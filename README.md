# IgniteEngine

[![CI Status](http://img.shields.io/travis/brandon/ApigeeIgnite.svg?style=flat)](https://travis-ci.org/brandon/ApigeeIgnite)
[![Version](https://img.shields.io/cocoapods/v/ApigeeIgnite.svg?style=flat)](http://cocoapods.org/pods/ApigeeIgnite)
[![License](https://img.shields.io/cocoapods/l/ApigeeIgnite.svg?style=flat)](http://cocoapods.org/pods/ApigeeIgnite)
[![Platform](https://img.shields.io/cocoapods/p/ApigeeIgnite.svg?style=flat)](http://cocoapods.org/pods/ApigeeIgnite)

## Usage

TODO

## Installation

ApigeeIgnite will soon be available through [CocoaPods](http://cocoapods.org). For the time being, to manually create a new project:

Before you start: clone this project and have the `/Engine` folder available on your local workstation.

1. Open Xcode 6

2. Create an Single View Application

3. Remove Main.storyboard  (select it, right-click, and choose "Move to Trash")

4. Remove "Main storyboard file base name" entry from Info.plist file.

5. Delete ViewController.h and ViewController.m

6. Create an empty file named `podfile` in the root of your project folder with the following text. Update the `:path` to point to your local Engine directory, which at its root, contains `ApigeeIgnite.podspec`.
    ```
    pod 'ApigeeIgnite', :path => '/local/path/where_you_cloned_the/Engine'
    ```

7. From your project directory, run `pod install`

8. Once the ApigeeIgnite pod and all dependencies have been installed, open [MyProject].xcworkspace.

9. Find main.m

    1. Add `#import IXAppDelegate.h`
    2. Change all references to `AppDelegate` class to `IXAppDelegate`

10. Find AppDelegate.h 
	
	1. Add `#import IXAppDelegate.h`
	2. Replace the `@interface` declaration with `@interface AppDelegate : IXAppDelegate`
	3. Delete `@property (strong, nonatomic) UIWindow *window;`

11. Find AppDelegate.m

	1. Comment out all methods in AppDelegate.m. If you need to override one, you must call `[super *methodname*]` before your own functions.

12. Create a new folder in your project root called `assets`. Drag this folder into Xcode, *deselecting* **Copy items if needed** and *selecting* **Create folder references**.

13. Your IX config will reside in this assets folder. At minimum, you need an `app.json` file and that points to a single view, like so:

	```
	{
	    "$app": {
	        "attributes": {
	            "view.index": "myView.json"
	        }
	    }
	}
	```

14. Get up to speed by reading the [docs](https://ignite.apigee.com).

15. If you're creating a git repo for your `/assets`, you should add `Engine/**` to your `.gitignore` to avoid commiting the entire IX engine to your repo.

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

 The MIT License (MIT)

 Copyright (c) 2015 Apigee Corporation

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.