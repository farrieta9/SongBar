//
//  LoginController.swift
//  SongBar
//
//  Created by Francisco Arrieta on 7/13/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
	
	
	@IBOutlet weak var inputContainerView: UIView!
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var loginButton: UIButton!
	@IBOutlet weak var registerButton: UIButton!
	
	
	@IBAction func handleLogin(sender: UIButton) {
		login()
	}
	
	private func displayAlert(message: String) {
		let alertController = UIAlertController(title: "Invalid", message: message, preferredStyle: .Alert)
		
		let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
		alertController.addAction(defaultAction)
		presentViewController(alertController, animated: true, completion: nil)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		CurrentUser.signOut()

		setUpViews()
		autoLogin()
    }
	
	func autoLogin() {
		let email = CurrentUser.getEmail()
		let password = CurrentUser.getPassword()
		if email.isEmpty || password.isEmpty {
			return
		}
		emailTextField.text = email
		passwordTextField.text = password
		
		login()
	}

	func login() {
		guard let email = emailTextField.text, password = passwordTextField.text else {
			return
		}
		
		FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
			if error != nil {
				self.displayAlert("Invalid email or password")
				return
			}
			// Signed in successfully
			if let uid = user?.uid {
				CurrentUser.storeUser(uid, email: email, password: password)
				self.performSegueWithIdentifier("home", sender: self)
			}
		})
	}
	
	func setUpViews() {
		self.navigationItem.title = "Login"
		self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
		self.navigationController?.navigationBar.shadowImage = UIImage()
		self.navigationController?.navigationBar.translucent = true
		self.navigationController?.navigationBar.tintColor = UIColor.whiteColor() // Makes the back button white
		self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
		
		view.backgroundColor = UIColor.rgb(59, green: 59, blue: 59)
		inputContainerView.backgroundColor = UIColor.clearColor()
		
		emailTextField.placeholder = "Email"
		emailTextField.autocorrectionType = .No
		emailTextField.keyboardType = .EmailAddress
		emailTextField.delegate = self
		emailTextField.textAlignment = .Left
		
		passwordTextField.placeholder = "Password"
		passwordTextField.secureTextEntry = true
		passwordTextField.delegate = self
		passwordTextField.textAlignment = .Left
		
		loginButton.setTitle("Login", forState: .Normal)
		loginButton.backgroundColor = UIColor.rgb(229, green: 77, blue: 66)
		loginButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		loginButton.layer.cornerRadius = 8
		loginButton.titleLabel?.font = UIFont.boldSystemFontOfSize(16)
		loginButton.applyGraidentToButton()
		
		registerButton.setTitle("Register", forState: .Normal)
		registerButton.backgroundColor = UIColor.rgb(44, green: 62, blue: 79)
		registerButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		registerButton.layer.cornerRadius = 8
		registerButton.titleLabel?.font = UIFont.boldSystemFontOfSize(16)
		registerButton.applyGraidentToButton()
		
		
		self.hideKeyboardWhenTappedAround()
	}
}

extension LoginController: UITextFieldDelegate {
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}
