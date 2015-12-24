//
//  TZLogInViewController.swift
//  transients
//
//  Created by Johann Diedrick on 12/23/15.
//  Copyright © 2015 Johann Diedrick. All rights reserved.
//

import Foundation
import UIKit
import Parse

class TZLoginViewController : UIViewController{
    
    var login_button:UIButton?
    var usernameField:UITextField?
    var passwordField:UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = Constants.Colors.backgroundColor
        
        
        login_button = UIButton(frame: CGRectMake(100,
            100,
            100,
            100))
        login_button?.backgroundColor = Constants.Colors.box2Color
        login_button?.tintColor = Constants.Colors.textColor
        login_button?.setTitle("Login", forState: UIControlState.Normal)
        login_button?.addTarget(self, action: "loginAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(login_button!)
        
        usernameField = UITextField(frame: CGRectMake(100, 200, 400, 100))
        usernameField?.backgroundColor = Constants.Colors.box1Color
        usernameField?.textColor = Constants.Colors.text2Color
        usernameField?.attributedPlaceholder = NSAttributedString(string:"username",
            attributes:[NSForegroundColorAttributeName: Constants.Colors.text2Color])
        self.view.addSubview(usernameField!)
        
        
        passwordField = UITextField(frame: CGRectMake(100, 300, 400, 100))
        passwordField?.backgroundColor = Constants.Colors.box1Color
        passwordField?.textColor = Constants.Colors.text2Color
        passwordField?.secureTextEntry = true
        passwordField?.attributedPlaceholder = NSAttributedString(string:"password",
            attributes:[NSForegroundColorAttributeName: Constants.Colors.text2Color])
        self.view.addSubview(passwordField!)
        
    }
    
    func loginAction(sender: AnyObject) {
        let username = self.usernameField!.text
        let password = self.passwordField!.text
        
        // Validate the text fields
        if username?.characters.count < 5 {
            var alert = UIAlertView(title: "Invalid", message: "Username must be greater than 5 characters", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            
        } else if password?.characters.count < 8 {
            var alert = UIAlertView(title: "Invalid", message: "Password must be greater than 8 characters", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            
        } else {
            // Run a spinner to show a task in progress
            var spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            // Send a request to login
            PFUser.logInWithUsernameInBackground(username!, password: password!, block: { (user, error) -> Void in
                
                // Stop the spinner
                spinner.stopAnimating()
                
                if ((user) != nil) {
                    var alert = UIAlertView(title: "Success", message: "Logged In", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        var tabBarController = UITabBarController()
                        
                        let rvc = TZRecorderViewController(nibName: nil, bundle: nil)
                        
                        let mvc = TZMapViewController(nibName: nil, bundle: nil)
                        let controllers = [rvc, mvc]
                        
                        tabBarController.viewControllers = controllers
                        
                        //   window.rootViewController = tabBarController
                        
                        tabBarController.tabBar.tintColor = Constants.Colors.textColor
                        tabBarController.tabBar.barTintColor = Constants.Colors.backgroundColor
                        
                        rvc.tabBarItem = UITabBarItem(title: "Record", image: nil, tag: 1)
                        mvc.tabBarItem = UITabBarItem(title: "Map", image: nil, tag: 2)
                        
                        self.presentViewController(tabBarController, animated: true, completion: nil)
                    })
                    
                } else {
                    var alert = UIAlertView(title: "Error", message: "\(error)", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                }
            })
        }
    }
    
}