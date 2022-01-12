//
//  AppDelegate.swift
//  WEGExtensionApp
//
//  Created by Yogesh Singh on 04/12/18.
//  Copyright © 2018 Yogesh Singh. All rights reserved.
//

import UIKit
import WebEngage
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        addCustomPushCategory()
        
        WebEngage.sharedInstance()?.application(application, didFinishLaunchingWithOptions: launchOptions, autoRegister: true)
        WebEngage.sharedInstance().user.login("ExtensionQWE1")
        return true
    }
    
    private func addCustomPushCategory() {
        let category = UNNotificationCategory.init(identifier: "BIG_PICTURE", actions: [], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}
