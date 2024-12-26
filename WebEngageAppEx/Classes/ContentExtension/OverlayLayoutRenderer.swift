//
//  OverlayLayoutRenderer.swift
//
//
//  Created by Uday Sharma on 13/11/23.
//

import Foundation
import UIKit


extension WEXOverlayPushNotificationViewController{
    
    /// Sets up the banner image view within the main content view based on expandable details of the notification.
    public func setupBannerImageView() {
        guard let superViewWrapper = view?.subviews.first, let mainContentView = superViewWrapper.subviews.first else {
            return
        }
        
        if let expandableDetails = notification?.request.content.userInfo[WEConstants.EXPANDABLEDETAILS] as? [String: Any] {
            let imageView = UIImageView()
            if expandableDetails["image"] is String {
                if let attachments = self.notification?.request.content.attachments, attachments.count > 0 {
                        if let attachment = attachments.first,
                           attachment.url.startAccessingSecurityScopedResource() {
                            
                            do {
                                let imageData = try Data(contentsOf: attachment.url)
                                if let image = UIImage.animatedImage(withAnimatedGIFData: imageData) {
                                    imageView.image = image
                                } else {
                                    print("Image not present in cache!")
                                }
                            } catch {
                                print("Error loading image data: \(error)")
                            }
                            
                            attachment.url.stopAccessingSecurityScopedResource()
                        }
                }
            } else {
                print("Image not present in payload: \(expandableDetails["image"] ?? "")")
            }

            imageView.contentMode = .scaleAspectFill
            mainContentView.addSubview(imageView)
            setupLabelsContainer()
        } else {
            print("Image not present in payload: \(String(describing: notification?.request.content.userInfo[WEConstants.EXPANDABLEDETAILS]))")
        }
    }

