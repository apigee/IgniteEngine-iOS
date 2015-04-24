1. Open Xcode 6

2. Create an Single View Application

3. Remove Main.storyboard  (select it, right-click, and choose "Move to Trash")

4. Remove "Main storyboard file base name" entry from Info.plist file.

5. Delete ViewController.h and ViewController.m

6. Create a new `podfile` in the root of your project folder with the following configuration:
    ```
    pod 'ApigeeIgnite', :path => '/local/path/to/Engine'
    ```

7. Find main.m

    1. Add `#import IXAppDelegate.h`
    2. Change all references to `AppDelegate` class to `IXAppDelegate`

8. Find AppDelegate.h 
	
	1. Add `#import IXAppDelegate.h`
	2. Replace the `@interface` declaration with:
	```
	@interface AppDelegate : IXAppDelegate
	```
	3. Delete `@property (strong, nonatomic) UIWindow *window;`

9. Find AppDelegate.m

	1. Comment out all methods in AppDelegate.m. If you need to override one, you must call `[super *methodname*]` before your own functions.

10. Create a new folder in your project root called `assets`. Drag this folder into Xcode, *deselecting* **Copy items if needed** and *selecting* **Create folder references**.

TODO:

- Fonts (must be manually added to info.plist)
- "iBeacon Monitoring" in info.plist?
- Maybe add sample info.plist that user can download?