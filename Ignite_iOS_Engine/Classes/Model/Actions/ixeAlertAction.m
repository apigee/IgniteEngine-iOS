//
//  ixeAlertAction.m
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/9.
//  Copyright (c) 2013 All rights reserved.
//

#import "ixeAlertAction.h"

#import "ixeActionContainer.h"
#import "ixePropertyContainer.h"

@interface ixeAlertAction () <UIAlertViewDelegate>
@property (nonatomic,strong) UIAlertView* alertView;
@end

@implementation ixeAlertAction

-(void)dealloc
{
    [_alertView setDelegate:nil];
}

-(void)execute
{
    [super execute];
    
    ixePropertyContainer* actionProperties = [self actionProperties];
    
    NSString* title = [actionProperties getStringPropertyValue:kixe_TITLE defaultValue:nil];
    NSString* subTitle = [actionProperties getStringPropertyValue:kixe_SUB_TITLE defaultValue:nil];
    NSString* confirmButtonTitle = [actionProperties getStringPropertyValue:@"confirm_button_title" defaultValue:kixe_OK];
    
    NSString* cancelButtonTitle = nil;
    if( [actionProperties getBoolPropertyValue:@"shows_cancel_button" defaultValue:NO] )
        cancelButtonTitle = [actionProperties getStringPropertyValue:@"cancel_button_title" defaultValue:kixe_CANCEL];
    
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
