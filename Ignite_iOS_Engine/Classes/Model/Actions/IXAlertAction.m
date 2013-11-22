//
//  IXAlertAction.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/9/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXAlertAction.h"

#import "IXActionContainer.h"
#import "IXPropertyContainer.h"

@interface IXAlertAction () <UIAlertViewDelegate>
@property (nonatomic,strong) UIAlertView* alertView;
@end

@implementation IXAlertAction

-(void)dealloc
{
    [_alertView setDelegate:nil];
}

-(void)execute
{
    [super execute];
    
    IXPropertyContainer* actionProperties = [self actionProperties];
    
    NSString* title = [actionProperties getStringPropertyValue:kIX_TITLE defaultValue:nil];
    NSString* subTitle = [actionProperties getStringPropertyValue:kIX_SUB_TITLE defaultValue:nil];
    NSString* confirmButtonTitle = [actionProperties getStringPropertyValue:@"confirm_button_title" defaultValue:kIX_OK];
    
    NSString* cancelButtonTitle = nil;
    if( [actionProperties getBoolPropertyValue:@"shows_cancel_button" defaultValue:NO] )
        cancelButtonTitle = [actionProperties getStringPropertyValue:@"cancel_button_title" defaultValue:kIX_CANCEL];
    
    [[self alertView] setDelegate:nil];
    [self setAlertView:[[UIAlertView alloc] initWithTitle:title
                                                  message:subTitle
                                                 delegate:self
                                        cancelButtonTitle:cancelButtonTitle
                                        otherButtonTitles:confirmButtonTitle,nil]];

    
    [[self alertView] show];
}


#pragma mark UIAlertViewDelegate Methods

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    [[self subActionContainer] executeActionsForEventNamed:@"will_present_alert"];
}

- (void)didPresentAlertView:(UIAlertView *)alertView
{
    [[self subActionContainer] executeActionsForEventNamed:@"did_present_alert"];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == [alertView cancelButtonIndex] )
    {
        [[self subActionContainer] executeActionsForEventNamed:@"cancel_button_pressed"];
    }
    else
    {
        [[self subActionContainer] executeActionsForEventNamed:@"confirm_button_pressed"];
    }
    
    [[self alertView] setDelegate:nil];
    [self setAlertView:nil];
}

@end
