//
//  WEXRatingPushNotificationViewController.swift
//  ContentExtension
//
//  Created by Yogesh Singh on 20/12/19.
//  Copyright © 2019 Yogesh Singh. All rights reserved.
//

import UIKit
import UserNotificationsUI

class WEXRatingPushNotificationViewController: UIViewController {

    
    // MARK: - View Helpers
    
}


// MARK: - Content Extension Delegates

extension WEXRatingPushNotificationViewController: UNNotificationContentExtension {
    
    func didReceive(_ notification: UNNotification) {
        
    }
    
    func didReceive(_ response: UNNotificationResponse,
                    completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        
    }
}
