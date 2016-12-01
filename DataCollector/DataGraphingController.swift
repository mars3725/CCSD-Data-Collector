//
//  DataGraphingController.swift
//  DataCollector
//
//  Created by Matthew Mohandiss on 10/28/16.
//  Copyright © 2016 Matthew Mohandiss. All rights reserved.
//

// (barWidth + barSpace) * barCount + groupSpace = 1.00

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
            chartView.animate(xAxisDuration: 1.5, yAxisDuration: 1.5)
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
        chartView.xAxis.granularity = 1
        chartView.xAxis.axisMinimum = 0
        chartView.xAxis.centerAxisLabelsEnabled = true
        
        chartView.rightAxis.enabled = false
        
        chartView.scaleYEnabled = false
        chartView.delegate = self
        
        let dataSet = timestampsToDataset(firstSet: student!.value(forKey: "firstBehaviorFrequency") as? [TimeInterval], secondSet: student!.value(forKey: "secondBehaviorFrequency") as? [TimeInterval], modifier: secondsInADay)
        let chartData = BarChartData()
        
        if dataSet.firstSet != nil {
            var firstBehaviorEntries = [BarChartDataEntry]()
            for (index, entry) in dataSet.firstSet!.enumerated() {
                firstBehaviorEntries.append(BarChartDataEntry(x: Double(index), y: Double(entry.count), data: entry.date as AnyObject?))
            }
            let BarChartData = BarChartDataSet(values: firstBehaviorEntries, label: student!.value(forKey: "firstBehavior") as? String)
            BarChartData.colors = [UIColor.init(red: 255/255, green: 105/255, blue: 97/255, alpha: 0.75)]
            chartData.addDataSet(BarChartData)
        }
        
        if dataSet.secondSet != nil {
            var secondBehaviorEntries = [BarChartDataEntry]()
            for (index, entry) in dataSet.secondSet!.enumerated() {
                secondBehaviorEntries.append(BarChartDataEntry(x: Double(index), y: Double(entry.count), data: entry.date as AnyObject?))
            }
            let BarChartData = BarChartDataSet(values: secondBehaviorEntries, label: student!.value(forKey: "secondBehavior") as? String)
            BarChartData.colors = [UIColor.init(red: 119/255, green: 221/255, blue: 119/255, alpha: 0.75)]
            chartData.addDataSet(BarChartData)
        }
        
        chartData.setValueFormatter(DefaultValueFormatter.init(decimals: 0))
        chartView.data = chartData
        print(chartData.entryCount)
        
        if chartData.entryCount == 0 {
            chartView.clear()
            chartView.noDataTextColor = UIColor.black
            chartView.noDataText = "At least one entry in each behavior category is required for data graphing."
            navigationBar.rightBarButtonItem?.isEnabled = false
            
        } else if chartData.dataSetCount == 1 {
            chartData.barWidth = 0.5
            chartView.xAxis.axisMaximum += 0.5
            for index in 0...chartView.barData!.entryCount-1 {
                chartView.barData?.dataSets.first!.entryForIndex(index)!.x += 0.5
            }
            
        } else if chartData.dataSetCount == 2 {
            chartData.barWidth = 0.25
            chartView.groupBars(fromX: 0, groupSpace: 0.5, barSpace: 0)
            chartView.xAxis.axisMaximum = Double(max(dataSet.firstSet!.count, dataSet.secondSet!.count))
        }
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
        navigationBar.title = "Graph"
    }
    
    func generateCSV() {
        let dataSet = timestampsToDataset(firstSet: student!.value(forKey: "firstBehaviorFrequency") as? [TimeInterval], secondSet: student!.value(forKey: "secondBehaviorFrequency") as? [TimeInterval], modifier: secondsInADay)
        
        if csvPath != nil {
            guard let stream = OutputStream(url: csvPath!, append: false) else {
                print("unable to open file")
                return
            }
            
            stream.open()
            
            if dataSet.firstSet != nil && dataSet.secondSet != nil {
                write(stream: stream, string: "Date, \(student!.value(forKey: "firstBehavior").unsafelyUnwrapped),  \(student!.value(forKey: "secondBehavior").unsafelyUnwrapped)\n")
                for index in 0...min(dataSet.firstSet!.count, dataSet.secondSet!.count)-1 {
                    guard write(stream: stream, string: "\"\(dataSet.firstSet![index].date)\", \(dataSet.firstSet![index].count), \(dataSet.secondSet![index].count)\n") > 0 else {
                        print("unable to write to file")
                        break
                    }
                }
                
            } else if dataSet.firstSet != nil {
                write(stream: stream, string: "Date, \(student!.value(forKey: "firstBehavior").unsafelyUnwrapped)\n")
                for index in 0...dataSet.firstSet!.count-1 {
                    guard write(stream: stream, string: "\"\(dataSet.firstSet![index].date)\", \(dataSet.firstSet![index].count)\n") > 0 else {
                        print("unable to write to file")
                        break
                    }
                }
                
            } else if dataSet.secondSet != nil {
                write(stream: stream, string: "Date, \(student!.value(forKey: "secondBehavior").unsafelyUnwrapped)\n")
                for index in 0...dataSet.secondSet!.count-1 {
                    guard write(stream: stream, string: "\"\(dataSet.secondSet![index].date)\", \(dataSet.secondSet![index].count)\n") > 0 else {
                        print("unable to write to file")
                        break
                    }
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

func timestampsToDataset(firstSet: [TimeInterval]?, secondSet: [TimeInterval]?, modifier: Double) -> (firstSet: [(date: String, count: Int)]?, secondSet: [(date: String, count: Int)]?) {
    var firstDataSet: [(date: String, count: Int)]?
    var secondDataSet: [(date: String, count: Int)]?
    var firstDay: Int?
    var lastDay: Int?
    
    if firstSet != nil && secondSet != nil {
        if !firstSet!.isEmpty && !secondSet!.isEmpty {
            firstDay = Int(floor(min(firstSet!.first!, secondSet!.first!)/modifier))
            lastDay = Int(floor(max(firstSet!.last!, secondSet!.last!)/modifier))
        } else if !firstSet!.isEmpty {
            firstDay = Int(firstSet!.first!/modifier)
            lastDay = Int(firstSet!.last!/modifier)
        } else if !secondSet!.isEmpty {
            firstDay = Int(secondSet!.first!/modifier)
            lastDay = Int(secondSet!.last!/modifier)
        }
    } else if firstSet != nil {
        if !firstSet!.isEmpty {
            firstDay = Int(firstSet!.first!/modifier)
            lastDay = Int(firstSet!.last!/modifier)
        }
    } else if secondSet != nil {
        if !secondSet!.isEmpty {
            firstDay = Int(secondSet!.first!/modifier)
            lastDay = Int(secondSet!.last!/modifier)
        }
    }
    
    if firstDay != nil && lastDay != nil {
        
        let startDate = Date(timeIntervalSince1970: Double(firstDay!)*modifier)
        if firstSet != nil {
            firstDataSet = [(date: String, count: Int)]()
        }
        if secondSet != nil {
            secondDataSet = [(date: String, count: Int)]()
        }
        
        for dayCount in firstDay!...lastDay! {
            let date = Calendar.current.date(byAdding: .day, value: (dayCount - firstDay!) + 1, to: startDate)!.toString()
            
            if firstSet != nil {
                firstDataSet!.append((date, firstSet!.filter({Int(floor($0/modifier)) == dayCount}).count))
            }
            
            if secondSet != nil {
                secondDataSet!.append((date, secondSet!.filter({Int(floor($0/modifier)) == dayCount}).count))
            }
        }
    }
    return (firstDataSet, secondDataSet)
}

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: self)
    }
}
