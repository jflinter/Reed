//
//  AppDelegate.swift
//  Reed
//
//  Created by Jack Flintermann on 12/24/15.
//  Copyright © 2015 jflinter. All rights reserved.
//

import UIKit
import ReedCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.ExtraLight))

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        application.setMinimumBackgroundFetchInterval(NSTimeInterval(86400))
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert, categories: nil))
        self.window?.tintColor = UIColor(red: 255.0/255.0, green: 42.0/255.0, blue: 104.0/255.0, alpha: 1)
        visualEffectView.frame = application.statusBarFrame
        self.window?.rootViewController?.view?.addSubview(visualEffectView)
        return true
    }
    
    func application(application: UIApplication, willChangeStatusBarFrame newStatusBarFrame: CGRect) {
        self.visualEffectView.frame = newStatusBarFrame
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        FirebaseStore.fetchNewStoriesForUser(User.activeUser) { stories in
            if stories.count > 0 {
                let notification = UILocalNotification()
                let plural = stories.count == 1 ? "story" : "stories"
                notification.alertBody = "\(stories.count) new \(plural)!"
                application.presentLocalNotificationNow(notification)
                completionHandler(UIBackgroundFetchResult.NewData)
            } else {
                completionHandler(UIBackgroundFetchResult.NoData)
            }
        }
    }
    
    func application(application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }

}

