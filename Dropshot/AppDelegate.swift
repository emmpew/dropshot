//
//  AppDelegate.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/11/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit
import UserNotifications
import SwiftyJSON

let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

// colors
let colorMellowBlue = UIColor(red: 76.0/255.0, green: 207.0/255.0, blue: 229.0/255.0, alpha: 1.0)
let colorSmoothRed = UIColor(red: 255.0/255.0, green: 75.0/255.0, blue: 100.0/255.0, alpha: 1.0)
let colorRemBlue = UIColor(red: 76.0/255.0, green: 191.0/255.0, blue: 211.0/255.0, alpha: 1.0)
let colorPurpleHaze = UIColor(red: 230.0/255.0, green: 105.0/255.0, blue: 255.0/255.0, alpha: 1.0)
let fontSize12 = UIScreen.main.bounds.width / 31
let fontSize17 = UIScreen.main.bounds.width / 18

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        application.isStatusBarHidden = true
        checkIfUserExists()
        
        let pageController = UIPageControl.appearance()
        pageController.pageIndicatorTintColor = .darkGray
        pageController.currentPageIndicatorTintColor = colorRemBlue
        pageController.backgroundColor = .white
        
        registerForRemoteNotification()
        ExpireWatcher.deleteFileIfOld()
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        LocManager.sharedInstance.stopUpdatingLocation()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        LocManager.sharedInstance.startUpdatingLocationWith(type: Authorization.WhenInUseAuthorization)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        ExpireWatcher.deleteFiles()
        UserDefaults.standard.removeObject(forKey: "failedDrop")
    }
    
    // MARK: Functions
    
    func registerForRemoteNotification() {
        if !UIApplication.shared.isRegisteredForRemoteNotifications {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            UIApplication.shared.registerForRemoteNotifications()
            
        }
    }
    
    func showInitialPNScreen() {
        UserInfo.totalBadgeCount = UIApplication.shared.applicationIconBadgeNumber
        if let visibleViewController = window?.rootViewController {
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "ProfileVC")
            visibleViewController.present(initialViewController, animated: true, completion: nil)
        }
    }
    
    func checkIfUserExists() {
        let defaults = UserDefaults.standard
        let token = defaults.value(forKey: "token")
        if token == nil {
            //
        } else {
            UserInfo.totalBadgeCount = UIApplication.shared.applicationIconBadgeNumber
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "MainVC") as! MainVC
            let nav: UINavigationController = UINavigationController(rootViewController: mainVC)
            nav.navigationBar.isHidden = true
            self.window?.rootViewController = nav
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        if let _ = UserDefaults.standard.value(forKey: "deviceToken") {
            //
        } else {
            //agregr call cuando el usuario cambie
            UserInfo.deviceToken = deviceTokenString
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        if let rootView = window?.rootViewController {
            rootView.alertView(message: "Unable to register Push Notification", window: appDelegate.window!, color: colorSmoothRed, delay: 3)
        }
    }
    
    // MARK: - NOTIFICATION DELEGATES >= iOS 10
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        UserInfo.totalBadgeCount = UIApplication.shared.applicationIconBadgeNumber
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
        UserInfo.totalBadgeCount = UIApplication.shared.applicationIconBadgeNumber
        
        let a = response.notification.request.content.userInfo
        if !a.isEmpty {
            showInitialPNScreen()
        }
        completionHandler()
    }
}

