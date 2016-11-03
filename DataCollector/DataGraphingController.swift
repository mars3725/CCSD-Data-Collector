//
//  DataGraphingController.swift
//  DataCollector
//
//  Created by Matthew Mohandiss on 10/28/16.
//  Copyright © 2016 Matthew Mohandiss. All rights reserved.
//

import UIKit
import Charts
import CoreData
import MessageUI

class DataGraphingController: UIViewController, ChartViewDelegate, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var chartView: BarChartView!
    var student: NSManagedObject?
    var managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var shouldAnimate = true
    var csvPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("data.csv")
    let secondsInADay: Double = 86400
    
    override func viewWillAppear(_ animated: Bool) {
        if shouldAnimate {
            chartView.animate(xAxisDuration: 2, yAxisDuration: 2)
            shouldAnimate = false
        }
    }
    
    override func viewDidLoad() {
        createChart()
    }
    
    func createChart() {
        chartView.doubleTapToZoomEnabled = false
        chartView.chartDescription!.enabled = false
        
        chartView.leftAxis.granularityEnabled = true
        chartView.leftAxis.granularity = 1
        chartView.leftAxis.axisMinimum = 0
        
        chartView.xAxis.granularityEnabled = true
        chartView.xAxis.centerAxisLabelsEnabled = true
        chartView.xAxis.granularity = 1
        chartView.xAxis.axisMinimum = 0
        chartView.xAxis.avoidFirstLastClippingEnabled = true
        
        chartView.rightAxis.enabled = false
        
        chartView.scaleYEnabled = false
        chartView.delegate = self
        
        let dataSet = timestampsToDataset(firstSet: student!.value(forKey: "firstBehaviorFrequency") as! [TimeInterval], secondSet: student!.value(forKey: "secondBehaviorFrequency") as! [TimeInterval], modifier: secondsInADay)
        
        if !dataSet.isEmpty {
            var firstBehaviorEntries = [BarChartDataEntry]()
            var secondBehaviorEntries = [BarChartDataEntry]()
            
            for (index, entry) in dataSet.enumerated() {
                firstBehaviorEntries.append(BarChartDataEntry(x: Double(index), y: Double(entry.firstBehaviorCount), data: entry.date as AnyObject?))
                secondBehaviorEntries.append(BarChartDataEntry(x: Double(index), y: Double(entry.secondBehaviorCount), data: entry.date as AnyObject?))
            }
            
            let firstDataSet = BarChartDataSet(values: firstBehaviorEntries, label: student!.value(forKey: "firstBehavior") as? String)
            let secondDataSet = BarChartDataSet(values: secondBehaviorEntries, label: student!.value(forKey: "secondBehavior") as? String)
            
            firstDataSet.colors = [UIColor.init(red: 255/255, green: 105/255, blue: 97/255, alpha: 0.75)]
            secondDataSet.colors = [UIColor.init(red: 119/255, green: 221/255, blue: 119/255, alpha: 0.75)]
            let chartData = BarChartData(dataSets: [firstDataSet, secondDataSet])
            chartData.setValueFormatter(DefaultValueFormatter.init(decimals: 0))
            chartData.barWidth = 0.25
            chartView.data = chartData
            chartView.groupBars(fromX: 0, groupSpace: 0.5, barSpace: 0)
        } else {
            chartView.noDataTextColor = UIColor.black
            chartView.noDataText = "Not enough data to graph"
        }
        chartView.xAxis.axisMaximum = Double(dataSet.count)
    }
    
    @IBAction func saveButtonClicked(_ sender: UIBarButtonItem) {
        chartView.highlightValue(x: 0, dataSetIndex: -1, callDelegate: false)
        generateCSV()
        sendMail()
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        navigationBar.title = entry.data as? String
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        navigationBar.title = nil
    }
    
    func generateCSV() {
        let dataset = timestampsToDataset(firstSet: student!.value(forKey: "firstBehaviorFrequency") as! [TimeInterval], secondSet: student!.value(forKey: "secondBehaviorFrequency") as! [TimeInterval], modifier: secondsInADay)
        
        if csvPath != nil {
            guard let stream = OutputStream(url: csvPath!, append: false) else {
                print("unable to open file")
                return
            }
            
            stream.open()
            write(stream: stream, string: "Date, \(student!.value(forKey: "firstBehavior").unsafelyUnwrapped),  \(student!.value(forKey: "secondBehavior").unsafelyUnwrapped)\n")
            
            for value in dataset {
                guard write(stream: stream, string: "\"\(value.date)\", \(value.firstBehaviorCount), \(value.secondBehaviorCount)\n") > 0 else {
                    print("unable to write to file")
                    break
                }
            }
            stream.close()
        }
    }
    
    @discardableResult func write(stream: OutputStream, string: String) -> Int {
        if let data = string.data(using: String.Encoding.utf8) {
            var bytesRemaining = data.count
            var totalBytesWritten = 0
            
            while bytesRemaining > 0 {
                let bytesWritten = data.withUnsafeBytes {
                    stream.write(
                        $0.advanced(by: totalBytesWritten),
                        maxLength: bytesRemaining
                    )
                }
                if bytesWritten < 0 {
                    return -1
                } else if bytesWritten == 0 {
                    return totalBytesWritten
                }
                
                bytesRemaining -= bytesWritten
                totalBytesWritten += bytesWritten
            }
            
            return totalBytesWritten
        }
        
        return -1
    }
    
    func sendMail() {
        if( MFMailComposeViewController.canSendMail() ) {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            mailComposer.setSubject("Data for \(student!.value(forKey: "firstName").unsafelyUnwrapped) \(student!.value(forKey: "lastName").unsafelyUnwrapped)")
            
            do {
                mailComposer.addAttachmentData(try Data.init(contentsOf: csvPath!.absoluteURL), mimeType: "text/csv", fileName: "\(student!.value(forKey: "firstName").unsafelyUnwrapped) \(student!.value(forKey: "lastName").unsafelyUnwrapped) Data")
                mailComposer.addAttachmentData(UIImagePNGRepresentation(chartView.getChartImage(transparent: false)!)!, mimeType: "image/png", fileName: "\(student!.value(forKey: "firstName").unsafelyUnwrapped) \(student!.value(forKey: "lastName").unsafelyUnwrapped) Chart")
            } catch {
                print("Failed trying to add attachments")
            }
            
            self.present(mailComposer, animated: true, completion: nil)
        } else {
            print("Cannot send mail")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

func timestampsToDataset(firstSet: [TimeInterval], secondSet: [TimeInterval], modifier: Double) -> [(date: String, firstBehaviorCount: Int, secondBehaviorCount: Int)] {
    var daysArray = [(date: String, firstBehaviorCount: Int, secondBehaviorCount: Int)]()
    
    if !firstSet.isEmpty && !secondSet.isEmpty {
        let firstDay = Int(floor(min(firstSet.first!, secondSet.first!)/modifier))
        let lastDay = Int(floor(max(firstSet.last!, secondSet.last!)/modifier))
        
        let startDate = Date(timeIntervalSince1970: Double(firstDay)*modifier)
        
        for dayCount in firstDay...lastDay {
            let date = Calendar.current.date(byAdding: .day, value: (dayCount - firstDay) + 1, to: startDate)!.toString()
            let firstBehaviorCount = firstSet.filter({Int(floor($0/modifier)) == dayCount}).count
            let secondBehaviorCount = secondSet.filter({Int(floor($0/modifier)) == dayCount}).count
            daysArray.append((date, firstBehaviorCount, secondBehaviorCount))
        }
    }
    
    return daysArray
}

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: self)
    }
}
