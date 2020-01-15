platform :ios, '9.0'
source 'https://github.com/CocoaPods/Specs.git'
inhibit_all_warnings!
use_frameworks!

target 'Prana' do
  # Firebase
    pod 'Fabric', '~> 1.10.1'
    pod 'Crashlytics', '~> 3.13.1'
    pod 'Firebase/Core'
  # Networking
    pod 'Alamofire', '~> 4.0'
  # Model
    pod 'SwiftyJSON', '~> 4.0'
    pod 'ObjectMapper', '~> 3.4'
    pod 'DateToolsSwift'
  # UI
    pod 'IQKeyboardManagerSwift'
    pod 'MKProgress', '~> 1.0.9'
    pod 'Toaster'
    pod 'DropDown'
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings.delete('CODE_SIGNING_ALLOWED')
    config.build_settings.delete('CODE_SIGNING_REQUIRED')
  end
end
