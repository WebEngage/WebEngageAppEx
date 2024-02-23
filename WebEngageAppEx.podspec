Pod::Spec.new do |spec|
  spec.name             = 'WebEngageAppEx'
  spec.version          = '1.1.1'
  spec.summary          = 'App Extension Target SDK for WebEngage for Rich Push Notifications support.'

  spec.description      = <<-DESC
  This pod includes various subspecs which are intended for use in Application Extensions, and depends on APIs which are App Extension Safe. The Core subspecs provides APIs which lets you track Users and Events from within Application Extensions.
  DESC

  spec.license           = 'MIT'
  spec.author            = 'Saumitra Bhave', 'Uzma Sayyed', 'Unmesh Rathod', 'Bhavesh Sarwar'
  spec.homepage          = 'https://webengage.com'
  spec.social_media_url  = 'http://twitter.com/webengage'
  spec.documentation_url = 'https://docs.webengage.com/docs/ios-getting-started'
  spec.source            = { :git => 'https://github.com/WebEngage/WebEngageAppEx.git', :tag => spec.version.to_s }
  spec.platform          = :ios
  spec.swift_version = '5.0'
  spec.ios.deployment_target = '10.0'
  spec.static_framework  = true

  spec.subspec 'CoreApi' do |api|
    api.source_files = 'WebEngageAppEx/Classes/CoreApi/**/*.{h,m,swift}'
    api.public_header_files = 'WebEngageAppEx/Classes/CoreApi/WebEngageAppEx.h','WebEngageAppEx/Classes/CoreApi/WEXAnalytics.h', 'WebEngageAppEx/Classes/CoreApi/WEXUser.h'
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
    cs.source_files = 'WebEngageAppEx/Classes/ContentExtension/**/*.{h,m,swift,rb}'
    cs.public_header_files = 'WebEngageAppEx/Classes/ContentExtension/WEXRichPushNotificationViewController.h','WebEngageAppEx/Classes/ContentExtension/WEXRichPushLayout.h','WebEngageAppEx/Classes/ContentExtension/WEXRichPushNotificationViewController+Private.h','WebEngageAppEx/Classes/ContentExtension/UIImage+animatedGIF.h'
    cs.frameworks = 'Foundation'
    cs.weak_frameworks = 'UserNotifications', 'UserNotificationsUI'
    cs.dependency 'WebEngageAppEx/CoreApi'

    cs.script_phase = {
      :name => 'Modify Build Setting',
      :script => <<-SCRIPT,
project_path="Pods.xcodeproj"
                    target_name="WebEngageAppEx"
                    build_setting="SWIFT_INSTALL_OBJC_HEADER"
                    build_setting_value="NO"
                    ruby -r 'xcodeproj' -e "
                      project = Xcodeproj::Project.open('$project_path')
                      target = project.targets.find { |t| t.name == '$target_name' }
                      if target
                        target.build_configurations.each do |config|
                        puts config.build_settings['$build_setting']
                        current_setting = config.build_settings['$build_setting']
                        
                            if current_setting && current_setting != 'YES'
                              puts 'Skip Modifying SWIFT_INSTALL_OBJC_HEADER'
                            else
                                config.build_settings['$build_setting'] = '$build_setting_value'
                                puts 'Modified SWIFT_INSTALL_OBJC_HEADER set to NO'
                                project.save
                            end
                        end
                        
                      else
                        puts 'Target $target_name not found in the project.'
                      end
                    "
                    SCRIPT
      :execution_position => :before_compile
    }
  end
end
