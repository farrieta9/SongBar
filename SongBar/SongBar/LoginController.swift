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
	
	let dayTopColor = UIColor.rgb(255, green: 226, blue: 79)
	let dayBottomColor = UIColor.rgb(47, green: 144, blue: 102)
	let dayToTopColor = UIColor.rgb(88, green: 139, blue: 169)
	let dayToBottomColor = UIColor.rgb(24, green: 112, blue: 131)
	
	let nightTopColor = UIColor.rgb(255, green: 226, blue: 79)
	let nightBottomColor =  UIColor.rgb(255, green: 226, blue: 79)
	let nightToTopColor = UIColor.rgb(47, green: 144, blue: 102)
	let nightToBottomColor = UIColor.rgb(24, green: 112, blue: 131)
	
	let gradient: CAGradientLayer = CAGradientLayer()
	var toColors : [CGColor]?
	var fromColors : [CGColor]?
	var day = true
	
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
	
	override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
		if flag {
			swap(&toColors, &fromColors)
			animateLayer()
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		CurrentUser.signOut()
		applyGradientBackground()

		setUpViews()
		autoLogin()
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
//		animateLayer()
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
	
	func applyGradientBackground() {
		
		fromColors = [dayTopColor.CGColor, dayBottomColor.CGColor]
		toColors = [dayToTopColor.CGColor, dayToBottomColor.CGColor]
		
		gradient.colors = fromColors!
		gradient.frame = view.bounds
		gradient.frame = registerButton.bounds
		registerButton.clipsToBounds = true
		
		// Make gradient horizontal
		gradient.startPoint = CGPointMake(0.0, 0.5)
		gradient.endPoint = CGPointMake(1.0, 0.5)
		
//		view.layer.insertSublayer(gradient, atIndex: 0)
		registerButton.layer.insertSublayer(gradient, atIndex: 0)
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
		
		emailTextField.placeholder = "Email"
		emailTextField.autocorrectionType = .No
		emailTextField.keyboardType = .EmailAddress
		emailTextField.delegate = self
		
		passwordTextField.placeholder = "Password"
		passwordTextField.secureTextEntry = true
		passwordTextField.delegate = self
		
		loginButton.setTitle("Login", forState: .Normal)
		loginButton.backgroundColor = UIColor.rgb(229, green: 77, blue: 66)
		loginButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		loginButton.layer.cornerRadius = 10
		
		registerButton.setTitle("Register", forState: .Normal)
		registerButton.backgroundColor = UIColor.rgb(44, green: 62, blue: 79)
		registerButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		registerButton.layer.cornerRadius = 10
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
	
}

extension LoginController: UITextFieldDelegate {
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}
