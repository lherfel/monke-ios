source 'https://github.com/Cocoapods/Specs'
use_frameworks!

platform :ios, '11.0'

def shared_pods
	pod 'MinterCore', :path => '../MinterCore'
	pod 'MinterMy', :path => '../MinterMy'
	pod 'MinterExplorer', :path => '../MinterExplorer'
	pod 'Alamofire', '4.7.3'
	pod 'AlamofireImage', '3.4.1'
	pod 'RxSwift', '4.3.1'
	pod 'RxDataSources', '~> 3.0'
	pod 'SwiftValidator', :git => 'https://github.com/jpotts18/SwiftValidator.git', :branch => 'master'
	pod 'TPKeyboardAvoiding', '~> 1.3'
	pod 'KeychainSwift', '12.0.0'
	#pod 'RealmSwift', '3.11.0'
	pod 'AFDateHelper', '~> 4.2.2'
	#pod 'NotificationBannerSwift', '1.8.0'
	#pod 'Fabric', '~> 1.7'
	#pod 'Crashlytics', '~> 3.10'
	pod 'ObjectMapper', '~> 3.3'
	#pod 'XLPagerTabStrip', '~> 8.0'
	pod 'ReachabilitySwift', '~> 4.3'
	pod 'GoldenKeystore', :git => 'https://github.com/sidorov-panda/GoldenKeystore'
	pod 'KeyboardKit', '2.2.0'
	pod 'PickerView'
end

target 'MinterKeyboard' do
	pod 'RxAppState', '1.2.0'
	shared_pods
end

target 'WalletKeyboard' do
	shared_pods
end