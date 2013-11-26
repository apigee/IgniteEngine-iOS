//
//  IXTextInputControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/15/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

/*
 
 CONTROL
 
 - TYPE : "TextInput"
 
 - PROPERTIES
 
 * name="dismiss_on_return"         default="YES"               type="BOOL"
 * name="placeholder_text"          default=""                  type="String"
 * name="placeholder_text_color"    default="lightGrayColor"    type="Color"

 - EVENTS
 
 * name="got_focus"         when="Occurs when the user begins editing the text."
 * name="lost_focus"        when="Occurs when the return key is pressed and "dismiss_on_return" is set to YES"
 
 */


#import "IXTextInput.h"

#import "IXLayout.h"
#import "IXAppManager.h"
#import "IXNavigationViewController.h"
#import "IXViewController.h"
#import "IXClickableScrollView.h"

#import "UITextField+IXAdditions.h"

static CGSize sIXKBSize;

@interface IXTextInput () <UITextFieldDelegate>

@property (nonatomic,assign) BOOL needsToRegisterForKeyboardNotifications;
@property (nonatomic,strong) UITextField* textField;
@property (nonatomic,assign,getter = shouldDismissOnReturn) BOOL dismissOnReturn;

@end

@implementation IXTextInput

-(void)dealloc
{
    [self unregisterForKeyboardNotifications];
    [_textField setDelegate:nil];
}

-(void)buildView
{
    [super buildView];
    
    _needsToRegisterForKeyboardNotifications = YES;
    
    _textField = [[UITextField alloc] initWithFrame:[[self contentView] bounds]];
    [_textField setDelegate:self];
    
    [[self contentView] addSubview:_textField];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    CGSize returnSize = CGSizeMake(size.width, 40.0f);
    float editorHeight = fmax(40.0f,[self textField].frame.size.height);
    returnSize.height = editorHeight;
    return returnSize;
}

-(void)layoutControlContentsInRect:(CGRect)rect
{    
    [[self textField] setFrame:rect];
}

-(void)applySettings
{
    [super applySettings];
    
    NSString* keyboardAppearance = [[self propertyContainer] getStringPropertyValue:@"keyboard.appearance" defaultValue:@"default"];
    [[self textField] setKeyboardAppearance:[UITextField stringToKeyboardAppearance:keyboardAppearance]];
    
    NSString* keyboardType = [[self propertyContainer] getStringPropertyValue:@"keyboard.type" defaultValue:@"default"];
    [[self textField] setKeyboardType:[UITextField stringToKeyboardType:keyboardType]];
    
    NSString* returnKey = [[self propertyContainer] getStringPropertyValue:@"keyboard.return_key" defaultValue:@"default"];
    [[self textField] setReturnKeyType:[UITextField stringToReturnKeyType:returnKey]];
    
    [self setDismissOnReturn:[[self propertyContainer] getBoolPropertyValue:@"dismiss_on_return" defaultValue:YES]];
    [[self textField] setBackgroundColor:[UIColor whiteColor]];
    
    NSString* placeHolderText = [[self propertyContainer] getStringPropertyValue:@"placeholder_text" defaultValue:@"TextInputPlaceHolder"];
    UIColor* placeHolderTextColor = [[self propertyContainer] getColorPropertyValue:@"placeholder_text_color" defaultValue:[UIColor lightGrayColor]];
    NSAttributedString* attributedPlaceHolder = [[NSAttributedString alloc] initWithString:placeHolderText
                                                                                attributes:@{NSForegroundColorAttributeName: placeHolderTextColor}];
    [[self textField] setAttributedPlaceholder:attributedPlaceHolder];
}

- (void)registerForKeyboardNotifications
{
    if( _needsToRegisterForKeyboardNotifications )
    {
        _needsToRegisterForKeyboardNotifications = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShown:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillBeHidden:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillChangeFrame:)
                                                     name:UIKeyboardDidChangeFrameNotification
                                                   object:nil];
    }
}

-(void)unregisterForKeyboardNotifications
{
    if( !_needsToRegisterForKeyboardNotifications )
    {
        _needsToRegisterForKeyboardNotifications = YES;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillShowNotification
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillHideNotification
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardDidChangeFrameNotification
                                                      object:nil];
    }
}

- (void)keyboardWillChangeFrame:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    sIXKBSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    double animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [self adjustScrollViewForKeyboard:animationDuration];
}

- (void)keyboardWillShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    sIXKBSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    double animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [self adjustScrollViewForKeyboard:animationDuration];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    double animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    UIScrollView* scrollView = nil;
    UIViewController* visibleVC = [[[IXAppManager sharedAppManager] rootViewController] visibleViewController];
    if( [visibleVC isKindOfClass:[IXViewController class]] )
    {
        IXViewController* IXVC = (IXViewController*) visibleVC;
        scrollView = [[IXVC containerControl] scrollView];
    }
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         UIEdgeInsets contentInsets = UIEdgeInsetsMake(scrollView.contentInset.top, 0.0f, 0.0f, 0.0f);
                         scrollView.contentInset = contentInsets;
                         scrollView.scrollIndicatorInsets = contentInsets;
                         [scrollView setContentOffset:CGPointMake(0, -contentInsets.top) animated:YES];
    }];
}

-(void)adjustScrollViewForKeyboard:(float)animationDuration
{
    if( ![[self textField] isFirstResponder] )
        return;
    
    CGFloat keyboardHeight = fmin(sIXKBSize.height,sIXKBSize.width);
    
    UIScrollView* scrollView = nil;
    UIViewController* visibleVC = [[[IXAppManager sharedAppManager] rootViewController] visibleViewController];
    if( [visibleVC isKindOfClass:[IXViewController class]] )
    {
        IXViewController* IXVC = (IXViewController*) visibleVC;
        scrollView = [[IXVC containerControl] scrollView];
    }
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         UIEdgeInsets contentInsets = UIEdgeInsetsMake(scrollView.contentInset.top, 0.0f, keyboardHeight, 0.0f);
                         
                         scrollView.contentInset = contentInsets;
                         scrollView.scrollIndicatorInsets = contentInsets;
                         
                         CGRect aRect = visibleVC.view.frame;
                         aRect.size.height -= keyboardHeight;
                         
                         //scrollView converts the frame of subView.frame to the coordinate system of someOtherView
                         CGRect textFieldScreenFrame = [[self contentView] convertRect:[[self textField] frame] toView:nil];
                         
                         if (!CGRectContainsPoint(aRect, textFieldScreenFrame.origin) ) {
                             [scrollView scrollRectToVisible:[self textField].frame animated:YES];
                         }
                     }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self unregisterForKeyboardNotifications];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self registerForKeyboardNotifications];
    [self adjustScrollViewForKeyboard:0.0f];
    
    [[self actionContainer] executeActionsForEventNamed:@"got_focus"];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL shouldReturn = [self shouldDismissOnReturn];
    if( shouldReturn )
    {
        [textField resignFirstResponder];
        [self unregisterForKeyboardNotifications];
        [[self actionContainer] executeActionsForEventNamed:@"lost_focus"];
    }
    return shouldReturn;
}

-(void)applyFunction:(NSString*)functionName withParameters:(IXPropertyContainer*)parameterContainer
{
    if( [functionName isEqualToString:@"keyboard_hide"] )
    {
        [[self textField] resignFirstResponder];
    }
    else if( [functionName isEqualToString:@"keyboard_show"] )
    {
        [[self textField] becomeFirstResponder];
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

// MAY HAVE A REASON TO IMPLEMENT THIS LATER
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;
//{
//    return YES;
//}

@end
