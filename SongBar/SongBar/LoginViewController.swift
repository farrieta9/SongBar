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
    override func viewDidLoad() {
        super.viewDidLoad()
		errorLabel.hidden = true
		errorLabel.textColor = UIColor.redColor()
        // Do any additional setup after loading the view.
    }
	
	
	@IBAction func onCreateAccount(sender: UIButton) {
		print("yeah")
		FIRAuth.auth()?.createUserWithEmail(emailTextField.text!, password: passwordTextField.text!, completion: {
			(user, error) in
			if error != nil {
				// There is an error. Account is already created or improper format.
				print("error occred. Accout is already taken maybe")
				self.login()
			} else {
				print("Create new user")
				self.login()
			}
		})
	}
	@IBAction func onExistingUser(sender: UIButton) {
		print("login existing user")
		self.login()
	}
	
	func login() {
		FIRAuth.auth()?.signInWithEmail(emailTextField.text!, password: passwordTextField.text!, completion: {
			user, error in
			if error != nil {
				print("Incorrect")
				self.errorLabel.text = "Incorrect email or password"
				self.errorLabel.hidden = false
			} else {
				print("it worked")
				self.performSegueWithIdentifier("homeViewController", sender: self)
			}
		})
	}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension LoginViewController: UITextFieldDelegate {
	func textFieldDidBeginEditing(textField: UITextField) {
		self.errorLabel.hidden = true
	}
}