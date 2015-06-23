//
//  IXPassKit.m
//  Ignite Engine
//
//  Created by Robert Walsh on 11/14/14.
//
/****************************************************************************
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
 ****************************************************************************/
//

#import "IXPassKit.h"

#import "NSString+IXAdditions.h"
#import "IXAppManager.h"
#import "IXNavigationViewController.h"
#import "IXViewController.h"

@import PassKit;

// PassKit Attributes
IX_STATIC_CONST_STRING kIXPassLocation = @"passUrl";

// PassKit Read-Only Properties
IX_STATIC_CONST_STRING kIXPassKitAvailable = @"isAllowed";
IX_STATIC_CONST_STRING kIXPassKitContainsPass = @"hasPass";
IX_STATIC_CONST_STRING kIXPassError = @"error.message";

// PassKit Functions
IX_STATIC_CONST_STRING kIXPassControllerPresent = @"present";
IX_STATIC_CONST_STRING kIXPassControllerDismiss = @"dismiss";

// PassKit Events
IX_STATIC_CONST_STRING kIXPassCreationSuccess = @"success";
IX_STATIC_CONST_STRING kIXPassCreationFailed = @"error";

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
    
    NSURL* passURL = [self.attributeContainer getURLValueForAttribute:kIXPassLocation basePath:nil defaultValue:nil];
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

-(void)applyFunction:(NSString *)functionName withParameters:(IXAttributeContainer *)parameterContainer
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
