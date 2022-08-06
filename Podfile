# Uncomment the next line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'
 platform :ios, '13'

target 'Safe Hygeine 4U' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Safe Hygeine 4U
	pod 'FirebaseAuth'
	pod 'FirebaseFirestore'
	pod 'FirebaseFirestoreSwift'
	pod 'GoogleSignIn'
 	pod 'GooglePlaces', '7.0.0'
	pod 'Cosmos', ' 23.0'
	pod 'lottie-ios'
	pod 'RSSelectionMenu'
end

post_install do |pi|
  pi.pods_project.targets.each do |t|
    t.build_configurations.each do |config|
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
    end
  end
end