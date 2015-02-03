//
//  IXAlertAction.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/9/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

/* From the docs:
 
In a two-button alert that proposes a potentially risky action, the button that cancels the action should be on the right (and light-colored).

In a two-button alert that proposes a benign action that people are likely to want, the button that cancels the action should be on the left (and dark-colored).
 
/**
 
 Allows user to select an image from Library or Camera Roll.
 

 <div id="container">
 <ul>
     <li><a href="../images/IXMediaSource_0.png" data-imagelightbox="c"><img src="../images/IXMediaSource_0.png"></a></li>
     <li><a href="../images/IXMediaSource_1.png" data-imagelightbox="c"><img src="../images/IXMediaSource_1.png"></a></li>
     <li><a href="../images/IXMediaSource_2.png" data-imagelightbox="c"><img src="../images/IXMediaSource_2.png"></a></li>
     <li><a href="../images/IXMediaSource_3.png" data-imagelightbox="c"><img src="../images/IXMediaSource_3.png"></a></li>
 </ul>
 </div>
 
*/

/*
 *      /Docs
 *
*/


#import "IXAlertAction.h"

#import "IXAppManager.h"
#import "IXActionContainer.h"
#import "IXPropertyContainer.h"

// IXAlertAction Properties
static NSString* const kIXTitle = @"title";
static NSString* const kIXMessage = @"message";
static NSString* const kIXButtonTitles = @"button.titles"; //comma separated: OK,Cancel
//static NSString* const kIXButtonDefaultIndex = @"button.default"; //0-based index of default action

// as of iOS7 we can no longer customize which is the highlighted button - the last (right-most or bottom) is always default.
// ref: http://stackoverflow.com/questions/19125249/highlight-top-button-in-uialertview

// IXAlertAction Events
static NSString* const kIXWillPresentAlert = @"will_present_alert";
static NSString* const kIXDidPresentAlert = @"did_present_alert";
static NSString* const kIXButtonPressed = @"button_pressed"; //default stand-in for index 0 (for laziness)
static NSString* const kIXButtonIndexPressed = @"button_%lu_pressed"; //0-based index of action to execute

@interface IXAlertAction () <UIAlertViewDelegate>
@property (nonatomic,strong) UIAlertView* alertView;
@end

@implementation IXAlertAction


/*
* Docs
*
*/

/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-warning">
 <i class="ti-panel"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Attributes</h3>
 <p>This has the following attributes:</p>
 </div>
 </div>

    @param urce Style of controls to use<br>*cameralibrary*
    @param camera Color of the player UI<br>*frontrear*
    @param show_camera_controls Height of the player UI<br>*(float)*

*/

-(void)attributes
{
}
/***************************************************************/
/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-info">
 <i class="ti-loop"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Returns</h3>
 <p>This has the following attributes:</p>
 </div>
 </div>

 @param selected_media The value the knob has been set to<br>*(string)*

*/

-(void)returns
{
}

/***************************************************************/
/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-success">
 <i class="ti-pulse"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Events</h3>
 <p>This control fires the following events:</p>
 </div>
 </div>


    @param did_load_media Fires when the media loads successfully
    @param failed_load_media Fires when the media fails to load

*/

-(void)events
{
}

/***************************************************************/
/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-danger">
 <i class="ti-direction"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Functions</h3>
 <p>This control supports the following functions:</p>
 </div>
 </div>

   
 @param present_picker Present the media picker view controller.
 
 <pre class="brush: js; toolbar: false;">
 
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "mediaSourceTest",
    "function_name": "present_picker"
  }
}
 
 </pre>
 
 @param dismiss_picker Dismiss the media picker view controller.
 
 <pre class="brush: js; toolbar: false;">
 
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "mediaSourceTest",
    "function_name": "dismiss_picker"
  }
}
 
 </pre>

*/

-(void)functions
{
}

/***************************************************************/
/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-primary">
 <i class="ti-shortcode"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Example</h3>
 <p>Go on, try it out!</p>
 </div>
 </div>


 <pre class="brush: js; toolbar: false;">
 
{
  "_id": "mediaSourceTest",
  "_type": "MediaSource",
  "actions": [
    {
      "on": "did_load_media",
      "_type": "Alert",
      "attributes": {
        "title": "did_load_media: [[$self.selected_media]]"
      }
    }
  ],
  "attributes": {
    "source": "library"
  }
}
 
 </pre>



*/

-(void)example
{
}

/***************************************************************/

/*
* /Docs
*
*/

-(void)dealloc
{
    [_alertView setDelegate:nil];
}

-(void)execute
{
    [super execute];
    
    IXPropertyContainer* actionProperties = [self actionProperties];
    
    NSString* title = [actionProperties getStringPropertyValue:kIXTitle defaultValue:nil];
    NSString* message = [actionProperties getStringPropertyValue:kIXMessage defaultValue:nil];
    
    NSArray* buttonTitles = [actionProperties getCommaSeperatedArrayListValue:kIXButtonTitles defaultValue:@[kIX_OK]];
    
    [[self alertView] setDelegate:nil];
    [[self alertView] dismissWithClickedButtonIndex:[[self alertView] cancelButtonIndex] animated:YES];
    [self setAlertView:[[UIAlertView alloc] initWithTitle:title
                                                  message:message
                                                 delegate:self
                                        cancelButtonTitle:nil
                                        otherButtonTitles:nil]];
    for ( NSString *title in buttonTitles )  {
        [self.alertView addButtonWithTitle:title];
    }
    
    [[self alertView] show];
}


#pragma mark UIAlertViewDelegate Methods

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    [[self subActionContainer] executeActionsForEventNamed:kIXWillPresentAlert];
}

- (void)didPresentAlertView:(UIAlertView *)alertView
{
    [[self subActionContainer] executeActionsForEventNamed:kIXDidPresentAlert];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[self alertView] setDelegate:nil];
    [self setAlertView:nil];
    
    NSString* actionName = [NSString stringWithFormat:kIXButtonIndexPressed, (long)buttonIndex];
    [self actionDidFinishWithEvents:@[actionName]];
    if (buttonIndex == 0)
    {
        // This is here so we can use the alias action trigger (on) "button_pressed"
        [self actionDidFinishWithEvents:@[kIXButtonPressed]];
    }

// deprecated
//    if( buttonIndex == [alertView cancelButtonIndex] )
//    {
//        [self actionDidFinishWithEvents:@[kIXCancelButtonPressed]];
//    }
//    else
//    {
//        [self actionDidFinishWithEvents:@[kIXConfirmButtonPressed]];
//    }
}

@end

@implementation IXDevalertAction

-(void)execute
{
    if( [[IXAppManager sharedAppManager] appMode] == IXDebugMode )
    {
        [super execute];
    }
}

@end

