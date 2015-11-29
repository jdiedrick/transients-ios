//
//  AppDelegate.swift
//  transients
//
//  Created by Johann Diedrick on 6/22/15.
//  Copyright (c) 2015 Johann Diedrick. All rights reserved.
//

import UIKit
import CoreData
import Parse


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var tabBarController: UITabBarController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Parse.setApplicationId("UDy5u1gUEEqN5Z5mikZoSqNOgTXFCZAo3XsurVyZ", clientKey: "5wpVRAO3cYBVyJCEY2TAywcPbY8pV3jYNja8Os25")

        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        //println("\(UIDevice.currentDevice().identifierForVendor!.UUIDString)")
        
        let launchedBefore = true
        //= NSUserDefaults.standardUserDefaults().boolForKey("FirstLaunch")
        
        if launchedBefore  {
            print("We have launched before, Not first launch.")
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "FirstLaunch")
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            
            
            if let window = window{
                
                let tabBarController = UITabBarController()
                
                let rvc = TZRecorderViewController(nibName: nil, bundle: nil)
                
                let mvc = TZMapViewController(nibName: nil, bundle: nil)
                let controllers = [rvc, mvc]
                
                tabBarController.viewControllers = controllers
                
                window.rootViewController = tabBarController
                
                tabBarController.tabBar.tintColor = Constants.Colors.textColor
                tabBarController.tabBar.barTintColor = Constants.Colors.backgroundColor
                
                rvc.tabBarItem = UITabBarItem(title: "Record", image: nil, tag: 1)
                mvc.tabBarItem = UITabBarItem(title: "Map", image: nil, tag: 2)
                
                
                
                //these two lines are used to custom make tzdriftviewcontroller load first for testing
                //        let rootViewController : UIViewController = TZDriftViewController()
                //        window.rootViewController = rootViewController
                
                window.makeKeyAndVisible()
            }
            
            return true


        }
        else {
            print("First launch, setting NSUserDefault.")
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "FirstLaunch")
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            
            
            if let window = window{
                
                let signUpViewController = TZSignUpViewController()
                
                window.rootViewController = signUpViewController
                
                window.makeKeyAndVisible()
            }
            
            return true
        }
        
       
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
}
