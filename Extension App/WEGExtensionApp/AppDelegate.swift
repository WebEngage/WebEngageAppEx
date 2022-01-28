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
        WebEngage.sharedInstance()?.application(application, didFinishLaunchingWithOptions: launchOptions, autoRegister: true)
        WebEngage.sharedInstance().user.login("ExtensionQWE1")
        return true
    }
}
