//
//  IXPassKit.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 11/14/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

/*  -----------------------------  */
//  [Documentation]
//
//  Author:     Jeremy Anticouni
//  Date:       1/29/2015
//
//  Copyright (c) 2015 Apigee. All rights reserved.
//
/*  -----------------------------  */
/**
 
 ###    Native iOS UI control that displays a menu from the bottom of the screen.
  
 <a href="#attributes">Attributes</a>,
 <a href="#readonly">Read-Only</a>,
 <a href="#inherits">Inherits</a>,
 <a href="#events">Events</a>,
 <a href="#functions">Functions</a>,
 <a href="#example">Example JSON</a>
 
 ##  <a name="attributes">Attributes</a>
 
 | Name                           | Type        | Description                                | Default |
 |--------------------------------|-------------|--------------------------------------------|---------|
 | pass.location                  | *(string)*  | http:// or /path/to/pass.passkit           |         |

 ##  <a name="readonly">Read Only Attributes</a>
 
 | Name                 | Type       | Description                                                      |
 |----------------------|------------|------------------------------------------------------------------|
 | passkit.available    | *(bool)*   | Does this device support PassKit?                                |
 | passkit.containsPass | *(bool)*   | Does the file you've pointed to actually contain a PassKit pass? |
 | pass.error           | *(string)* | Whoopsie.                                                        |
 
 ##  <a name="inherits">Inherits</a>
 
>  IXBaseControl
 
 ##  <a name="events">Events</a>

 | Name                  | Description                                         |
 |-----------------------|-----------------------------------------------------|
 | pass.creation.success | Fires when the pass is displayed successfully       |
 | pass.creation.failed  | Fires when an error occurs when displaying the pass |
 

 ##  <a name="functions">Functions</a>
 
Present the PassKit view controller: *pass.controller.present*

    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "passkitTest",
        "function_name": "pass.controller.present"
      }
    }

Dismiss the PassKit view controller: *pass.controller.dismiss*

    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "passkitTest",
        "function_name": "pass.controller.dismiss"
      }
    }
 
 ##  <a name="example">Example JSON</a> 
 

 
 */
//
//  [/Documentation]
/*  -----------------------------  */

#import "IXPassKit.h"

#import "NSString+IXAdditions.h"
#import "IXAppManager.h"
#import "IXNavigationViewController.h"
#import "IXViewController.h"

@import PassKit;

// PassKit Attributes
IX_STATIC_CONST_STRING kIXPassLocation = @"pass.location";

// PassKit Read-Only Properties
IX_STATIC_CONST_STRING kIXPassKitAvailable = @"passkit.available";
IX_STATIC_CONST_STRING kIXPassKitContainsPass = @"passkit.containsPass";
IX_STATIC_CONST_STRING kIXPassError = @"pass.error";

// PassKit Functions
IX_STATIC_CONST_STRING kIXPassControllerPresent = @"pass.controller.present";
IX_STATIC_CONST_STRING kIXPassControllerDismiss = @"pass.controller.dismiss";

// PassKit Events
IX_STATIC_CONST_STRING kIXPassCreationSuccess = @"pass.creation.success";
IX_STATIC_CONST_STRING kIXPassCreationFailed = @"pass.creation.failed";

@interface IXPassKit () <PKAddPassesViewControllerDelegate>

@property (nonatomic,strong) NSURL* passURL;
@property (nonatomic,strong) PKPass* pass;
@property (nonatomic,strong) NSError* passCreationError;

@property (nonatomic,strong) PKPassLibrary* passLibrary;
@property (nonatomic,strong) PKAddPassesViewController* addPassesViewController;

@end

@implementation IXPassKit

-(void)dealloc
{
    [self dismissPassController:YES];
}

-(void)buildView
{
    if( [PKPassLibrary isPassLibraryAvailable] ) {
        _passLibrary = [[PKPassLibrary alloc] init];
    }
}

-(void)applySettings
{
    [super applySettings];

    NSURL* passURL = [self.propertyContainer getURLPathPropertyValue:kIXPassLocation basePath:nil defaultValue:nil];
    if( [self passURL] == nil || ![[self passURL] isEqual:passURL] || [self pass] == nil ) {

        [self setPassURL:passURL];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            NSData* passData = [[NSData alloc] initWithContentsOfURL:[self passURL]];
            NSError* passCreationError;
            PKPass* createdPass = [[PKPass alloc] initWithData:passData error:&passCreationError];

            [self setPass:createdPass];
            [self setPassCreationError:passCreationError];

            IX_dispatch_main_sync_safe(^{

                if( [self pass] == nil )
                {
                    [[self actionContainer] executeActionsForEventNamed:kIXPassCreationFailed];

                    IX_LOG_ERROR(@"ERROR: from %@ in %@ : PASSKIT CONTROL ID:%@ CREATION ERROR: %@",THIS_FILE,THIS_METHOD,[[self ID] uppercaseString],[[self passCreationError] description]);
                }
                else
                {
                    [[self actionContainer] executeActionsForEventNamed:kIXPassCreationSuccess];
                }

            });
        });
    }
}

-(NSString *)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = nil;
    if( [propertyName isEqualToString:kIXPassKitAvailable] )
    {
        returnValue = [NSString ix_stringFromBOOL:[PKPassLibrary isPassLibraryAvailable]];
    }
    else if( [propertyName isEqualToString:kIXPassKitContainsPass] )
    {
        if( [self passLibrary] != nil && [self pass] != nil ) {
            returnValue = [NSString ix_stringFromBOOL:[[self passLibrary] containsPass:[self pass]]];
        } else {
            returnValue = kIX_FALSE;
        }
    }
    else if( [propertyName isEqualToString:kIXPassError] )
    {
        returnValue = [[self passCreationError] description];
    }
    else {
        returnValue = [super getReadOnlyPropertyValue:propertyName];
    }
    return returnValue;
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXPassControllerPresent] )
    {
        [self presentPassController:YES];
    }
    else if( [functionName isEqualToString:kIXPassControllerDismiss] )
    {
        [self dismissPassController:YES];
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

-(void)dismissPassController:(BOOL)animated
{
    if( self.addPassesViewController != nil && ![self.addPassesViewController isBeingPresented] && ![self.addPassesViewController isBeingDismissed] && [self.addPassesViewController presentingViewController] )
    {
        [self.addPassesViewController setDelegate:nil];
        [self.addPassesViewController dismissViewControllerAnimated:animated completion:nil];
    }
}

-(void)presentPassController:(BOOL)animated
{
    if( ![self.addPassesViewController isBeingPresented] && ![self.addPassesViewController isBeingDismissed] && ![self.addPassesViewController presentingViewController] )
    {
        if( [PKPassLibrary isPassLibraryAvailable] && [self pass] != nil ) {
            [self dismissPassController:NO];
            [self setAddPassesViewController:[[PKAddPassesViewController alloc] initWithPass:[self pass]]];
            [self.addPassesViewController setDelegate:self];
            [[[IXAppManager sharedAppManager] rootViewController] presentViewController:self.addPassesViewController animated:animated completion:nil];
        }
    }
}

-(void)addPassesViewControllerDidFinish:(PKAddPassesViewController *)controller
{
    [controller setDelegate:nil];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
