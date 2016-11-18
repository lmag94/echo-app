//
//  AppDelegate.swift
//  Echo
//
//  Created by Luis Mariano Arobes on 20/09/16.
//  Copyright © 2016 Luis Mariano Arobes. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UINavigationBar.appearance().barTintColor = Color.primaryColor
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        _ = Pushbots(appId: PushbotsConstants.applicationId, prompt: true)
        
        setupLocationManager()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("didRegisterForRemoteNotificationsWithDeviceToken")
        
        Pushbots.sharedInstance().register(onPushbots: deviceToken)
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        //Track notification only if the application opened from Background by clicking on the notification.
        if application.applicationState == .inactive  {
            Pushbots.sharedInstance().trackPushNotificationOpened(withPayload: userInfo);
        }
        
        //The application was already active when the user got the notification, just show an alert.
        //That should *not* be considered open from Push.
        if application.applicationState == .active  {
            //Capture notification data e.g. badge, alert and sound
            if let aps = userInfo["aps"] as? NSDictionary {
                let alert_message = aps["alert"] as! String
                let alert = UIAlertController(title: "Alert!",
                                              message: alert_message,
                                              preferredStyle: .alert)
                let defaultButton = UIAlertAction(title: "OK",
                                                  style: .default) {(_) in
                                                    // your defaultButton action goes here
                }
                
                alert.addAction(defaultButton)
                self.window?.rootViewController?.present(alert, animated: true) {
                    // completion goes here
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Notification Registration Error \(error)")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate: CLLocationManagerDelegate {
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest        
        locationManager.requestAlwaysAuthorization()
    }
}

