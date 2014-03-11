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
#import "IXProperty.h"
#import "UITextField+IXAdditions.h"

// IXTextInput Properties
static NSString* const kIXFont = @"font";
static NSString* const kIXCursorColor = @"cursor.color";
static NSString* const kIXAutoCorrect = @"autocorrect";
static NSString* const kIXDismissOnReturn = @"dismiss_on_return";

static NSString* const kIXText = @"text";
static NSString* const kIXTextColor = @"text.color";
static NSString* const kIXTextPlaceholder = @"text.placeholder";
static NSString* const kIXTextPlaceholderColor = @"text.placeholder.color";
static NSString* const kIXTextAlignment = @"text.alignment";

static NSString* const kIXKeyboardAppearance = @"keyboard.appearance";
static NSString* const kIXKeyboardType = @"keyboard.type";
static NSString* const kIXKeyboardReturnKey = @"keyboard.return_key";

static NSString* const kIXInputRegexAllowed = @"input.regex.allowed";
static NSString* const kIXInputRegexDisAllowed = @"input.regex.disallowed";
static NSString* const kIXInputMax = @"input.max";
static NSString* const kIXInputTransform = @"input.transform";

// kIXInputTransform Types
static NSString* const kIXInputTransformCapitalized = @"capitalized";
static NSString* const kIXInputTransformLowercase = @"lowercase";
static NSString* const kIXInputTransformUppercase = @"uppercase";
static NSString* const kIXInputTransformUppercaseFirst = @"ucfirst";

// IXTextInput Functions
static NSString* const kIXKeyboardHide = @"keyboard_hide";
static NSString* const kIXKeyboardShow = @"keyboard_show";

// IXTextInput Events
static NSString* const kIXGotFocus = @"got_focus";
static NSString* const kIXLostFocus = @"lost_focus";
static NSString* const kIXReturnKeyPressed = @"return_key_pressed";
static NSString* const kIXTextChanged = @"text_changed";

static CGSize sIXKBSize;

@interface IXTextInput () <UITextFieldDelegate>

@property (nonatomic,assign) BOOL needsToRegisterForKeyboardNotifications;
@property (nonatomic,strong) UITextField* textField;
@property (nonatomic,strong) UIColor* defaultTextFieldTintColor;
@property (nonatomic,assign,getter = shouldDismissOnReturn) BOOL dismissOnReturn;

@property (nonatomic,assign) NSInteger inputMaxAllowedCharacters;
@property (nonatomic,strong) NSString* inputTransform;
@property (nonatomic,strong) NSString* inputAllowedRegexString;
@property (nonatomic,strong) NSString* inputDisallowedRegexString;

@property (nonatomic,strong) NSRegularExpression *inputAllowedRegex;
@property (nonatomic,strong) NSRegularExpression *inputDisallowedRegex;

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
    _defaultTextFieldTintColor = [_textField tintColor];

    _textField = [[UITextField alloc] initWithFrame:[[self contentView] bounds]];
    [_textField setBackgroundColor:[UIColor whiteColor]];
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
    
    [[self textField] setEnabled:[[self contentView] isEnabled]];
    
    NSString* placeHolderText = [[self propertyContainer] getStringPropertyValue:kIXTextPlaceholder defaultValue:nil];
    if( [placeHolderText length] > 0 )
    {
        UIColor* placeHolderTextColor = [[self propertyContainer] getColorPropertyValue:kIXTextPlaceholderColor defaultValue:[UIColor lightGrayColor]];
        NSAttributedString* attributedPlaceHolder = [[NSAttributedString alloc] initWithString:placeHolderText
                                                                                    attributes:@{NSForegroundColorAttributeName: placeHolderTextColor}];
        [[self textField] setAttributedPlaceholder:attributedPlaceHolder];
    }
    
    NSString* inputText = [[self propertyContainer] getStringPropertyValue:kIXText defaultValue:nil];
    if ( [inputText length] > 0 )
    {
        [[self textField] setText:inputText];
    }
    
    [[self textField] setFont:[[self propertyContainer] getFontPropertyValue:kIXFont defaultValue:[UIFont fontWithName:@"HelveticaNeue" size:20.0f]]];
    [[self textField] setTextColor:[[self propertyContainer] getColorPropertyValue:kIXTextColor defaultValue:[UIColor blackColor]]];
    [[self textField] setTintColor:[[self propertyContainer] getColorPropertyValue:kIXCursorColor defaultValue:[self defaultTextFieldTintColor]]];
    [[self textField] setAutocorrectionType:[[self propertyContainer] getBoolPropertyValue:kIXAutoCorrect defaultValue:YES]];
    [[self textField] setTextAlignment:[UITextField ix_textAlignmentFromString:[[self propertyContainer] getStringPropertyValue:kIXTextAlignment defaultValue:nil]]];
    [[self textField] setKeyboardAppearance:[UITextField ix_stringToKeyboardAppearance:[[self propertyContainer] getStringPropertyValue:kIXKeyboardAppearance defaultValue:kIX_DEFAULT]]];
    [[self textField] setKeyboardType:[UITextField ix_stringToKeyboardType:[[self propertyContainer] getStringPropertyValue:kIXKeyboardType defaultValue:kIX_DEFAULT]]];
    [[self textField] setReturnKeyType:[UITextField ix_stringToReturnKeyType:[[self propertyContainer] getStringPropertyValue:kIXKeyboardReturnKey defaultValue:kIX_DEFAULT]]];
    
    [self setDismissOnReturn:[[self propertyContainer] getBoolPropertyValue:kIXDismissOnReturn defaultValue:YES]];
    [self setInputMaxAllowedCharacters:[[self propertyContainer] getIntPropertyValue:kIXInputMax defaultValue:0]];
    [self setInputTransform:[[self propertyContainer] getStringPropertyValue:kIXInputTransform defaultValue:nil]];
    [self setInputDisallowedRegexString:[[self propertyContainer] getStringPropertyValue:kIXInputRegexDisAllowed defaultValue:nil]];

    [self setInputAllowedRegexString:[[self propertyContainer] getStringPropertyValue:kIXInputRegexAllowed defaultValue:nil]];
    if( [[self inputAllowedRegexString] length] > 1 )
    {
        NSMutableString *tmp = [[NSMutableString alloc] initWithString:[self inputAllowedRegexString]];
        [tmp insertString:@"^" atIndex:1];
        [self setInputAllowedRegexString:tmp];
    }
}

