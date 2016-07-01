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
	@IBOutlet weak var signInButton: UIButton!
	@IBOutlet weak var createButton: UIButton!
	
	@IBOutlet weak var scrollView: UIScrollView!
	let userDefaults = NSUserDefaults.standardUserDefaults()
	
	
	let dayTopColor = Utilities.getColor(255, green: 226, blue: 79)
	let dayBottomColor = Utilities.getColor(47, green: 144, blue: 102)
	let dayToTopColor = Utilities.getColor(88, green: 139, blue: 169)
	let dayToBottomColor = Utilities.getColor(24, green: 112, blue: 131)
	
	let nightTopColor = Utilities.getColor(255, green: 226, blue: 79)
	let nightBottomColor =  Utilities.getColor(255, green: 226, blue: 79)
	let nightToTopColor = Utilities.getColor(47, green: 144, blue: 102)
	let nightToBottomColor = Utilities.getColor(24, green: 112, blue: 131)
	
	let gradient: CAGradientLayer = CAGradientLayer()
	var toColors : [CGColor]?
	var fromColors : [CGColor]?
	var day = true
	
    override func viewDidLoad() {
        super.viewDidLoad()
//		scrollView.contentInset = UIEdgeInsetsMake(0, 0, 400, 0)
		
		fromColors = [dayTopColor.CGColor, dayBottomColor.CGColor]
		toColors = [dayToTopColor.CGColor, dayToBottomColor.CGColor]
		
		gradient.colors = fromColors!
		gradient.frame = view.bounds
//		view.layer.insertSublayer(gradient, atIndex: 0)
		scrollView.layer.insertSublayer(gradient, atIndex: 0)
		
		
		signInButton.backgroundColor = Utilities.getColor(229, green: 77, blue: 66)
		signInButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		signInButton.layer.cornerRadius = 10
		
		createButton.backgroundColor = Utilities.getColor(44, green: 62, blue: 79)
		createButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		createButton.layer.cornerRadius = 10
		

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
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		self.scrollView.frame = self.view.bounds
		self.scrollView.contentSize.height = 400
		self.scrollView.contentSize.width = 0
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		animateLayer()
	}
	
	func toggleFromDayToNight() {
		day = !day
		
		if day {
			fromColors = [dayTopColor.CGColor, dayBottomColor.CGColor]
			toColors = [dayToTopColor.CGColor, dayToBottomColor.CGColor]
		} else {
			fromColors = [nightTopColor.CGColor, nightBottomColor.CGColor]
			toColors = [nightToTopColor.CGColor, nightToBottomColor.CGColor]
		}
		
		let colors = (gradient.presentationLayer() as! CAGradientLayer).colors // save the in-flight current colors
		gradient.removeAnimationForKey("animateGradient")                      // cancel the animation
		gradient.colors = colors                                               // restore the colors to in-flight values
		animateLayer()                                                          // start animation
	}
	
	func animateLayer() {
		let animation: CABasicAnimation = CABasicAnimation(keyPath: "colors")
		animation.fromValue = gradient.colors
		animation.toValue = toColors
		animation.duration = 3.0
		animation.removedOnCompletion = true
		animation.fillMode = kCAFillModeForwards
		animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
		animation.delegate = self
		
		gradient.colors = toColors
		
		gradient.addAnimation(animation, forKey:"animateGradient")
	}
	
	override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
		if flag {
			swap(&toColors, &fromColors)
			animateLayer()
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
		scrollView.setContentOffset(CGPointMake(0, 250), animated: true)
		print("move up")
	}
}