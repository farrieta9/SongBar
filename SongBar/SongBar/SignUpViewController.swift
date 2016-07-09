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
	
	@IBOutlet weak var blurView: UIVisualEffectView!
	
	let userDefaults = NSUserDefaults.standardUserDefaults()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setNavigationBarTransparent()
		
		usernameTextField.delegate = self
		emailTextField.delegate = self
		passwordTextField.delegate = self
		let gradient: CAGradientLayer = CAGradientLayer()
		gradient.frame = view.bounds
		gradient.colors = [Utilities.getColor(149, green: 177, blue: 170).CGColor,
		                   Utilities.getColor(218, green: 237, blue: 248).CGColor,
		                   Utilities.getColor(96, green: 146, blue: 153).CGColor,
		                   Utilities.getColor(232, green: 207, blue: 187).CGColor,
		                   Utilities.getColor(236, green: 240, blue: 246).CGColor
		]
		
		view.layer.insertSublayer(gradient, atIndex: 0)
		
		self.hideKeyboardWhenTappedAround()
		
		
		signUpButton.backgroundColor = Utilities.getColor(229, green: 77, blue: 66)
		signUpButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		signUpButton.layer.cornerRadius = 10
		signUpButton.layer.borderWidth = 0
		signUpButton.clipsToBounds = true
		
		backButton.backgroundColor = Utilities.getColor(44, green: 62, blue: 79)
		backButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		backButton.layer.cornerRadius = 10
		
		messageLabel.hidden = true
		messageLabel.textColor = UIColor.redColor()
    }
	
	func setNavigationBarTransparent() -> Void {
		self.navigationItem.title = "Create Account"
		
		self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
		self.navigationController?.navigationBar.shadowImage = UIImage()
		self.navigationController?.navigationBar.translucent = true
		self.navigationController?.navigationBar.tintColor = UIColor.whiteColor() // Makes the back button white
		
		// Sets the title to white
		self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
	}
	
	@IBAction func onSignUp(sender: UIButton) {
		self.createAccount()
	}
	
	func createAccount() {
		// Check if fields are empty
		if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty || usernameTextField.text!.isEmpty {
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
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}
