//
//  BehaviorRecorderController.swift
//  DataCollector
//
//  Created by Matthew Mohandiss on 10/23/16.
//  Copyright © 2016 Matthew Mohandiss. All rights reserved.ReyHittD
//

import UIKit
import CoreData

class BehaviorInputController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var firstBehavior: UIButton!
    @IBOutlet weak var secondBehavior: UIButton!
    var student: NSManagedObject?
    var managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let seg = segue.destination as? DataGraphingController {
            seg.student = student
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let firstName = student!.value(forKey: "firstName") as! String
        let lastName = student!.value(forKey: "lastName") as! String
        navigationBar.title = String(firstName.characters.first!) + " " + lastName
        firstBehavior.setTitle(student!.value(forKey: "firstBehavior") as! String?, for: UIControlState.normal)
        secondBehavior.setTitle(student!.value(forKey: "secondBehavior") as! String?, for: UIControlState.normal)
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if toInterfaceOrientation.isPortrait {
            stackView.axis = UILayoutConstraintAxis.vertical
        } else {
            stackView.axis = UILayoutConstraintAxis.horizontal
        }
    }
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        var key = String()
        
        if sender.isEqual(firstBehavior) {
            key = "firstBehaviorFrequency"
        } else if sender.isEqual(secondBehavior) {
            key = "secondBehaviorFrequency"
        }
        let timestamp = Date().timeIntervalSince1970
        var timestamps = student!.value(forKey: key) as! [TimeInterval]
        timestamps.append(timestamp)
        student!.setValue(timestamps, forKey: key)
        
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print("error")
            }
        }
    }
}
