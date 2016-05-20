//
//  AppDelegate.swift
//  ServerTemp
//
//  Created by BdevNameless on 01.12.15.
//  Copyright © 2015 Nikita Karaulov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    //MARK: - Delegate Methods

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if isFirstRun() {
            handleFirstRun()
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        print("applicationWillResignActive")        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        tunnelDown()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        print("applicationDidEnterBackground")
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        print("applicationWillEnterForeground")
        tunnelDown()
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        print("applicationDidBecomeActive")
        tunnelUp()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        print("applicationWillTerminate")
        tunnelDown()
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //MARK: - Private Methods
    
    private func isFirstRun() -> Bool {
        return !NSUserDefaults.standardUserDefaults().boolForKey("firstRun")
    }
    
    private func updateFirstRunFlag() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "firstRun")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    private func handleFirstRun() {
        flushKeychain()
        updateFirstRunFlag()
    }
    
    private func flushKeychain() {
        let query: [NSObject: AnyObject] = [kSecClass: kSecClassGenericPassword]
        SecItemDelete(query as CFDictionaryRef)
    }
    
    private func tunnelUp() {
//        let config = VPNConfiguration()
//        config.loadConfigugarion() { (loadError: NSError?) in
//            if loadError == nil {
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1*Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
//                    try! config.startVPN()
//                }
//            }
//        }
    }
    
    private func tunnelDown() {
        let config = VPNConfiguration()
        config.stopVPN()
    }

}

