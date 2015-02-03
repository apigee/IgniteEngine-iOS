//
//  IXPassKit.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 11/14/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

/*
 *      Docs
 *
 *      Author:     Jeremy Anticouni
 *      Date:     42034
 *
 *
 *      Copyright (c) 2015 Apigee. All rights reserved.
*/

/**
 
 Interact with Passbook Passes directly without calling out to Safari.
 

 <div id="container">
 <ul>
 <li><a href="../images/IXPassKit_0.png" data-imagelightbox="c"><img src="../images/IXPassKit_0.png"></a></li>
 <li><a href="../images/IXPassKit_1.png" data-imagelightbox="c"><img src="../images/IXPassKit_1.png"></a></li>
 <li><a href="../images/IXPassKit_2.png" data-imagelightbox="c"><img src="../images/IXPassKit_2.png"></a></li>
 </ul>
</div>
 
*/

/*
 *      /Docs
 *
*/

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

/*  -----------------------------  */
//  [Documentation]

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-warning">
 <i class="ti-panel"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Attributes</h3>
 <p>This has the following attributes:</p>
 </div>
 </div>

    @param pass.location http:// or /path/to/pass.passkit  <br>    *(string)*
 
*/

-(void)attributes
{
    // Documentation: Config
}

/** Events
 
 IXPassKit has the following events:
 
 @param pass.creation.success Fires when the pass is displayed successfully
 @param pass.creation.failed Fires when an error occurs when displaying the pass
 
*/

-(void)events
{
    // Documentation: Events
}

/** Functions
 
 @param pass.controller.present Present PassKit view controller
 
 <pre class="brush: js; toolbar: false;">
     {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "passkitTest",
        "function_name": "pass.controller.present"
      }
    }
 </pre>

 
 @param pass.controller.dismiss Dismiss PassKit view controller
 
 <pre class="brush: js; toolbar: false;">
     {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "passkitTest",
        "function_name": "pass.controller.dismiss"
      }
    }
 </pre>

 */

-(void)functions
{
    // Documentation: Functions
}

/***************************************************************/
/***************************************************************/

/** Read-Only Attributes
 
 @param passkit.available	 *(bool)*   |   Is Does this device support PassKit?
 @param passkit.containsPass *(bool)*   |   Does the file you’ve pointed to actually contain a PassKit pass?
 @param pass.error *(string)*   |   Whoopsie.
 
*/

-(void)returns
{
    // Documentation: Read-only Attributes
}

/**
<pre class="brush: js; toolbar: false;">
 
{
  "_id": "passKitTest",
  "_type": "PassKit",
  "actions": [
    {
      "on": "pass.creation.success",
      "_type": "Alert",
      "attributes": {
        "title": "Pass created."
      }
    },
    {
      "on": "pass.creation.failed",
      "_type": "Alert",
      "attributes": {
        "title": "Pass failed."
      }
    }
  ],
  "attributes": {
    "pass.location": "/data/boardingpass.pkpass"
  }
}
 
</pre>
 
*/

-(void)example
{
    // Documentation: Sample Code
}

//  /[Documentation]
/*  -----------------------------  */


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