    /// Sets up the container for rich content labels based on the expandable details of the notification.
    public func setupLabelsContainer() {
        if let superViewWrapper = view?.subviews.first,
           let expandableDetails = notification?.request.content.userInfo[WEConstants.EXPANDABLEDETAILS] as? [String: Any], let colorHex = expandableDetails[WEConstants.BLACKCOLOR] as? String{
            let richContentView = UIView()
            if #available(iOS 13.0, *) {
                richContentView.backgroundColor = UIColor.clear
            }

            if let expandedDetails = notification?.request.content.userInfo[WEConstants.EXPANDABLEDETAILS] as? [String: Any]{
                let title = expandedDetails[WEConstants.RICHTITLE] as? String
                let subtitle = expandedDetails[WEConstants.RICHSUBTITLE] as? String
                let message = expandedDetails[WEConstants.RICHMESSAGE] as? String
                var titlePresent = title != ""
                var subTitlePresent = subtitle != ""
                var messagePresent = message != ""

                if !titlePresent {
                    titlePresent = notification?.request.content.title != ""
                }
                if !subTitlePresent {
                    subTitlePresent = notification?.request.content.subtitle != ""
                }
                if !messagePresent {
                    messagePresent = notification?.request.content.body != ""
                }
                let richTitleLabel = UILabel()
                if let viewController = viewController, let title = title {
                    richTitleLabel.attributedText = viewController.getHtmlParsedString(title, isTitle: true, bckColor: colorHex)
                    richTitleLabel.textAlignment = viewController.naturalTextAlignment(forText: richTitleLabel.text)
                }

                let richSubLabel = UILabel()
                if let viewController = viewController, let subtitle = subtitle {
                    richSubLabel.attributedText = viewController.getHtmlParsedString(subtitle, isTitle: true, bckColor: colorHex)
                    richSubLabel.textAlignment = viewController.naturalTextAlignment(forText: richSubLabel.text)
                }

                let richBodyLabel = UILabel()
                if let viewController = viewController, let message = message {
                    var utils = WEXUtils()
                    richBodyLabel.attributedText = utils.getAttributedString(message: message, colorHex: colorHex, viewController: viewController)
                }
                richBodyLabel.numberOfLines = 0


                richContentView.addSubview(richTitleLabel)
                richContentView.addSubview(richSubLabel)
                richContentView.addSubview(richBodyLabel)

                superViewWrapper.addSubview(richContentView)
                setupConstraints()
            }
        }
    }

    /// Sets up layout constraints for the rich content labels container and its child labels.
    public func setupConstraints() {
        if let view = view, let superViewWrapper = view.subviews.first, let mainContentView = superViewWrapper.subviews.first, let richContentView = superViewWrapper.subviews.last {
            superViewWrapper.translatesAutoresizingMaskIntoConstraints = false
            superViewWrapper.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            superViewWrapper.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            superViewWrapper.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            superViewWrapper.bottomAnchor.constraint(equalTo: richContentView.bottomAnchor).isActive = true
            
            mainContentView.translatesAutoresizingMaskIntoConstraints = false
            mainContentView.leadingAnchor.constraint(equalTo: mainContentView.superview!.leadingAnchor).isActive = true
            mainContentView.trailingAnchor.constraint(equalTo: mainContentView.superview!.trailingAnchor).isActive = true
            mainContentView.topAnchor.constraint(equalTo: mainContentView.superview!.topAnchor).isActive = true
            
            richContentView.translatesAutoresizingMaskIntoConstraints = false
            richContentView.leadingAnchor.constraint(equalTo: richContentView.superview!.leadingAnchor).isActive = true
            richContentView.trailingAnchor.constraint(equalTo: richContentView.superview!.trailingAnchor).isActive = true
            richContentView.topAnchor.constraint(equalTo: mainContentView.bottomAnchor).isActive = true
            
            viewController?.view.bottomAnchor.constraint(equalTo: superViewWrapper.bottomAnchor).isActive = true
            
            if let imageView = mainContentView.subviews.first as? UIImageView {
                imageView.translatesAutoresizingMaskIntoConstraints = false
                if let bannerImage = imageView.image {
                    var imageAspect: CGFloat = CGFloat(WEConstants.LANDSCAPE_ASPECT)
                    if bannerImage.size.height != 0 {
                        imageAspect = bannerImage.size.height / bannerImage.size.width
                        if imageAspect > 1{
                            imageAspect = 1
                        }
                    }
                    
                    imageView.topAnchor.constraint(equalTo: superViewWrapper.topAnchor).isActive = true
                    imageView.leadingAnchor.constraint(equalTo: superViewWrapper.leadingAnchor).isActive = true
                    imageView.trailingAnchor.constraint(equalTo: superViewWrapper.trailingAnchor).isActive = true
                    imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: imageAspect).isActive = true
                    superViewWrapper.bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
                }
                
                if let richTitleLabel = richContentView.subviews[0] as? UILabel, let richSubTitleLabel = richContentView.subviews[1] as? UILabel, let richBodyLabel = richContentView.subviews[2] as? UILabel {
                    richTitleLabel.translatesAutoresizingMaskIntoConstraints = false
                    richTitleLabel.leadingAnchor.constraint(equalTo: richContentView.leadingAnchor, constant: WEConstants.CONTENT_PADDING).isActive = true
                    richTitleLabel.trailingAnchor.constraint(equalTo: richContentView.trailingAnchor, constant: 0 - WEConstants.CONTENT_PADDING).isActive = true
                    richTitleLabel.topAnchor.constraint(equalTo: richContentView.topAnchor, constant: WEConstants.CONTENT_PADDING).isActive = true
                    
                    richSubTitleLabel.translatesAutoresizingMaskIntoConstraints = false
                    richSubTitleLabel.leadingAnchor.constraint(equalTo: richContentView.leadingAnchor, constant: WEConstants.CONTENT_PADDING).isActive = true
                    richSubTitleLabel.trailingAnchor.constraint(equalTo: richContentView.trailingAnchor, constant: 0 - WEConstants.CONTENT_PADDING).isActive = true
                    richSubTitleLabel.topAnchor.constraint(equalTo: richTitleLabel.bottomAnchor).isActive = true
                    
                    richBodyLabel.translatesAutoresizingMaskIntoConstraints = false
                    richBodyLabel.leadingAnchor.constraint(equalTo: richContentView.leadingAnchor, constant: WEConstants.CONTENT_PADDING).isActive = true
                    richBodyLabel.trailingAnchor.constraint(equalTo: richContentView.trailingAnchor, constant: 0 - WEConstants.CONTENT_PADDING).isActive = true
                    richBodyLabel.topAnchor.constraint(equalTo: richSubTitleLabel.bottomAnchor).isActive = true
                    richBodyLabel.bottomAnchor.constraint(equalTo: richContentView.bottomAnchor, constant: -WEConstants.CONTENT_PADDING).isActive = true
                }
            } else {
                print("Expected to be running iOS version 10 or above")
            }
        }
    }
}
