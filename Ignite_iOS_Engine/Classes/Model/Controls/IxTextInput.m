//
//  IxTextInputControl.m
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/15.
//  Copyright (c) 2013 All rights reserved.
//

/*
 
 WIDGET
 
 - TYPE : "TextInput"
 
 - PROPERTIES
 
 * name="dismiss_on_return"         default="YES"               type="BOOL"
 * name="placeholder_text"          default=""                  type="String"
 * name="placeholder_text_color"    default="lightGrayColor"    type="Color"

 - EVENTS
 
 * name="got_focus"         when="Occurs when the user begins editing the text."
 * name="lost_focus"        when="Occurs when the return key is pressed and "dismiss_on_return" is set to YES"
 
 */


#import "IxTextInput.h"

#import "IxLayout.h"
#import "IxAppManager.h"
#import "IxNavigationViewController.h"
#import "IxViewController.h"
#import "IxClickableScrollView.h"

static UITextField* activeTextField = nil;
static CGSize kbSize;
@interface IxTextInput () <UITextFieldDelegate>

@property (nonatomic,assign) BOOL needsToRegisterForKeyboardNotifications;
@property (nonatomic,strong) UITextField* textField;
@property (nonatomic,assign,getter = shouldDismissOnReturn) BOOL dismissOnReturn;

@end

@implementation IxTextInput

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
    
    float editorHeight = fmax(40.0f,_textField.frame.size.height);
    
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
    
    // Keyboard Appearance
    
    NSString* keyboardAppearance = [[self propertyContainer] getStringPropertyValue:@"keyboard.appearance" defaultValue:@"default"];
    
    if([keyboardAppearance compare:@"light"] == NSOrderedSame)
    {
        self.textField.keyboardAppearance = UIKeyboardAppearanceLight;
    }
    else if([keyboardAppearance compare:@"dark"] == NSOrderedSame)
    {
        self.textField.keyboardAppearance = UIKeyboardAppearanceDark;
    }
    else
    {
        self.textField.keyboardAppearance = UIKeyboardAppearanceDefault;
    }
    
    // Keyboard Type
    
    
    NSString* keyboardType = [[self propertyContainer] getStringPropertyValue:@"keyboard.type" defaultValue:@"default"];
    
    if([keyboardType compare:@"email"] == NSOrderedSame)
    {
        self.textField.keyboardType = UIKeyboardTypeEmailAddress;
    }
    else if([keyboardType compare:@"number"] == NSOrderedSame)
    {
        self.textField.keyboardAppearance = UIKeyboardTypeNumberPad;
    }
    else if([keyboardType compare:@"phone"] == NSOrderedSame)
    {
        self.textField.keyboardAppearance = UIKeyboardTypePhonePad;
    }
    else if([keyboardType compare:@"url"] == NSOrderedSame)
    {
        self.textField.keyboardAppearance = UIKeyboardTypeURL;
    }
    else if([keyboardType compare:@"decimal"] == NSOrderedSame)
    {
        self.textField.keyboardAppearance = UIKeyboardTypeDecimalPad;
    }
    else if([keyboardType compare:@"name_phone"] == NSOrderedSame)
    {
        self.textField.keyboardAppearance = UIKeyboardTypeNamePhonePad;
    }
    else if([keyboardType compare:@"numbers_punctuation"] == NSOrderedSame)
    {
        self.textField.keyboardAppearance = UIKeyboardTypeNumbersAndPunctuation;
    }
    else
    {
        self.textField.keyboardAppearance = UIKeyboardTypeDefault;
    }
    
    // Return Key
    
    NSString* returnKey = [[self propertyContainer] getStringPropertyValue:@"keyboard.return_key" defaultValue:@"default"];
    
    if([returnKey compare:@"go"] == NSOrderedSame)
    {
        self.textField.returnKeyType = UIReturnKeyGo;
    }
    else if([returnKey compare:@"next"] == NSOrderedSame)
    {
        self.textField.returnKeyType = UIReturnKeyNext;
    }
    else if([returnKey compare:@"search"] == NSOrderedSame)
    {
        self.textField.returnKeyType = UIReturnKeySearch;
    }
    else if([returnKey compare:@"done"] == NSOrderedSame)
    {
        self.textField.returnKeyType = UIReturnKeyDone;
    }
    else if([returnKey compare:@"join"] == NSOrderedSame)
    {
        self.textField.returnKeyType = UIReturnKeyJoin;
    }
    else if([returnKey compare:@"send"] == NSOrderedSame)
    {
        self.textField.returnKeyType = UIReturnKeySend;
    }
    else if([returnKey compare:@"route"] == NSOrderedSame)
    {
        self.textField.returnKeyType = UIReturnKeyRoute;
    }
    else if([returnKey compare:@"emergency"] == NSOrderedSame)
    {
        self.textField.returnKeyType = UIReturnKeyEmergencyCall;
    }
    else if([returnKey compare:@"google"] == NSOrderedSame)
    {
        self.textField.returnKeyType = UIReturnKeyGoogle;
    }
    else if([returnKey compare:@"yahoo"] == NSOrderedSame)
    {
        self.textField.returnKeyType = UIReturnKeyYahoo;
    }
    else
    {
        self.textField.returnKeyType = UIReturnKeyDefault;
    }
    
    [self setDismissOnReturn:[[self propertyContainer] getBoolPropertyValue:@"dismiss_on_return" defaultValue:YES]];
    [[self textField] setBackgroundColor:[UIColor whiteColor]];
    
    NSString* placeHolderText = [[self propertyContainer] getStringPropertyValue:@"placeholder_text" defaultValue:@"TextInputPlaceHolder"];
    UIColor* placeHolderTextColor = [[self propertyContainer] getColorPropertyValue:@"placeholder_text_color" defaultValue:[UIColor lightGrayColor]];
    NSAttributedString* attributedPlaceHolder = [[NSAttributedString alloc] initWithString:placeHolderText
                                                                                attributes:@{NSForegroundColorAttributeName: placeHolderTextColor}];
    [[self textField] setAttributedPlaceholder:attributedPlaceHolder];
    
    // TODO: Add more properties.
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
    kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    double animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [self adjustScrollViewForKeyboard:animationDuration];
}

