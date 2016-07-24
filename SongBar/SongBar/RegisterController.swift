//
//  RegisterController.swift
//  SongBar
//
//  Created by Francisco Arrieta on 7/13/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit
import Firebase

class RegisterController: UIViewController {
	
	let ref = FIRDatabase.database().reference()
	
	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var fullnameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var registerButton: UIButton!
	@IBOutlet weak var backButton: UIButton!
	
	@IBAction func handleBackButton(sender: UIButton) {
		backToLogin()
	}
	
	@IBAction func handleRegisterButton(sender: UIButton) {
		
		guard let email = emailTextField.text, password = passwordTextField.text, username = usernameTextField.text?.lowercaseString, fullname = fullnameTextField.text else {
			return
		}
		
		if valideForm() == false {
			return
		}

		FIRDatabase.database().reference().child("users_by_name/\(username)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
			
			if snapshot.value is NSNull {
				FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
					if error != nil {
						print(error)
						self.displayAlert("Invalid email or email is taken")
						return
					}
					
					guard let uid = user?.uid else {
						return
					}
					// Successfully authenticated user
					let usersByIdRef = self.ref.child("users_by_id").child(uid)
					var values = ["username": username, "email": email, "fullname": fullname]
					usersByIdRef.updateChildValues(values)
					
					
					let usersByNameRef = self.ref.child("users_by_name").child(username)
					values = ["username": username, "email": email, "fullname": fullname, "uid": uid]
					usersByNameRef.updateChildValues(values)
					
					
					self.backToLogin()
				})
			} else {
				self.displayAlert("username is taken")
			}
			
			}, withCancelBlock: nil)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setUpView()
	}
	
	func backToLogin() {
		self.navigationController?.popViewControllerAnimated(true)
	}
	
	func setUpView() {
		view.backgroundColor = UIColor.rgb(59, green: 59, blue: 59)
		self.navigationItem.title = "Register"
		
		usernameTextField.placeholder = "Username"
		usernameTextField.autocorrectionType = .No
		usernameTextField.delegate = self
		
		fullnameTextField.delegate = self
		fullnameTextField.autocorrectionType = .No
		fullnameTextField.placeholder = "Fullname"
		
		emailTextField.placeholder = "Email"
		emailTextField.autocorrectionType = .No
		emailTextField.keyboardType = .EmailAddress
		emailTextField.delegate = self
		
		passwordTextField.placeholder = "Password"
		passwordTextField.secureTextEntry = true
		passwordTextField.delegate = self
		
		registerButton.setTitle("Register", forState: .Normal)
		registerButton.backgroundColor = UIColor.rgb(44, green: 62, blue: 79)
		registerButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		registerButton.layer.cornerRadius = 10
		
		backButton.setTitle("Back", forState: .Normal)
		backButton.backgroundColor = UIColor.greenColor()
		backButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		backButton.layer.cornerRadius = 10
		self.hideKeyboardWhenTappedAround()
	}
	
	func valideForm() -> Bool {
		
		guard let email = emailTextField.text, password = passwordTextField.text, username = usernameTextField.text, fullname = fullnameTextField.text else {
			return false
		}
		
		if email.isEmpty || password.isEmpty || username.isEmpty || fullname.isEmpty {
			displayAlert("All entries must be filled")
			return false
		}
		
		if password.characters.count < 6 {
			displayAlert("Password must be 6 characters or more")
			return false
		}
		
		return true
	}
	
	private func displayAlert(message: String) {
		let alertController = UIAlertController(title: "Invalid", message: message, preferredStyle: .Alert)
	
		let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
		alertController.addAction(defaultAction)
		presentViewController(alertController, animated: true, completion: nil)
	}
}

extension RegisterController: UITextFieldDelegate {
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}

