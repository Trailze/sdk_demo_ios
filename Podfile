# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'demo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

pod 'MapboxCoreNavigation', :git => 'https://github.com/Trailze/mapbox-navigation-ios.git', :tag => 'trailze-v1.0.2'
pod 'MapboxNavigation', :git => 'https://github.com/Trailze/mapbox-navigation-ios.git', :tag => 'trailze-v1.0.2'
pod 'MapboxGeocoder.swift', '~> 0.12'
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
          config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
          config.build_settings['BITCODE_GENERATION_MODE'] = 'bitcode'
      end
  end
end
