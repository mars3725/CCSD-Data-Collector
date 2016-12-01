//
//  ViewController.swift
//  DataCollector
//
//  Created by Matthew Mohandiss on 10/21/16.
//  Copyright © 2016 Matthew Mohandiss. All rights reserved.
//

import UIKit

class LoginController: UIViewController, UITextFieldDelegate {
    let username = "ccsd"
    let password = "password"
    
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardNotifications()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            passwordField.becomeFirstResponder()
            
        } else if textField == passwordField {
            passwordField.resignFirstResponder()
        }
        
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        usernameField.text = nil
        passwordField.text = nil
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if !usernameField.isFirstResponder && !passwordField.isFirstResponder {
            if authenticate() {
                return true
            } else {
                usernameField.text = nil
                passwordField.text = nil
                errorMessage.isHidden = false
                let timer = Timer(timeInterval: 2, repeats: false, block: { timer in
                    self.errorMessage.isHidden = true
                })
                RunLoop.current.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
                return false
            }
        }
        return false
    }
    
    func authenticate() -> Bool {
        let usernameText = usernameField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let passwordText = passwordField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if usernameText?.lowercased() == username && passwordText?.lowercased() == password {
            return true
        } else {
            return false
        }
    }
    
    func registerForKeyboardNotifications(){
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
        if self.usernameField.isFirstResponder {
            frame = usernameField.frame
        } else if self.passwordField.isFirstResponder {
            frame = passwordField.frame
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
