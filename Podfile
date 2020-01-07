platform :ios, '9.0'
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

target 'Prana' do
    pod 'Fabric', '~> 1.10.1'
    pod 'Crashlytics', '~> 3.13.1'
    pod 'Alamofire', '~> 4.0'
    pod 'SwiftyJSON', '~> 4.0'
    pod 'IQKeyboardManagerSwift'
    pod 'Macaw', '~> 0.9.5'
    pod 'MKProgress', '~> 1.0.9'
    pod 'Toaster'
    
    pod 'Firebase/Core'
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings.delete('CODE_SIGNING_ALLOWED')
    config.build_settings.delete('CODE_SIGNING_REQUIRED')
  end
end
