Pod::Spec.new do |spec|

  spec.name             = 'WebEngageAppEx'
  spec.version          = '1.1.1'

  spec.summary          = 'App Extension Target SDK for WebEngage for Rich Push Notifications support.'

  spec.description      = <<-DESC
  This pod includes various subspecs which are intended for use in Application Extensions, and depends on APIs which are App Extension Safe. The Core subspecs provides APIs which lets you track Users and Events from within Application Extensions.
  DESC

  spec.license            = 'MIT'
  spec.author             = 'Saumitra Bhave', 'Uzma Sayyed', 'Unmesh Rathod', 'Bhavesh Sarwar'
  spec.homepage           = 'https://webengage.com'
  spec.social_media_url   = 'http://twitter.com/webengage'
  spec.documentation_url  = 'https://docs.webengage.com/docs/ios-getting-started'
  spec.source             = { :git => 'https://github.com/WebEngage/WebEngageAppEx.git', :tag => spec.version.to_s }
  spec.platform           = :ios
  spec.ios.deployment_target = '10.0'

  spec.subspec 'CoreApi' do |api|
    api.source_files = 'WebEngageAppEx/Classes/CoreApi/**/*.{h,m}'
    api.public_header_files = 'WebEngageAppEx/Classes/CoreApi/WEXAnalytics.h', 'WebEngageAppEx/Classes/CoreApi/WEXUser.h'
    api.frameworks = 'Foundation'
  end

  spec.subspec 'NotificationService' do |ns|
    ns.source_files = 'WebEngageAppEx/Classes/NotificationService/WEXPushNotificationService.{h,m}'
    ns.public_header_files = 'WebEngageAppEx/Classes/NotificationService/WEXPushNotificationService.h'
    ns.frameworks = 'Foundation'
    ns.weak_frameworks = 'UserNotifications'
    ns.dependency 'WebEngage','>= 6.4.0'
  end

  spec.subspec 'ContentExtension' do |cs|
    cs.source_files = 'WebEngageAppEx/Classes/ContentExtension/**/*.{h,m,swift}'
    cs.public_header_files = 'WebEngageAppEx/Classes/ContentExtension/WEXRichPushNotificationViewController.h'
    cs.frameworks = 'Foundation'
    cs.weak_frameworks = 'UserNotifications', 'UserNotificationsUI'
    cs.dependency 'WebEngageAppEx/CoreApi'
    cs.pod_target_xcconfig = { 'SWIFT_OBJC_BRIDGING_HEADER' => File.join(__dir__, 'WebEngageAppEx/Classes/ContentExtension/WebEngageAppEx-Bridging-Header.h') }


  end

end
