# Run the following command to validate this podspec:
#   $ pod lib lint --no-clean --allow-warnings --use-libraries
#
# Run the following command to publish the podspec:
#   $ pod trunk push IgniteEngine.podspec --allow-warnings --use-libraries
#
# Problems? Use the --verbose flag
# podspec version: 0002

Pod::Spec.new do |spec|
    spec.name                  = 'IgniteEngine'
    spec.version               = '0.1.1'
    spec.summary               = 'A platform for rapidly building native mobile applications using declarative JSON.'
    spec.description           = <<-DESC
                                  The Ignite Engine is a platform for rapidly building native mobile apps using declarative JSON to build views, controllers, and logic. The stability and robustness of the engine frees you to focus on the functionality and design of your app.
                                  DESC
    spec.homepage              = 'https://github.com/apigee/IgniteEngine-iOS'
    spec.license               = 'MIT'
    spec.authors               = {
                                  'Robert Walsh' => 'rwalsh@apigee.com',
                                  'Brandon Shelley' => 'brandon@apigee.com',
                                  'Jeremy Anticouni' => 'jeremy@apigee.com'
                                }
    spec.source                = { :git => 'https://github.com/apigee/IgniteEngine-iOS.git', :branch => 'master', :tag => spec.version.to_s }
    spec.platform              = :ios, '8.0'
    spec.requires_arc          = true  
    spec.preserve_paths        = 'Classes/**'
    spec.source_files          = 'Classes/**/*.{h,m}'
    spec.exclude_files         = 'Example'

    spec.ios.deployment_target = '8.0'
    spec.documentation_url     = 'https://ignite.apigee.com'

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
end
