Pod::Spec.new do |s|
s.name             = 'WebEngageBannerPush'
s.version          = '0.4.0'
s.summary          = 'Extension For Using WebEngage Banner or Attachment Based Notifications'

s.description      = <<-DESC
This is Small Pod which contains the reference implentation of iOS Notification Service Extension, Clients can just pull this dependency and extend their Root Notification Service class with the one provided in this pod
DESC

s.homepage         = 'https://github.com/WebEngage/WebEngageAppEx'
s.license          = { :type => 'OTHER', :file => 'LICENSE' }
s.author           = { "Saumitra R. Bhave" => "saumitra@webklipper.com",
                       "Yogesh Singh" => "yogesh.singh@webklipper.com" }
s.source           = { :git => 'https://github.com/WebEngage/WebEngageAppEx.git', :tag => s.version.to_s }

s.ios.deployment_target = '10.0'
s.source_files = 'WebEngageAppEx/Classes/NotificationService/**/*.{h,m}'
s.public_header_files = 'WebEngageAppEx/Classes/NotificationService/WEXPushNotificationService.h'
s.frameworks = 'Foundation', 'UIKit'
s.weak_frameworks = 'UserNotifications'
end

end
