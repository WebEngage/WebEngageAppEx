//
//  WEXBannerPushNotificationViewController.swift
//
//
//  Created by Shubham Naidu on 03/11/23.
//
import UIKit
import UserNotifications
import UserNotificationsUI

class WEXOverlayPushNotificationViewController: WEXRichPushLayout {

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
    static let ACTION_LINK = "actionLink"
        static let APPEX = "appex"
        static let BIG_PICTURE = "BIG_PICTURE"
        static let BIG_TEXT = "BIG_TEXT"
        static let OVERLAY = "OVERLAY"
        static let BLACKCOLOR = "bckColor"
        static let CAROUSEL = "CAROUSEL_V1"
        static let COLLAPSED = "collapsed"
        static let CONTENT_PADDING: CGFloat = 10.0
        static let CFBUNDLEIDENTIFIER = "CFBundleIdentifier"
        static let CUSTOM_DATA = "customData"
        static let EVENT_DATA_OVERRIDES = "event_data_overrides"
        static let EXPANDED = "expanded"
        static let EXPANDABLEDETAILS = "expandableDetails"
        static let EXPERIMENT_ID = "experiment_id"
        static let GROUP = "group"
        static let IMAGE = "image"
        static let ITEMS = "items"
        static let LANDSCAPE_ASPECT: Float = 0.5
        static let MODE = "mode"
        static let NOTIFICATION_ID = "notification_id"
        static let POTRAIT = "portrait"
        static let RATING = "RATING_V1"
        static let RATING_SCALE = "ratingScale"
        static let RICHSUBTITLE = "rst"
        static let RICHMESSAGE = "rm"
        static let RICHTITLE = "rt"
        static let SOURCE = "source"
        static let STYLE = "style"
        static let SUBMIT_CTA = "submitCTA"
        static let SYSTEM = "system"
        static let SYSTEM_DATA_OVERRIDES = "system_data_overrides"
        static let TITLE_BODY_SPACE = 5
        static let WENOTIFICATIONGROUP = "WEGNotificationGroup"
        static let WEBENGAGE = "webengage"
        static let WEX_APP_GROUP = "WEX_APP_GROUP"
        static let WEX_CONTENT_EXTENSION_VERSION = "1.0.2"
        static let WEX_CONTENT_EXTENSION_VERSION_STRING = "WEG_Content_Extension_Version"
        static let WHITECOLOR = "#FFFFFF"
}