- (NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* readOnlyPropertyValue = nil;
    if( [propertyName isEqualToString:kIXText] )
    {
        readOnlyPropertyValue = [[self textField] text];
    }
    else
    {
        readOnlyPropertyValue = [super getReadOnlyPropertyValue:propertyName];
    }
    return readOnlyPropertyValue;
}

-(void)applyFunction:(NSString*)functionName withParameters:(IXPropertyContainer*)parameterContainer
{
    if( [functionName isEqualToString:kIXKeyboardHide] )
    {
        [[self textField] resignFirstResponder];
    }
    else if( [functionName isEqualToString:kIXKeyboardShow] )
    {
        [[self textField] becomeFirstResponder];
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
<<<<<<< HEAD
    
    [self setDismissOnReturn:[[self propertyContainer] getBoolPropertyValue:@"dismiss_on_return" defaultValue:YES]];
    
    [[self textField] setBackgroundColor:[UIColor whiteColor]];
    [[self textField] setTintColor:[UIColor redColor]];
    
    NSString* placeHolderText = [self.propertyContainer getStringPropertyValue:@"text.placeholder" defaultValue:@""];
    UIColor* placeHolderTextColor = [self.propertyContainer getColorPropertyValue:@"text.placeholder.color" defaultValue:[UIColor lightGrayColor]];
    NSAttributedString* attributedPlaceHolder = [[NSAttributedString alloc] initWithString:placeHolderText
                                                                                attributes:@{NSForegroundColorAttributeName: placeHolderTextColor}];
    [[self textField] setAttributedPlaceholder:attributedPlaceHolder];
    [[self textField] setTextColor:[self.propertyContainer getColorPropertyValue:@"text.color" defaultValue:[UIColor blackColor]]];
    [[self textField] setTintColor:[self.propertyContainer getColorPropertyValue:@"cursor.color" defaultValue:[self defaultTextFieldTintColor]]];
    
    UIFont* font = [[self propertyContainer] getFontPropertyValue:@"font" defaultValue:[UIFont fontWithName:@"HelveticaNeue" size:20.0f]];
    [[self textField] setFont:font];
=======
>>>>>>> b1f0e1e31ad532b3fb41e2ec3db7b0adaa89aa16
}

- (void)registerForKeyboardNotifications
{
    if( _needsToRegisterForKeyboardNotifications )
    {
        _needsToRegisterForKeyboardNotifications = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShown:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:[self textField]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillBeHidden:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:[self textField]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillChangeFrame:)
                                                     name:UIKeyboardDidChangeFrameNotification
                                                   object:[self textField]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textDidChange:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:[self textField]];
    }
}

-(void)unregisterForKeyboardNotifications
{
    if( !_needsToRegisterForKeyboardNotifications )
    {
        _needsToRegisterForKeyboardNotifications = YES;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillShowNotification
                                                      object:[self textField]];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillHideNotification
                                                      object:[self textField]];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardDidChangeFrameNotification
                                                      object:[self textField]];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UITextFieldTextDidChangeNotification
                                                      object:[self textField]];
    }
}

