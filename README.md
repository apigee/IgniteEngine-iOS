# ApigeeIgnite

[![CI Status](http://img.shields.io/travis/brandon/ApigeeIgnite.svg?style=flat)](https://travis-ci.org/brandon/ApigeeIgnite)
[![Version](https://img.shields.io/cocoapods/v/ApigeeIgnite.svg?style=flat)](http://cocoapods.org/pods/ApigeeIgnite)
[![License](https://img.shields.io/cocoapods/l/ApigeeIgnite.svg?style=flat)](http://cocoapods.org/pods/ApigeeIgnite)
[![Platform](https://img.shields.io/cocoapods/p/ApigeeIgnite.svg?style=flat)](http://cocoapods.org/pods/ApigeeIgnite)

## Usage

TODO

## Installation

ApigeeIgnite is available through [CocoaPods](http://cocoapods.org). To manually create a new project:

1. Open Xcode 6

2. Create an Single View Application

3. Remove Main.storyboard  (select it, right-click, and choose "Move to Trash")

4. Remove "Main storyboard file base name" entry from Info.plist file.

5. Delete ViewController.h and ViewController.m

6. Create an empty file named `podfile` in the root of your project folder with the following text:
    ```
    pod 'ApigeeIgnite', :path => '/local/path/to/Engine'
    ```

7. From your project directory, run `pod install`

8. Once the ApigeeIgnite pod and all dependencies have installed, open [MyProject].xcworkspace.

9. Find main.m

    1. Add `#import IXAppDelegate.h`
    2. Change all references to `AppDelegate` class to `IXAppDelegate`

10. Find AppDelegate.h 
	
	1. Add `#import IXAppDelegate.h`
	2. Replace the `@interface` declaration with:
	```
	@interface AppDelegate : IXAppDelegate
	```
	3. Delete `@property (strong, nonatomic) UIWindow *window;`

11. Find AppDelegate.m

	1. Comment out all methods in AppDelegate.m. If you need to override one, you must call `[super *methodname*]` before your own functions.

12. Create a new folder in your project root called `assets`. Drag this folder into Xcode, *deselecting* **Copy items if needed** and *selecting* **Create folder references**.

TODO:

- Fonts (must be manually added to info.plist)
- "iBeacon Monitoring" in info.plist?
- Maybe add sample info.plist that user can download?

## Dependencies

The Ignite Engine uses the following CocoaPods:

- ActionSheetPicker
- AFNetworking 2.0
- AFNetworkActivityLogger
- AFOAuth2Manager
- ALMoviePlayerController
- ApigeeiOSSDK
- APParallaxHeader-Width
- CocoaLumberjack
- Color-Picker-for-iOS
- ColorUtils
- JAFontAwesome
- IQKeyboardManager
- jetfire
- MMDrawerController
- RaptureXML
- Reachability
- SDWebImage
- SVPulsingAnnotationView
- SVWebViewController
- TTTAttributedLabel
- YLMoment
- ZBarSDK
- ZipArchive

## License

ApigeeIgnite is available under the MIT license.
