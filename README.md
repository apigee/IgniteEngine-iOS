# IgniteEngine

[![Version](https://img.shields.io/cocoapods/v/IgniteEngine.svg?style=flat)](http://cocoapods.org/pods/IgniteEngine)
[![License](https://img.shields.io/cocoapods/l/IgniteEngine.svg?style=flat)](http://cocoapods.org/pods/IgniteEngine)
[![Platform](https://img.shields.io/cocoapods/p/IgniteEngine.svg?style=flat)](http://cocoapods.org/pods/IgniteEngine)

## Introduction

#### What is the Ignite Engine?

The Ignite Engine is a platform for rapidly building native mobile apps using declarative JSON to build views, controllers, and logic. The stability and robustness of the engine frees you to focus on the functionality and design of your app.

#### What platforms are supported?

You can start building apps for iOS today; we're working hard to bring the platform to Android very soon.

## Prerequisites

- A Mac, running Mavericks (v10.9+) or Yosemite (v10.10+).
- [Xcode](https://itunes.apple.com/us/app/xcode/id497799835) (v6.2+).
- If you want to run your apps on iOS devices, you'll need an [iOS Developer](http://developer.apple.com) account.
- The Ignite Engine uses [CocoaPods](http://cocoapods.org) to manage its dependencies. Before you start, open Terminal and run `$ sudo gem install cocoapods` to install the CocoaPods CLI.

## Installation (In 60 Seconds or Less*)

*This is the best way to start learning the Ignite Engine: it doesn't require fiddling around with setting up a new Xcode project.*

1. Download the [Ignite Engine starter kit](https://ignite.apigee.com/starterkit).

2. Unzip the downloaded folder and move it into a place you'll remember (like `~/Development`!).

3. Open Terminal and `$ cd` to the new folder (like `$ cd ~/Development/IgniteEngineStarterKit`).

4. Run `$ pod install` to magically download and install all the dependencies.

5. Open the `IgniteEngineStarterKit.xcworkspace` file and run the app in the iOS simulator.

6. Get up to speed by reading the [docs](https://ignite.apigee.com).
 
<sub>* If you have a super awesome Internet connection. Otherwise it might take a couple minutes ;)</sub>

## Installation (The Hard Way™)

*If you want to learn how to build your own project from scratch and integrate the Ignite Engine, then these steps are for you!*

1. Open Xcode 6.

2. Create a new Single View Application.

3. Delete `Main.storyboard`  (select it, right-click, and choose "Move to Trash").

4. Open `Supporting Files/Info.plist`:

    - Remove the property named `Main storyboard file base name`.
    
    - Add a new property named `IXApp` with the value `app.json` (modify this property's value if required).
    
    - Add a new property named `IXAssets` with the value `assets` (modify this property's value if required).

5. Delete `ViewController.h` and `ViewController.m`.

6. Create an empty file named `podfile` in the root of your project folder with the following text:

    ```
    pod 'IgniteEngine'
    ```
    *(If you're feeling adventurous and know what you're doing, you can also point this pod directly to the GitHub repo).*

7. Open Terminal, and from your project directory, run `$ pod install`

8. Once the IgniteEngine pod and all its dependencies have been installed, open `{MyProject}.xcworkspace` from the root of your Xcode project folder. And yes, that's `.xcworkspace`. The `.xcodeproj` file will **not** work.

9. Open `main.m`:

    - Add `#import IXAppDelegate.h` at the top.
    - Change all references to `AppDelegate` class to be `IXAppDelegate` instead.

10. Open `AppDelegate.h`:
	
	- Add `#import IXAppDelegate.h` at the top.
	- Replace the `@interface` declaration with: `@interface AppDelegate : IXAppDelegate`.
	- Delete `@property (strong, nonatomic) UIWindow *window;`.

11. Open `AppDelegate.m`:

	- Comment out all methods in AppDelegate.m. If you need to override one, you must call `[super *methodname*]` before your own functions.

12. Create a new folder in your project root called `assets`. Drag this folder into Xcode, *deselecting* **Copy items if needed** and *selecting* **Create folder references**.

13. Your IX config will reside in this assets folder. At minimum, you need an `app.json` file and that points to a single view, like so:

	```
	{
	    "$app": {
	        "attributes": {
	            "defaultView": "myView.json"
	        }
	    }
	}
	```

14. Get up to speed by reading the [docs](https://ignite.apigee.com).

## Tips

- If you're creating a git repo for your `/assets`, you should add `Pods/**` to your `.gitignore` to avoid commiting your dynamic dependencies to your repo.

## Contributing

*We didn't make the Ignite Engine open source for nothing! Dig in, get your hands dirty, and submit a pull request.*


1. Clone this repo into somewhere sensible like `~/Development/IgniteEngine-iOS`.

2. Make a copy of the `/Example` project folder and put it somewhere sensible like `~/Development/MyIgniteDevProject` (or make a new one following the steps above).

3. Edit the `podfile` inside `/MyIgniteDevProject` to use a local `:path` declaration:
    
    ```
    pod 'IgniteEngine', :path => '~/Development/IgniteEngine-iOS'
    ```
    
4. Run `pod install` to update your IgniteEngine pod

5. Open `{MyApp}.xcworkspace` from inside your new `/MyigniteDevProject` folder.

6. From the project navigator, expand the `Pods` project and expand `Development Pods > IgniteEngine`.

7. Here you'll find everything you need to get started developing. Because this folder is a symbolic link to your project clone, modifications made inside the `Development Pods` folder will automagically update your git repo.

8. We use the 'fork-and-pull' methodology, so please commit your changes to a branch (like `dev`) on your personal fork and submit a pull request. Accidents happen though, so we added a pre-commit script that you can use to block commits to `master`. Add it to your local repo like so:

    ```
    $ cd ~/Development/IgniteEngine-iOS/.git
    $ mkdir hooks
    $ cd hooks/
    $ ln -s ../../.pre-commit.sh pre-commit
    ```

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

*Note: additional licenses may apply for these dependencies*

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

