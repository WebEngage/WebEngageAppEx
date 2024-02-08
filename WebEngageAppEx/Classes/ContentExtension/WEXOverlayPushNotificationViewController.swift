//
//  WEXOverlayPushNotificationViewController.swift
//
//
//  Created by Uday Sharma on 03/11/23.
//
import UIKit
import UserNotifications
import UserNotificationsUI


@objcMembers
@objc public class WEXOverlayPushNotificationViewController: WEXRichPushLayout {

    var notification: UNNotification?

   func didReceiveNotification(_ notification: UNNotification) {
        if let source = notification.request.content.userInfo[WEConstants.SOURCE] as? String, source == WEConstants.WEBENGAGE {
            self.notification = notification
            initialiseViewHierarchy()
        }
    }

    func didReceiveNotificationResponse(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        if let source = response.notification.request.content.userInfo[WEConstants.SOURCE] as? String, source == WEConstants.WEBENGAGE {
            completion(.dismissAndForwardAction)
        }
    }

    /// Initializes the view hierarchy by setting the background color (if available) and adding a wrapper view and rich content labels container.
    func initialiseViewHierarchy() {
        if #available(iOS 13.0, *) {
            view?.backgroundColor = UIColor.clear
        }
        
        let superViewWrapper = UIView()
        view?.addSubview(superViewWrapper)
        
        let mainContentView = UIView()
        superViewWrapper.addSubview(mainContentView)
        
        setupBannerImageView()
    }

}

struct WEConstants{
    static let SOURCE = "source"
    static let EXPANDABLEDETAILS = "expandableDetails"
    static let BLACKCOLOR = "bckColor"
    static let WEBENGAGE = "webengage"
    static let RICHSUBTITLE = "rst"
    static let RICHMESSAGE = "rm"
    static let RICHTITLE = "rt"
    static let CONTENT_PADDING: CGFloat = 10.0
    static let LANDSCAPE_ASPECT: Float = 0.5
}
