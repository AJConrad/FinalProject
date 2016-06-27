//
//  LoginViewController.swift
//  DetroitPotholeReporter
//
//  Created by Andrew Conrad on 6/21/16.
//  Copyright © 2016 AndrewConrad. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    //I dont much like the text blocks but I need a way to convey what each option does. Fix this later.
    //Instead of horizontally alligned buttons, try vertically alligned buttons.
    
    let loginManager = LoginManager.sharedInstance
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    
    
    //MARK: - User Login Verification Methods
    
    //minimum what email and password can be method
    @IBAction private func entryFieldsChanged() {
        guard let email = loginTextField.text else {
            return
        }
        
        guard let password = passwordTextField.text else {
            return
        }
        
        if isValidLogin(email, password: password) {
            loginButton.enabled = true
            signupButton.enabled = true
        }
    }
    
    private func isValidLogin(email: String, password: String) -> Bool {
        return email.characters.count > 5 && password.characters.count > 3
    }

    
    
    //MARK: - Interactivity Methods

    //Login functions
    @IBAction func loginButtonPressed(sender: AnyObject) {
        guard let email = loginTextField.text else {
            return
        }
        
        guard let password = passwordTextField.text else {
            return
        }
        print("Guard worked")
        
        loginManager.loginUser(email, password: password)
    }
    
    func loginSuccess() {
        print("Will Segue")
        performSegueWithIdentifier("Login", sender: self)
        print("Did Segue")
        
    }
    
    func loginFail() {
        //add popup explaining failure, delete print below
        print("Login Failure")
    }
    
    //Registering functions
    @IBAction func signupButtonPressed(sender: AnyObject) {
        
        guard let email = loginTextField.text else {
            return
        }
        
        guard let password = passwordTextField.text else {
            return
        }
        
        loginManager.registerNewUser(email, password: password)
    }
    
    func regSuccess() {
        performSegueWithIdentifier("Login", sender: self)
    }
    
    func regFail() {
        //add a popup window explaining failure, delete print below
        print("Register Failure")
    }
    
    //No login functions
    @IBAction func contiueButtonPressed(sender: AnyObject) {
        performSegueWithIdentifier("Login", sender: self)
    }
    
    
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signupButton.enabled = false
//        loginButton.enabled = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loginSuccess), name: "LoggedInMsg", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loginFail), name: "LoggedInErrorMsg", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(regSuccess), name: "RegisteredMsg", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(regFail), name: "RegisterErrorMsg", object: nil)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}
