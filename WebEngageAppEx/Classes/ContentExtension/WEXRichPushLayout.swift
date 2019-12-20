//
//  WEXRichPushLayout.swift
//  ContentExtension
//
//  Created by Yogesh Singh on 20/12/19.
//  Copyright © 2019 Yogesh Singh. All rights reserved.
//

import UIKit

class WEXRichPushLayout: NSObject, UNNotificationContentExtension {
    
    var controller: WEXRichPushNotificationViewController?
    var view: UIView?
    
    init(with controller: WEXRichPushNotificationViewController) {
        
        self.controller = controller
        self.view = controller.view
    }
    
    func didReceive(_ notification: UNNotification) {
        
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        
    }
}
