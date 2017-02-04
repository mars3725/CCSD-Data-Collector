//
//  newStudentController.swift
//  DataCollector
//
//  Created by Matthew Mohandiss on 10/22/16.
//  Copyright © 2016 Matthew Mohandiss. All rights reserved.
//

import UIKit
import CoreData

class NewStudentController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var behaviorsTable: UITableView!
    @IBOutlet weak var scheduleTable: UITableView!
    
    
    var managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addBehavior(_ sender: UIButton) {
        let newCell = behaviorsTable.dequeueReusableCell(withIdentifier: "behavior", for: IndexPath(item: 0, section: 0))
        newCell.textLabel!.text = "new behavior"
        //newCell.imageView!.image = createColorImage(color: UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1))
        //(newCell.textLabel!.viewWithTag(1) as! UITextField).becomeFirstResponder()
    }
    
    
    @IBAction func addPeriod(_ sender: Any) {
//        let newCell = behaviorsTable.dequeueReusableCell(withIdentifier: "period", for: IndexPath(item: 0, section: 0))
//        newCell.textLabel!.text = "new period"
        //newCell.imageView!.image = createColorImage(color: UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1))
        //(newCell.textLabel!.viewWithTag(1) as! UITextField).becomeFirstResponder()
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        addStudent()
        navigationController!.popViewController(animated: true)
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameField && lastNameField.text!.isEmpty {
            lastNameField.becomeFirstResponder()
        } else if textField == lastNameField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func addStudent() {
//        let transaction = NSEntityDescription.insertNewObject(forEntityName: "Student", into: managedObjectContext)
//        transaction.setValue(self.firstNameField.text, forKey: "firstName")
//        transaction.setValue(self.lastNameField.text, forKey: "lastName")
//        
//        if !firstBehaviorField.text!.isEmpty {
//            transaction.setValue(self.firstBehaviorField.text, forKey: "firstBehavior")
//            if self.firstNameField.text == "Test" && self.lastNameField.text == "Student" {
//                transaction.setValue(generateFakeData(count: 250, months: 3), forKey: "firstBehaviorFrequency")
//            } else {
//                transaction.setValue([TimeInterval](), forKey: "firstBehaviorFrequency")
//            }
//        }
//        
//        if !secondBehaviorField.text!.isEmpty {
//            transaction.setValue(self.secondBehaviorField.text, forKey: "secondBehavior")
//            if self.firstNameField.text == "Test" && self.lastNameField.text == "Student" {
//                transaction.setValue(generateFakeData(count: 250, months: 3), forKey: "secondBehaviorFrequency")
//            } else {
//                transaction.setValue([TimeInterval](), forKey: "secondBehaviorFrequency")
//            }
//        }
//        
//        if managedObjectContext.hasChanges {
//            do {
//                try managedObjectContext.save()
//            } catch {
//                print("error")
//            }
//        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !firstNameField.text!.isEmpty && !lastNameField.text!.isEmpty && behaviorsTable.numberOfRows(inSection: 0) != 0 && scheduleTable.numberOfRows(inSection: 0) != 0 {
            doneButton.isEnabled = true
        } else {
            doneButton.isEnabled = false
        }
        return true
    }
    
    func generateFakeData(count: Int, months: Int) -> [Double] {
        let oneMonth: UInt32 = 2592000
        var data = [Double]()
        for _ in 1...count {
            data.append(Date().timeIntervalSince1970 - Double(arc4random_uniform(oneMonth * UInt32(months))))
        }
        return data.sorted(by: <)
    }
    
    func createColorImage(color: UIColor) -> UIImage
    {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 10, height: 10))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
}

class BehaviorCell: UITableViewCell {
    
}

class PeriodCell: UITableViewCell {
    
}

