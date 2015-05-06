#
# Be sure to run `pod lib lint IgniteEngine.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |spec|
  spec.name               = 'IgniteEngine'
  spec.version            = '0.1.0'
  spec.summary            = 'A framework for rapidly building native mobile applications using declarative JSON.'
  spec.description        = <<-DESC
                           The Ignite Engine is a framework for rapidly building native mobile applications using declarative JSON to build app views, controllers, and logic. This approach ensures consistent, reliable, and reusable code is written at the engine layer, leaving the developer free to focus on form, function, and design.
                           DESC
  spec.homepage           = 'https://github.com/apigee/IgniteEngine-iOS'
  spec.license            = 'MIT'
  spec.authors            = {
                          'Robert Walsh' => 'rwalsh@apigee.com',
                          'Brandon Shelley' => 'brandon@apigee.com',
                          'Jeremy Anticouni' => 'jeremy@apigee.com'
                          }
  spec.source             = { :git => 'https://github.com/apigee/IgniteEngine-iOS.git', :branch => 'master', :tag => spec.version.to_s }

  spec.platform           = :ios, '8.0'
  spec.requires_arc       = true  
  spec.preserve_paths     = 'Classes/**'
  spec.source_files       = 'Classes/**/*.{h,m}'


  spec.dependency 'ActionSheetPicker-3.0','~>1.6'
  spec.dependency 'AFNetworking','~>2.5'
  spec.dependency 'AFNetworkActivityLogger','~>2.0'
  spec.dependency 'AFOAuth2Manager','~>2.2'
  spec.dependency 'ALMoviePlayerController','~>0.3'
  spec.dependency 'ApigeeiOSSDK','~>2.0'
  spec.dependency 'APParallaxHeader-Width','~>0.1'
  spec.dependency 'CocoaLumberjack','~>2.0'
  spec.dependency 'Color-Picker-for-iOS','~>2.0'
  spec.dependency 'ColorUtils','~>1.1'
  spec.dependency 'IQKeyboardManager','~>3.2'
  spec.dependency 'JAFontAwesome','~>4.3'
  spec.dependency 'jetfire','~>0.1'
  spec.dependency 'MMDrawerController','~>0.6'
  spec.dependency 'Reachability','~>3.2'
  spec.dependency 'SDWebImage','~>3.7'
  spec.dependency 'SVPulsingAnnotationView','~>0.3'
  spec.dependency 'SVWebViewController','~>1.0'
  spec.dependency 'TTTAttributedLabel', '~> 1.13'
  spec.dependency 'YLMoment', '~> 0.5'
  spec.dependency 'ZBarSDK', '~> 1.3'
  spec.dependency 'ZipArchive', '~> 1.4'

  #spec.frameworks            = "ApigeeiOSSDK"
  #spec.vendored_frameworks   = "Frameworks/ApigeeiOSSDK.framework" 

end