- (void)keyboardWillShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    double animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [self adjustScrollViewForKeyboard:animationDuration];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    double animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    UIScrollView* scrollView = nil;
    UIViewController* visibleVC = [[[IxAppManager sharedInstance] rootViewController] visibleViewController];
    if( [visibleVC isKindOfClass:[IxViewController class]] )
    {
        IxViewController* IxVC = (IxViewController*) visibleVC;
        scrollView = [[IxVC containerControl] scrollView];
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
    if( ![_textField isFirstResponder] )
        return;
    
    CGFloat keyboardHeight = fmin(kbSize.height,kbSize.width);
    
    UIScrollView* scrollView = nil;
    UIViewController* visibleVC = [[[IxAppManager sharedInstance] rootViewController] visibleViewController];
    if( [visibleVC isKindOfClass:[IxViewController class]] )
    {
        IxViewController* IxVC = (IxViewController*) visibleVC;
        scrollView = [[IxVC containerControl] scrollView];
    }
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         UIEdgeInsets contentInsets = UIEdgeInsetsMake(scrollView.contentInset.top, 0.0f, keyboardHeight, 0.0f);
                         
                         scrollView.contentInset = contentInsets;
                         scrollView.scrollIndicatorInsets = contentInsets;
                         
                         CGRect aRect = visibleVC.view.frame;
                         aRect.size.height -= keyboardHeight;
                         
                         //scrollView converts the frame of subView.frame to the coordinate system of someOtherView
                         CGRect textFieldScreenFrame = [[self contentView] convertRect:[_textField frame] toView:nil];
                         
                         if (!CGRectContainsPoint(aRect, textFieldScreenFrame.origin) ) {
                             [scrollView scrollRectToVisible:_textField.frame animated:YES];
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


-(void)applyFunction:(NSString*)functionName withParameters:(IxPropertyContainer*)parameterContainer
{
    
    if( [functionName compare:@"keyboard.hide"] == NSOrderedSame )
    {
        NSLog(@"keyboard.hide");
        [_textField resignFirstResponder];
    }
    if( [functionName compare:@"keyboard.show"] == NSOrderedSame )
    {
        NSLog(@"keyboard.show");
        [_textField becomeFirstResponder];

    }
}

// MAY HAVE A REASON TO IMPLEMENT THIS LATER
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;
//{
//    return YES;
//}

@end
