//
//  LoginViewController.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/11/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var errorLabel: UILabel!

	let userDefaults = NSUserDefaults.standardUserDefaults()
	
    override func viewDidLoad() {
        super.viewDidLoad()

		if let email = userDefaults.stringForKey("email") {
			emailTextField.text = email
		}

		if let password = userDefaults.stringForKey("password") {
			passwordTextField.text = password
		}
		
		errorLabel.hidden = true
		errorLabel.textColor = UIColor.redColor()
		
		self.hideKeyboardWhenTappedAround()
		
		if areTextFieldsFilled() {
			login()
		}
    }
	
	
	@IBAction func onCreateAccount(sender: UIButton) {
		if !areTextFieldsFilled(){
			errorLabel.text = "Missing fields"
			errorLabel.hidden = false
			return
		}
		
		if !isPasswordLengthValid() {
			self.errorLabel.text = "Password must have 6 or more characters"
			self.errorLabel.hidden = false
			return
		}
		
		FIRAuth.auth()?.createUserWithEmail(emailTextField.text!, password: passwordTextField.text!, completion: {
			(data, error) in
			if error != nil {
				self.resetCurrentUser()
				// There is an error. Account is already created or improper format.
				print("error occred. Accout is already taken maybe")
				let errorMessage = error?.userInfo["error_name"]!.stringByReplacingOccurrencesOfString("_", withString: " ")
				print(errorMessage!)
				
				if errorMessage! == "ERROR EMAIL ALREADY IN USE" {
					self.errorLabel.text = "EMAIL ALREADY IN USE"
				} else {
					self.errorLabel.text = "Invalid email or password"
				}
				
				self.errorLabel.hidden = false
			} else {
				print("Create new user")
				self.storeCurrentUser()
				self.login()
			}
		})
	}
	
	@IBAction func onExistingUser(sender: UIButton) {
		if !areTextFieldsFilled() {
			errorLabel.text = "Missing fields"
			errorLabel.hidden = false
			return  // Texts are not filled
		}
		
		self.login()
	}
	
	// Checks if the email and password fiels are filled
	func areTextFieldsFilled() -> Bool {
		if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
			return false
		}
		errorLabel.hidden = true
		return true
	}
	
	func isPasswordLengthValid() -> Bool {
		if passwordTextField.text?.characters.count > 5 {
			return true
		} else {
			return false
		}
	}
	
	func login() {
		FIRAuth.auth()?.signInWithEmail(emailTextField.text!, password: passwordTextField.text!, completion: {
			data, error in
			if error != nil {
				self.resetCurrentUser()
				self.errorLabel.text = "Invalid email or password"
				self.errorLabel.hidden = false
			} else {
				print("Logged in successfully")
				print(data)
				print(error)
				self.storeCurrentUser()
				self.performSegueWithIdentifier("homeViewController", sender: self)
			}
		})
	}
	
	func resetCurrentUser() {
		userDefaults.setValue("", forKey: "email")
		userDefaults.setValue("", forKey: "password")
	}
	
	func storeCurrentUser() {
		userDefaults.setValue(self.emailTextField.text, forKey: "email")
		userDefaults.setValue(self.passwordTextField.text, forKey: "password")
	}
	
}

extension UIViewController {
	// http://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift
	func hideKeyboardWhenTappedAround() {
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
		view.addGestureRecognizer(tap)
	}
	
	func dismissKeyboard() {
		view.endEditing(true)
	}
}


extension LoginViewController: UITextFieldDelegate {
	func textFieldDidBeginEditing(textField: UITextField) {
		self.errorLabel.hidden = true
	}
}