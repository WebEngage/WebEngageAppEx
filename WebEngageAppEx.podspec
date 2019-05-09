
Pod::Spec.new do |s|

  s.name             = 'WebEngageAppEx'
  s.version          = '0.3.0'
  s.summary          = 'Extension For Using WebEngage APIs from Application Extensions'

  s.description      = <<-DESC
  This pod includes various subspecs which are intended for use in Application Extensions, and depends on APIs which are App Extension Safe. The Core subspecs provides APIs which lets you track Users and Events from within Application Extensions.
  DESC

  s.homepage         = 'https://github.com/WebEngage/WebEngageAppEx'
  s.license          = { :type => 'OTHER', :file => 'LICENSE' }
  s.author           = { "Saumitra R. Bhave" => "saumitra@webklipper.com",
                         "Yogesh Singh" => "yogesh.singh@webklipper.com" }
  s.social_media_url = "http://twitter.com/webengage"
  s.source           = { :git => 'https://github.com/WebEngage/WebEngageAppEx.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.subspec 'CoreApi' do |api|
    api.source_files = 'WebEngageAppEx/Classes/CoreApi/**/*.{h,m}'
    api.public_header_files = 'WebEngageAppEx/Classes/CoreApi/WEXAnalytics.h', 'WebEngageAppEx/Classes/CoreApi/WEXUser.h'
    api.frameworks = 'Foundation'
  end

  s.subspec 'NotificationService' do |ns|
    ns.source_files = 'WebEngageAppEx/Classes/NotificationService/WEXPushNotificationService.{h,m}'
    ns.public_header_files = 'WebEngageAppEx/Classes/NotificationService/WEXPushNotificationService.h'
    ns.frameworks = 'Foundation'
    ns.weak_frameworks = 'UserNotifications'
  end

  s.subspec 'ContentExtension' do |cs|
    cs.source_files = 'WebEngageAppEx/Classes/ContentExtension/**/*.{h,m}'
    cs.public_header_files = 'WebEngageAppEx/Classes/ContentExtension/WEXRichPushNotificationViewController.h'
    cs.frameworks = 'Foundation'
    cs.weak_frameworks = 'UserNotifications', 'UserNotificationsUI'
    cs.dependency 'WebEngageAppEx/CoreApi'
  end

end
