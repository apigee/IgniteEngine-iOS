# IgniteEngine

[![Version](https://img.shields.io/cocoapods/v/IgniteEngine.svg?style=flat)](http://cocoapods.org/pods/IgniteEngine)
[![License](https://img.shields.io/cocoapods/l/IgniteEngine.svg?style=flat)](http://cocoapods.org/pods/IgniteEngine)
[![Platform](https://img.shields.io/cocoapods/p/IgniteEngine.svg?style=flat)](http://cocoapods.org/pods/IgniteEngine)

## Before You Start

The easiest way to get started with the Ignite Engine is through [CocoaPods](http://cocoapods.org). Before you start, run `[sudo] gem install cocoapods` to install the CocoaPods CLI.


## Installation (In 60 Seconds or Less*)

> This is the best way to start learning the Ignite Engine. It doesn't require fiddling around with setting up a new Xcode project.

1. Download the [Ignite Engine starter kit](https://ignite.apigee.com/StarterKit.zip).

2. Unzip the downloaded folder and move it into a place you'll remember (like `~/Development`!).

3. Open Terminal and `cd` to the new folder (like `cd ~/Development/IgniteEngine`).

4. Type `pod install` to magically download and install all the dependencies.

5. Open the `IgniteEngineApp.xcworkspace` file and run the app in the iOS simulator.

6. Get up to speed by reading the [docs](https://ignite.apigee.com).
 
<sub>* If you have a super awesome internet connection. Otherwise it might take a couple minutes ;)</sub>

## Installation (The Hard Way™)

> If you want to learn how to build your own project from scratch and integrate the Ignite Engine, then these steps are for you!

1. Open Xcode 6

2. Create an Single View Application

3. Remove Main.storyboard  (select it, right-click, and choose "Move to Trash")

4. Remove "Main storyboard file base name" entry from Info.plist file.

5. Delete ViewController.h and ViewController.m

6. Create an empty file named `podfile` in the root of your project folder with the following text. *(If you're feeling adventurous and know what you're doing, you can also point directly to the GitHub project).*

    ```
    pod 'IgniteEngine'
    ```

7. Open Terminal, and from your project directory, run `pod install`

8. Once the IgniteEngine pod and all its dependencies have been installed, open [MyProject].xcworkspace from the root of your Xcode project folder. And yes, that's `.xcworkspace`. The `.xcodeproj` file will **not** work.

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

## Tips

- If you're creating a git repo for your `/assets`, you should add `Pods/**` to your `.gitignore` to avoid commiting your dynamic dependencies to your repo.

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
