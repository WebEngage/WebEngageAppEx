//
//  NotificationService.swift
//  ServiceExtension
//
//  Created by Yogesh Singh on 20/03/19.
//  Copyright © 2019 Yogesh Singh. All rights reserved.
//

import UserNotifications

class NotificationService: WEXPushNotificationService { 
    
    
    override func onRequest(_ request: URLRequest!, completionHandler: ((URLRequest?) -> Void)!) {
        
        print("NI : request intercepted")
        completionHandler(request)
    }
    
}
