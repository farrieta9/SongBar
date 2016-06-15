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

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
	
	@IBAction func onSignUp(sender: UIButton) {
		self.createAccount()
	}
	
	func createAccount() {
		// Check if fields are empty
		if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty || usernameTextField.text!.isEmpty {
			messageLabel.text = "All entries must be filled"
			return
		}
		
		// Check if password is long enough
		if passwordTextField.text?.characters.count < 6 {
			messageLabel.text = "Password must have at least 6 characters"
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
				
			} else {
				// No errors so store new user
				self.userDefaults.setValue(self.usernameTextField.text, forKey: "username")
				FIRDatabase.database().reference().child("users").child((data?.uid)!).setValue(["username": self.usernameTextField.text!])
				
				self.performSegueWithIdentifier("loginVC", sender: self)
			}
		
		})
		
	}

}
