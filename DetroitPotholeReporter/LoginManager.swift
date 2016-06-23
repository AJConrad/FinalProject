//
//  LoginManager.swift
//  DetroitPotholeReporter
//
//  Created by Andrew Conrad on 6/21/16.
//  Copyright © 2016 AndrewConrad. All rights reserved.
//

import UIKit

class LoginManager: NSObject {
    
    static let sharedInstance = LoginManager()
    let backendless = Backendless.sharedInstance()
    var currentUser = BackendlessUser()
    
    func registerNewUser(email: String, password: String) {
        
        let user = BackendlessUser()
        user.email = email
        user.password = password
        
        backendless.userService.registering(user, response: { (registeredUser) in
            print("Sucess Registering \(registeredUser.email)")
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "RegisteredMsg", object: nil))
        }) { (error) in
            print("Error Registering \(error)")
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "RegisterErrorMsg", object: nil))
        }
    }
    
    func loginUser(email: String, password: String) {
        print("Login func")
        
        backendless.userService.login(email, password: password, response: { (loggedInUser) in
            print("Logged In \(loggedInUser.email)")
            self.currentUser = loggedInUser
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "LoggedInMsg", object: nil))
        }) { (error) in
            print("Log In Error \(error)")
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "LoggedInErrorMsg", object: nil))
        }
    }
    
    func logoutUser() {
        backendless.userService.logout({ (response) in
            print("Logged Out")
        }) { (error) in
            print("Log Out Error \(error)")
        }
    }
    
}
