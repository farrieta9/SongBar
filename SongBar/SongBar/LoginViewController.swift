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
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var signInButton: UIButton!
	@IBOutlet weak var createButton: UIButton!
	
	let userDefaults = NSUserDefaults.standardUserDefaults()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
//		signInButton.backgroundColor = UIColor.clearColor()
		signInButton.backgroundColor = Utilities.getColor(229, green: 77, blue: 66)
		signInButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		signInButton.layer.cornerRadius = 10
		signInButton.layer.borderWidth = 0
		signInButton.clipsToBounds = true
		
		createButton.backgroundColor = Utilities.getColor(44, green: 62, blue: 79)
		createButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		createButton.layer.cornerRadius = 10
//		createButton.
		

		if let email = userDefaults.stringForKey("email") {
			emailTextField.text = email
		}

		if let password = userDefaults.stringForKey("password") {
			passwordTextField.text = password
		}
		
		errorLabel.hidden = true
		errorLabel.textColor = UIColor.redColor()
		
		Utilities.getDateTime()
		
		self.hideKeyboardWhenTappedAround()
		
		if areTextFieldsFilled() {
			login()
		}
    }
	
	
	@IBAction func onSignIn(sender: UIButton) {
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
				Utilities.resetCurrentUser()
				self.errorLabel.text = "Invalid email or password"
				self.errorLabel.hidden = false
			} else {
				print("Logged in successfully")
				
				guard let name = FIRAuth.auth()?.currentUser?.displayName else {
					return
				}
				
				print("Welcome \(name)")

				
				self.storeCurrentUser((data?.uid)!, username: name)
				self.performSegueWithIdentifier("homeViewController", sender: self)
			}
		})
	}
	
	
	func storeCurrentUser(uid: String, username: String) {
		
		self.userDefaults.setValue(username, forKey: "username")
		userDefaults.setValue(self.emailTextField.text, forKey: "email")
		userDefaults.setValue(self.passwordTextField.text, forKey: "password")
		userDefaults.setValue(uid, forKey: "uid")
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