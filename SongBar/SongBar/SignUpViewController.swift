//
//  SignUpViewController.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/14/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var signUpButton: UIButton!
	
	let userDefaults = NSUserDefaults.standardUserDefaults()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.hideKeyboardWhenTappedAround()
		
		messageLabel.hidden = true
		messageLabel.textColor = UIColor.redColor()
    }
	
	@IBAction func onSignUp(sender: UIButton) {
		self.createAccount()
	}
	
	func createAccount() {
		// Check if fields are empty
		if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty || usernameTextField.text!.isEmpty {
			messageLabel.text = "All entries must be filled"
			messageLabel.hidden = false
			return
		}
		
		// Check if password is long enough
		if passwordTextField.text?.characters.count < 6 {
			messageLabel.text = "Password must have at least 6 characters"
			messageLabel.hidden = false
			return
		}
		
		FIRAuth.auth()?.createUserWithEmail(emailTextField.text!, password: passwordTextField.text!, completion: {(data, error) in
			
			if error != nil {
				// Check the kind of error
				let errorMessage = error?.userInfo["error_name"]!.stringByReplacingOccurrencesOfString("_", withString: " ")
				if errorMessage! == "ERROR EMAIL ALREADY IN USE" {
					self.messageLabel.text = "Email is taken"
				} else {
					self.messageLabel.text = "Invalid email or password"
				}
				self.messageLabel.hidden = false
				
			} else {
				// No errors so store new user
				self.userDefaults.setValue(self.usernameTextField.text, forKey: "username")
				FIRDatabase.database().reference().child("users").child("users_by_id").child((data?.uid)!).setValue(["username": self.usernameTextField.text!.lowercaseString])
				FIRDatabase.database().reference().child("users").child("users_by_name").child((self.usernameTextField.text?.lowercaseString)!).setValue(["uid": (data?.uid)!])
				
				let user = FIRAuth.auth()?.currentUser
				if let user = user {
					let changeRequest = user.profileChangeRequest()
					
					changeRequest.displayName = self.usernameTextField.text
//					changeRequest.photoURL = NSURL(string: "https://example.com/jane-q-user/profile.jpg")
					changeRequest.commitChangesWithCompletion { error in
						if let error = error {
							print(error)  // An error happened.
						} else {
							print("Profile updated successfully") // Profile updated.
						}
					}
				}

				
				self.view.endEditing(true)
				self.messageLabel.text = "Success"
				self.messageLabel.hidden = false
				
				self.performSegueWithIdentifier("loginVC", sender: self)
			}
		
		})
		
	}

}

extension SignUpViewController: UITextFieldDelegate {
	func textFieldDidBeginEditing(textField: UITextField) {
		self.messageLabel.hidden = true
	}
}