- (void)keyboardWillChangeFrame:(NSNotification*)aNotification
{
    sIXKBSize = [[aNotification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    double animationDuration = [[aNotification userInfo][UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [self adjustScrollViewForKeyboard:animationDuration];
}

- (void)keyboardWillShown:(NSNotification*)aNotification
{
    sIXKBSize = [[aNotification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    double animationDuration = [[aNotification userInfo][UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [self adjustScrollViewForKeyboard:animationDuration];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    double animationDuration = [[aNotification userInfo][UIKeyboardAnimationDurationUserInfoKey] doubleValue];

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
                             [scrollView scrollRectToVisible:[[self textField] frame] animated:YES];
                         }
                     }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self unregisterForKeyboardNotifications];
    
    [self setInputAllowedRegex:nil];
    [self setInputDisallowedRegex:nil];
    
    [[self actionContainer] executeActionsForEventNamed:kIXLostFocus];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self registerForKeyboardNotifications];
    [self adjustScrollViewForKeyboard:0.0f];
    
    [self setInputAllowedRegex:nil];
    [self setInputDisallowedRegex:nil];

    if( [[self inputAllowedRegexString] length] > 0 )
    {
        [self setInputAllowedRegex:[NSRegularExpression regularExpressionWithPattern:[self inputAllowedRegexString]
                                                                             options:NSRegularExpressionCaseInsensitive
                                                                               error:nil]];
    }
    if( [[self inputDisallowedRegexString] length] > 0 )
    {
        [self setInputDisallowedRegex:[NSRegularExpression regularExpressionWithPattern:[self inputDisallowedRegexString]
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:nil]];
    }
    
    [[self actionContainer] executeActionsForEventNamed:kIXGotFocus];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //JA: Added action for return key press
    [[self actionContainer] executeActionsForEventNamed:kIXReturnKeyPressed];

    BOOL shouldReturn = [self shouldDismissOnReturn];
    if( shouldReturn )
    {
        [textField resignFirstResponder];
        [self unregisterForKeyboardNotifications];
        [[self actionContainer] executeActionsForEventNamed:kIXLostFocus];
    }
    return shouldReturn;
}

- (void)textDidChange:(NSNotification*)aNotification
{
    NSString *inputText = [[self textField] text];
    
    NSInteger inputMaxAllowedCharacters = [self inputMaxAllowedCharacters];
    if( inputMaxAllowedCharacters > 0 && [inputText length] > inputMaxAllowedCharacters )
    {
        inputText = [inputText substringToIndex:inputMaxAllowedCharacters];
    }
    
    if( [self inputDisallowedRegex] )
    {
        inputText = [[self inputDisallowedRegex] stringByReplacingMatchesInString:inputText
                                                                          options:0
                                                                            range:NSMakeRange(0, [inputText length])
                                                                     withTemplate:@""];
    }
    if ( [self inputAllowedRegex] )
    {
        inputText = [[self inputAllowedRegex] stringByReplacingMatchesInString:inputText
                                                                       options:0
                                                                         range:NSMakeRange(0, [inputText length])
                                                                  withTemplate:@""];
    }
    
    NSString* inputTransform = [self inputTransform];
    if ( inputTransform )
    {
        if ([inputTransform isEqualToString:kIXInputTransformLowercase])
        {
            inputText = [inputText lowercaseString];
        }
        else if ([inputTransform isEqualToString:kIXInputTransformUppercase])
        {
            inputText = [inputText uppercaseString];
        }
        else if ([inputTransform isEqualToString:kIXInputTransformCapitalized])
        {
            inputText = [inputText capitalizedString];
        }
        else if ([inputTransform isEqualToString:kIXInputTransformUppercaseFirst])
        {
            inputText = [NSString stringWithFormat:@"%@%@",[[inputText substringToIndex:1] uppercaseString],[inputText substringFromIndex:1]];
        }
    }
    
<<<<<<< HEAD
    self.textField.text = inputText;
    [self.actionContainer executeActionsForEventNamed:@"text_changed"];
}

- (NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* readOnlyPropertyValue = nil;
    if( [propertyName isEqualToString:@"text"] )
    {
        readOnlyPropertyValue = [[self textField] text];
    }
    else
    {
        readOnlyPropertyValue = [super getReadOnlyPropertyValue:propertyName];
    }
    return readOnlyPropertyValue;
}

-(void)applyFunction:(NSString*)functionName withParameters:(IXPropertyContainer*)parameterContainer
{
    if( [functionName isEqualToString:@"keyboard_hide"] || [functionName isEqualToString:@"lose_focus"] )
    {
        [[self textField] resignFirstResponder];
    }
    else if( [functionName isEqualToString:@"keyboard_show"] || [functionName isEqualToString:@"focus"] )
    {
        [[self textField] becomeFirstResponder];
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
=======
    [[self textField] setText:inputText];
    [[self actionContainer] executeActionsForEventNamed:kIXTextChanged];
>>>>>>> b1f0e1e31ad532b3fb41e2ec3db7b0adaa89aa16
}

@end
