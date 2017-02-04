//
//  ViewController.swift
//  DataCollector
//
//  Created by Matthew Mohandiss on 10/21/16.
//  Copyright © 2016 Matthew Mohandiss. All rights reserved.
//

import UIKit

class LoginController: UIViewController, UITextFieldDelegate {
    var pin = 0
    
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var pinField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pin = UserDefaults.standard.integer(forKey: "pin")
        super.viewWillAppear(animated)
        pinField.text = nil
        
        if pin == 0 {
            pinField.placeholder = "Create PIN"
        } else {
            pinField.placeholder = "Enter PIN"
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if let potentialpassword = Int(pinField.text!) {
            if pin == 0 {
                UserDefaults.standard.set(potentialpassword, forKey: "pin")
                UserDefaults.standard.synchronize()
                return true
            } else if potentialpassword == pin {
                return true
            }
        }
        
        pinField.text = nil
        errorMessage.isHidden = false
        let timer = Timer(timeInterval: 2, repeats: false, block: { timer in
            self.errorMessage.isHidden = true
        })
        RunLoop.current.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if string.isEmpty || textField.text!.characters.count < 3 {
                return true
            } else if textField.text!.characters.count == 3 {
                textField.resignFirstResponder()
            }
        
        return false
    }
}
