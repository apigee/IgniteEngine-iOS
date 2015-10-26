# Run the following command to validate this podspec:
#   $ pod lib lint --no-clean --allow-warnings --use-libraries
#
# Run the following command to publish the podspec:
#   $ pod trunk push IgniteEngine.podspec --allow-warnings --use-libraries
#
# Problems? Use the --verbose flag
# podspec version: 0003

Pod::Spec.new do |s|
    s.name                  = 'IgniteEngine'
    s.version               = '0.1.2'
    s.summary               = 'A platform for rapidly building native mobile applications using declarative JSON.'
    s.description           = <<-DESC
                                  The Ignite Engine is a platform for rapidly building native mobile apps using declarative JSON to build views, controllers, and logic. The stability and robustness of the engine frees you to focus on the functionality and design of your app.
                                  DESC
    s.homepage              = 'https://github.com/apigee/IgniteEngine-iOS'
    s.license               = 'MIT'
    s.authors               = {
                                  'Robert Walsh' => 'rwalsh@apigee.com',
                                  'Brandon Shelley' => 'brandon@apigee.com',
                                  'Jeremy Anticouni' => 'jeremy@apigee.com'
                              }
    s.source                = { :git => 'https://github.com/apigee/IgniteEngine-iOS.git', :branch => 'master', :tag => s.version.to_s }
    s.platform              = :ios, '8.0'
    s.requires_arc          = true  
    s.preserve_paths        = 'IgniteEngine/**'
    s.exclude_files         = 'Example'

    s.ios.deployment_target = '8.0'
    s.documentation_url     = 'https://ignite.apigee.com'

    s.xcconfig = {
        'USER_HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/Headers/Public/ApigeeiOSSDK/ApigeeiOSSDK"'
    }

    s.subspec 'Actions' do |ss|
        ss.dependency 'IgniteEngine/Core'
        ss.source_files = 'IgniteEngine/Actions/*.{h,m}'
    end

    s.subspec 'Attributes' do |ss|
        ss.dependency 'IgniteEngine/Core'
        ss.source_files = 'IgniteEngine/Attributes/*.{h,m}'
    end

    s.subspec 'Categories' do |ss|
        ss.dependency 'IgniteEngine/Core'
        ss.source_files = 'IgniteEngine/Categories/*.{h,m}'
    end

    s.subspec 'Controllers' do |ss|
        ss.dependency 'IgniteEngine/Core'
        ss.source_files = 'IgniteEngine/Controllers/*.{h,m}'
    end

    s.subspec 'Controls' do |ss|
        ss.dependency 'IgniteEngine/Core'
        ss.source_files = 'IgniteEngine/Controls/*.{h,m}'
    end

    s.subspec 'Core' do |ss|
        ss.source_files = 'IgniteEngine/Core/*.{h,m}'
    end

    s.subspec 'DataProviders' do |ss|
        ss.dependency 'IgniteEngine/Core'
        ss.source_files = 'IgniteEngine/DataProviders/*.{h,m}'
    end

    s.subspec 'Evaluations' do |ss|
        ss.dependency 'IgniteEngine/Core'
        ss.source_files = 'IgniteEngine/Evaluations/*.{h,m}'
    end

    s.subspec 'Utilities' do |ss|
        ss.dependency 'IgniteEngine/Core'
        ss.source_files = 'IgniteEngine/Utilities/*.{h,m}'
    end

    s.subspec 'Views' do |ss|
        ss.dependency 'IgniteEngine/Core'
        ss.source_files = 'IgniteEngine/Views/*.{h,m}'
    end

    s.dependency 'ActionSheetPicker-3.0','~>1.6'
    s.dependency 'AFNetworking','~>2.5'
    s.dependency 'AFNetworkActivityLogger','~>2.0'
    s.dependency 'AFOAuth2Manager','~>2.2'
    s.dependency 'ALMoviePlayerController','~>0.3'
    s.dependency 'ApigeeiOSSDK','~>2.0'
    s.dependency 'APParallaxHeader-Width','~>0.1'
    s.dependency 'CocoaLumberjack','~>2.0'
    s.dependency 'Color-Picker-for-iOS','~>2.0'
    s.dependency 'ColorUtils','~>1.1'
    s.dependency 'IQKeyboardManager','~>3.2'
    s.dependency 'JAFontAwesome','~>4.3'
    s.dependency 'jetfire','~>0.1'
    s.dependency 'MMDrawerController','~>0.6'
    s.dependency 'Reachability','~>3.2'
    s.dependency 'SDWebImage','~>3.7'
    s.dependency 'SVPulsingAnnotationView','~>0.3'
    s.dependency 'SVWebViewController','~>1.0'
    s.dependency 'TTTAttributedLabel', '~> 1.13'
    s.dependency 'YLMoment', '~> 0.5'
    s.dependency 'ZBarSDK', '~> 1.3'
    s.dependency 'ZipArchive', '~> 1.4'
end
