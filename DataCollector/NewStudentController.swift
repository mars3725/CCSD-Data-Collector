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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var firstBehaviorField: UITextField!
    @IBOutlet weak var secondBehaviorField: UITextField!
    var managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardNotifications()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        addStudent()
        navigationController!.popViewController(animated: true)
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameField && lastNameField.text!.isEmpty {
            lastNameField.becomeFirstResponder()
        } else if textField == lastNameField && firstBehaviorField.text!.isEmpty {
            firstBehaviorField.becomeFirstResponder()
        } else if textField == firstBehaviorField && secondBehaviorField.text!.isEmpty {
            secondBehaviorField.becomeFirstResponder()
        } else if textField == secondBehaviorField {
            secondBehaviorField.resignFirstResponder()
            self.scrollView.scrollRectToVisible(firstNameField.frame, animated: true)
        } else {
            textField.resignFirstResponder()
            self.scrollView.scrollRectToVisible(firstNameField.frame, animated: true)
        }
        
        if !firstNameField.text!.isEmpty && !lastNameField.text!.isEmpty && !firstBehaviorField.text!.isEmpty && !secondBehaviorField.text!.isEmpty {
            doneButton.isEnabled = true
        } else {
            doneButton.isEnabled = false
        }
        
        return true
    }
    
    func addStudent() {
        let transaction = NSEntityDescription.insertNewObject(forEntityName: "Student", into: managedObjectContext)
        transaction.setValue(self.firstNameField.text, forKey: "firstName")
        transaction.setValue(self.lastNameField.text, forKey: "lastName")
        transaction.setValue(self.firstBehaviorField.text, forKey: "firstBehavior")
        transaction.setValue(self.secondBehaviorField.text, forKey: "secondBehavior")
        transaction.setValue([TimeInterval](), forKey: "firstBehaviorFrequency")
        transaction.setValue([TimeInterval](), forKey: "secondBehaviorFrequency")
        
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print("error")
            }
        }
    }
    
    func registerForKeyboardNotifications() {
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height + 50, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        var frame = CGRect()
        if self.firstNameField.isFirstResponder {
            frame = firstNameField.frame
        } else if self.lastNameField.isFirstResponder {
            frame = lastNameField.frame
        } else if self.firstBehaviorField.isFirstResponder {
            frame = firstBehaviorField.frame
        } else if self.secondBehaviorField.isFirstResponder {
            frame = secondBehaviorField.frame
        }
        
         self.scrollView.scrollRectToVisible(frame, animated: true)
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.scrollView.isScrollEnabled = false
    }
    
}

