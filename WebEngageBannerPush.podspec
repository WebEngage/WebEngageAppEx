Pod::Spec.new do |spec|

  spec.name             = 'WebEngageBannerPush'
  spec.version          = '1.3.2'
  spec.summary          = 'Extension Target SDK for adding WebEngage Rich Push Notifications support'

  spec.description      = <<-DESC
  This pod contains reference implentation of iOS Notification Service Extension. Clients are expected to pull this dependency and extend their Root Notification Service class with the one provided in this pod.
  DESC

  spec.license            = 'MIT'
  spec.author             = 'Saumitra Bhave', 'Uzma Sayyed', 'Unmesh Rathod', 'Bhavesh Sarwar'
  spec.homepage           = 'https://webengage.com'
  spec.social_media_url   = 'http://twitter.com/webengage'
  spec.documentation_url  = 'https://docs.webengage.com/docs/ios-getting-started'
  spec.source             = { :git => 'https://github.com/WebEngage/WebEngageAppEx.git', :tag => spec.version.to_s }
  spec.platform           = :ios
  spec.ios.deployment_target = '10.0'

  spec.source_files         = 'WebEngageAppEx/Classes/ServiceExtension/*.{h,m}'
  spec.public_header_files  = 'WebEngageAppEx/Classes/ServiceExtension/*.h'
  spec.frameworks           = 'Foundation', 'UIKit'
  spec.weak_frameworks      = 'UserNotifications'
  spec.resource_bundles = { 'WebEngageBannerPush' => 'WebEngageAppEx/Classes/ServiceExtension/*.{xcprivacy}' }
end
