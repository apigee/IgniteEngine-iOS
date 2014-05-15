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
#import "IXNavigateAction.h"
#import "UITextField+IXAdditions.h"

// IXTextInput Properties
static NSString* const kIXFont = @"font";
static NSString* const kIXCursorColor = @"cursor.color";
static NSString* const kIXAutoCorrect = @"autocorrect";
static NSString* const kIXDismissOnReturn = @"dismiss_on_return";
static NSString* const kIXLayoutToScroll = @"layout_to_scroll";
static NSString* const kIXKeyboardAdjustsScreen = @"keyboard_adjusts_screen";
static NSString* const kIXIsMultiLine = @"is_multiline";

static NSString* const kIXInitialText = @"initial_text";
static NSString* const kIXTextColor = @"text.color";
static NSString* const kIXTextPlaceholder = @"text.placeholder";
static NSString* const kIXTextPlaceholderColor = @"text.placeholder.color";
static NSString* const kIXTextAlignment = @"text.alignment";
static NSString* const kIXBackgroundColor = @"background.color";

static NSString* const kIXKeyboardAppearance = @"keyboard.appearance";
static NSString* const kIXKeyboardType = @"keyboard.type";
static NSString* const kIXKeyboardReturnKey = @"keyboard.return_key";

static NSString* const kIXInputRegexAllowed = @"input.regex.allowed";
static NSString* const kIXInputRegexDisAllowed = @"input.regex.disallowed";
static NSString* const kIXInputMax = @"input.max";
static NSString* const kIXInputTransform = @"input.transform";

static NSString* const kIXFilterDatasource = @"filter_datasource"; //not implemented

// kIXInputTransform Types
static NSString* const kIXInputTransformCapitalize = @"capitalize";
static NSString* const kIXInputTransformLowercase = @"lowercase";
static NSString* const kIXInputTransformUppercase = @"uppercase";
static NSString* const kIXInputTransformUppercaseFirst = @"ucfirst";

// IXTextInput ReadOnly Properties
static NSString* const kIXText = @"text"; // To set the text use the kIXSetText function.

// IXTextInput Functions
static NSString* const kIXSetText = @"set_text"; // Parameter is kIXText.
static NSString* const kIXKeyboardHide = @"keyboard_hide";
static NSString* const kIXKeyboardShow = @"keyboard_show";
static NSString* const kIXFocus = @"focus";

// IXTextInput Events
static NSString* const kIXGotFocus = @"got_focus";
static NSString* const kIXLostFocus = @"lost_focus";
static NSString* const kIXReturnKeyPressed = @"return_key_pressed";
static NSString* const kIXTextChanged = @"text_changed";

static CGSize sIXKBSize;
static CGFloat const kIXKeyboardAnimationDefaultDuration = 0.25f;
static CGFloat const kIXMaxPreferredHeightForTextInput = 40.0f;
static NSString* const kIXNewLineString = @"\n";

@interface IXTextInput () <UITextFieldDelegate,UITextViewDelegate>

@property (nonatomic,strong) UITextField* textField;
@property (nonatomic,strong) UITextView* textView;
@property (nonatomic,strong) UIColor* defaultTextInputTintColor;

@property (nonatomic,assign,getter = isFirstLoad) BOOL firstLoad;
@property (nonatomic,assign,getter = isUsingUITextView) BOOL usingUITextView;
@property (nonatomic,assign,getter = shouldDismissOnReturn) BOOL dismissOnReturn;
@property (nonatomic,assign,getter = isRegisteredForKeyboardNotifications) BOOL registeredForKeyboardNotifications;

@property (nonatomic,weak) IXLayout* layoutToScroll;
@property (nonatomic,assign) BOOL adjustsScrollWithScreen;
@property (nonatomic,assign) CGSize layoutContentSizeAtStartOfEditing;

@property (nonatomic,assign) NSInteger inputMaxAllowedCharacters;
@property (nonatomic,strong) NSString* inputTransform;
@property (nonatomic,strong) NSString* inputAllowedRegexString;
@property (nonatomic,strong) NSString* inputDisallowedRegexString;
@property (nonatomic,strong) NSRegularExpression *inputAllowedRegex;
@property (nonatomic,strong) NSRegularExpression *inputDisallowedRegex;

@property (nonatomic,strong) NSArray* filterDatasource; //not implemented

@end

@implementation IXTextInput

-(void)dealloc
{
    [self unregisterForKeyboardNotifications];
    [_textField setDelegate:nil];
    [_textView setDelegate:nil];
}

-(void)buildView
{
    [super buildView];
    
    _firstLoad = YES;
    _adjustsScrollWithScreen = YES;
    _registeredForKeyboardNotifications = NO;
}

-(void)createTextInputView
{
    if( [self isFirstLoad] )
    {
        [self setFirstLoad:NO];
        
        NSString* initialText = [[self propertyContainer] getStringPropertyValue:kIXInitialText defaultValue:nil];
        
        [self setUsingUITextView:[[self propertyContainer] getBoolPropertyValue:kIXIsMultiLine defaultValue:NO]];
        
        if( [self isUsingUITextView] )
        {
            [self setTextView:[[UITextView alloc] initWithFrame:[[self contentView] bounds]]];
            [self setDefaultTextInputTintColor:[[self textView] tintColor]];

            [[self textView] setDelegate:self];
            [[self textView] setBackgroundColor:[UIColor whiteColor]];
            [[self textView] setText:initialText];
            
            [[self contentView] addSubview:[self textView]];
        }
        else
        {
            [self setTextField:[[UITextField alloc] initWithFrame:[[self contentView] bounds]]];
            [self setDefaultTextInputTintColor:[[self textField] tintColor]];

            [[self textField] setDelegate:self];
            [[self textField] setBackgroundColor:[UIColor whiteColor]];
            [[self textField] setText:initialText];
            
            [[self contentView] addSubview:[self textField]];
        }
    }
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    CGSize returnSize = CGSizeMake(size.width, kIXMaxPreferredHeightForTextInput);
    
    CGFloat textInputHeight = 0.0f;
    if( [self isUsingUITextView] )
    {
        textInputHeight = [[self textView] frame].size.height;
    }
    else
    {
        textInputHeight = [[self textField] frame].size.height;
    }
    
    returnSize.height = fmax(textInputHeight,kIXMaxPreferredHeightForTextInput);
    return returnSize;
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    if( [self isUsingUITextView] )
    {
        [[self textView] setFrame:rect];
    }
    else
    {
        [[self textField] setFrame:rect];
    }
}

-(void)applySettings
{
    [super applySettings];
    
    [self createTextInputView];
    
    UIFont* font = [[self propertyContainer] getFontPropertyValue:kIXFont defaultValue:[UIFont fontWithName:@"HelveticaNeue" size:20.0f]];
    UIColor* textColor = [[self propertyContainer] getColorPropertyValue:kIXTextColor defaultValue:[UIColor blackColor]];
    UIColor* tintColor = [[self propertyContainer] getColorPropertyValue:kIXCursorColor defaultValue:[self defaultTextInputTintColor]];
    UIColor* backgroundColor = [[self propertyContainer] getColorPropertyValue:kIXBackgroundColor defaultValue:[UIColor whiteColor]];
    NSTextAlignment textAlignment = [UITextField ix_textAlignmentFromString:[[self propertyContainer] getStringPropertyValue:kIXTextAlignment defaultValue:nil]];
    UITextAutocorrectionType autoCorrectionType = [UITextField ix_booleanToTextAutocorrectionType:[[self propertyContainer] getBoolPropertyValue:kIXAutoCorrect defaultValue:YES]];

    UIKeyboardAppearance keyboardAppearance = [UITextField ix_stringToKeyboardAppearance:[[self propertyContainer] getStringPropertyValue:kIXKeyboardAppearance defaultValue:kIX_DEFAULT]];
    UIKeyboardType keyboardType = [UITextField ix_stringToKeyboardType:[[self propertyContainer] getStringPropertyValue:kIXKeyboardType defaultValue:kIX_DEFAULT]];
    UIReturnKeyType returnKeyType = [UITextField ix_stringToReturnKeyType:[[self propertyContainer] getStringPropertyValue:kIXKeyboardReturnKey defaultValue:kIX_DEFAULT]];
    
    if( ![self isUsingUITextView] )
    {
        [[self textField] setEnabled:[[self contentView] isEnabled]];
        
        NSString* placeHolderText = [[self propertyContainer] getStringPropertyValue:kIXTextPlaceholder defaultValue:nil];
        if( [placeHolderText length] > 0 )
        {
            UIColor* placeHolderTextColor = [[self propertyContainer] getColorPropertyValue:kIXTextPlaceholderColor defaultValue:[UIColor lightGrayColor]];
            NSAttributedString* attributedPlaceHolder = [[NSAttributedString alloc] initWithString:placeHolderText
                                                                                        attributes:@{NSForegroundColorAttributeName: placeHolderTextColor}];
            [[self textField] setAttributedPlaceholder:attributedPlaceHolder];
        }
        
        [[self textField] setFont:font];
        [[self textField] setTextColor:textColor];
        [[self textField] setTintColor:tintColor];
        [[self textField] setAutocorrectionType:autoCorrectionType];
        [[self textField] setTextAlignment:textAlignment];
        [[self textField] setKeyboardAppearance:keyboardAppearance];
        [[self textField] setKeyboardType:keyboardType];
        [[self textField] setReturnKeyType:returnKeyType];
        [[self textField] setBackgroundColor:backgroundColor];
    }
    else
    {
        [[self textView] setFont:font];
        [[self textView] setTextColor:textColor];
        [[self textView] setTintColor:tintColor];
        [[self textView] setAutocorrectionType:autoCorrectionType];
        [[self textView] setTextAlignment:textAlignment];
        [[self textView] setKeyboardAppearance:keyboardAppearance];
        [[self textView] setKeyboardType:keyboardType];
        [[self textView] setReturnKeyType:returnKeyType];
        [[self textView] setBackgroundColor:backgroundColor];
    }
    
    [self setDismissOnReturn:[[self propertyContainer] getBoolPropertyValue:kIXDismissOnReturn defaultValue:YES]];
    [self setInputMaxAllowedCharacters:[[self propertyContainer] getIntPropertyValue:kIXInputMax defaultValue:0]];
    [self setInputTransform:[[self propertyContainer] getStringPropertyValue:kIXInputTransform defaultValue:nil]];
    [self setInputDisallowedRegexString:[[self propertyContainer] getStringPropertyValue:kIXInputRegexDisAllowed defaultValue:nil]];
    [self setFilterDatasource:[[self propertyContainer] getCommaSeperatedArrayListValue:kIXFilterDatasource defaultValue:nil]];
    
    [self setInputAllowedRegexString:[[self propertyContainer] getStringPropertyValue:kIXInputRegexAllowed defaultValue:nil]];
    if( [[self inputAllowedRegexString] length] > 1 )
    {
        NSMutableString *positiveAssertion = [[NSMutableString alloc] initWithString:[self inputAllowedRegexString]];
        [positiveAssertion insertString:@"^" atIndex:1];
        [self setInputAllowedRegexString:positiveAssertion];
    }
    
    NSString* layoutToScrollID = [[self propertyContainer] getStringPropertyValue:kIXLayoutToScroll defaultValue:nil];
    IXLayout* layoutToScroll = nil;
    if( [layoutToScrollID length] > 0 )
    {
        IXBaseControl* controlFound = [[[self sandbox] getAllControlsWithID:layoutToScrollID] firstObject];
        if( [controlFound isKindOfClass:[IXLayout class]] )
        {
            layoutToScroll = (IXLayout*)controlFound;
        }
    }
    
    [self setAdjustsScrollWithScreen:[[self propertyContainer] getBoolPropertyValue:kIXKeyboardAdjustsScreen defaultValue:(layoutToScroll != nil)]];
    if( layoutToScroll == nil && [self adjustsScrollWithScreen] )
    {
        layoutToScroll = [[[self sandbox] viewController] containerControl];
    }
    
    [self setLayoutToScroll:layoutToScroll];
}

- (NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* readOnlyPropertyValue = nil;
    if( [propertyName isEqualToString:kIXText] )
    {
        if( [self isUsingUITextView] )
        {
            readOnlyPropertyValue = [[self textView] text];
        }
        else
        {
            readOnlyPropertyValue = [[self textField] text];
        }
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
        if( [self isUsingUITextView] )
        {
            [[self textView] resignFirstResponder];
        }
        else
        {
            [[self textField] resignFirstResponder];
        }
    }
    else if( [functionName isEqualToString:kIXKeyboardShow] || [functionName isEqualToString:kIXFocus] )
    {
        if( [self isUsingUITextView] )
        {
            [[self textView] becomeFirstResponder];
        }
        else
        {
            [[self textField] becomeFirstResponder];
        }
    }
    else if( [functionName isEqualToString:kIXSetText] )
    {
        NSString* text = [parameterContainer getStringPropertyValue:kIXText defaultValue:nil];
        NSString* placeholderText = [parameterContainer getStringPropertyValue:kIXTextPlaceholder defaultValue:nil];
        
        if( [self isUsingUITextView] )
        {
            if( text != nil )
            {
                [[self textView] setText:text];
            }
        }
        else
        {
            if( text != nil )
            {
                [[self textField] setText:text];
            }
            if( placeholderText != nil )
            {
                [[self propertyContainer] addProperty:[IXProperty propertyWithPropertyName:kIXTextPlaceholder rawValue:placeholderText] replaceOtherPropertiesWithTheSameName:YES];
                [[self textField] setPlaceholder:placeholderText];
            }
        }
        
        
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

- (void)registerForKeyboardNotifications
{
    if( ![self isRegisteredForKeyboardNotifications] )
    {
        [self setRegisteredForKeyboardNotifications:YES];
        
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
        if( [self isUsingUITextView] )
        {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(textDidChange:)
                                                         name:UITextViewTextDidChangeNotification
                                                       object:nil];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(textDidChange:)
                                                         name:UITextFieldTextDidChangeNotification
                                                       object:nil];
        }
        
    }
}

-(void)unregisterForKeyboardNotifications
{
    if( [self isRegisteredForKeyboardNotifications] )
    {
        [self setRegisteredForKeyboardNotifications:NO];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillShowNotification
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillHideNotification
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardDidChangeFrameNotification
                                                      object:nil];
        if( [self isUsingUITextView] )
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:UITextViewTextDidChangeNotification
                                                          object:nil];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:UITextFieldTextDidChangeNotification
                                                          object:nil];
        }
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
    if( [self adjustsScrollWithScreen] )
    {
        double animationDuration = [[aNotification userInfo][UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        UIView* textInputView = nil;
        if( [self isUsingUITextView] ) {
            textInputView = [self textView];
        }
        else {
            textInputView = [self textField];
        }
        
        UIScrollView* scrollView = [[self layoutToScroll] scrollView];
        
        CGFloat keyboardHeight = fmin(sIXKBSize.height,sIXKBSize.width);
        
        CGPoint point = [scrollView contentOffset];
        point.y += [textInputView bounds].size.height - keyboardHeight;
        
        if( point.y < 0.0f )
            point.y = 0.0f;
        
        [UIView animateWithDuration:((animationDuration > 0.0f) ? animationDuration : kIXKeyboardAnimationDefaultDuration)
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             
                             [scrollView setContentSize:[self layoutContentSizeAtStartOfEditing]];
                             [scrollView setContentOffset:point animated:YES];
                             
                         } completion:nil];
    }
}

-(void)adjustScrollViewForKeyboard:(float)animationDuration
{
    if( ( ![[self textView] isFirstResponder] && ![[self textField] isFirstResponder] ) || ![self adjustsScrollWithScreen] )
        return;
    
    CGFloat keyboardHeight = fmin(sIXKBSize.height,sIXKBSize.width);
    if( keyboardHeight > 0 )
    {
        UIScrollView* scrollView = [[self layoutToScroll] scrollView];
        UIView* textInputView = nil;
        if( [self isUsingUITextView] )
        {
            textInputView = [self textView];
        }
        else
        {
            textInputView = [self textField];
        }
        
        CGRect textInputBounds = [textInputView bounds];
        CGRect convertedTextInputBounds = [textInputView convertRect:textInputBounds toView:scrollView];
        CGFloat scrollViewHeight = [scrollView bounds].size.height;
        
        CGPoint point = convertedTextInputBounds.origin;
        point.x = 0.0f;
        point.y -= scrollViewHeight - keyboardHeight - textInputBounds.size.height;
        
        //    if( CGRectGetMaxY((convertedTextInputBounds)) > scrollViewHeight - keyboardHeight + scrollView.contentOffset.y )
        //    {
        [UIView animateWithDuration:((animationDuration > 0.0f) ? animationDuration : kIXKeyboardAnimationDefaultDuration)
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             if( CGRectGetMaxY((convertedTextInputBounds)) > scrollViewHeight - keyboardHeight + scrollView.contentOffset.y )
                             {
                                 [scrollView setContentSize:CGSizeMake([scrollView contentSize].width,scrollView.contentSize.height + keyboardHeight)];
                             }
                             [scrollView setContentOffset:point animated:NO];
                         } completion:nil];
        //    }

    }
}

- (void)textInputDidEndEditing:(id<UITextInput>)textInput
{
    if( [self adjustsScrollWithScreen] )
    {
        UIScrollView* scrollView = [[self layoutToScroll] scrollView];
        [scrollView setContentSize:[self layoutContentSizeAtStartOfEditing]];
    }
    
    [self unregisterForKeyboardNotifications];
    
    [self setInputAllowedRegex:nil];
    [self setInputDisallowedRegex:nil];
    
    // Only fire actions if we arent navigating.
    // Navigating automatically fires the resign of the keyboard so lets just not worry about actions associated with it.
    if( ![IXNavigateAction isAttemptingNavigation] )
    {
        [[self actionContainer] executeActionsForEventNamed:kIXLostFocus];
    }
}

-(void)textInputDidBeginEditing:(id<UITextInput>)textInput
{
    if( [self adjustsScrollWithScreen] )
    {
        UIScrollView* scrollView = [[self layoutToScroll] scrollView];
        [self setLayoutContentSizeAtStartOfEditing:[scrollView contentSize]];
    }
    
    [self registerForKeyboardNotifications];
    [self adjustScrollViewForKeyboard:kIXKeyboardAnimationDefaultDuration];
    
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

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self textInputDidEndEditing:textView];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self textInputDidEndEditing:textField];
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [self textInputDidBeginEditing:textView];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self textInputDidBeginEditing:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [self handleReturnKeyPressed:textField];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return (![text isEqualToString:kIXNewLineString]) ? YES : (![self handleReturnKeyPressed:textView]);
}

- (BOOL)handleReturnKeyPressed:(UIResponder*)textInput
{
    [[self actionContainer] executeActionsForEventNamed:kIXReturnKeyPressed];

    BOOL shouldDismiss = [self shouldDismissOnReturn];
    if( shouldDismiss )
    {
        [textInput resignFirstResponder];
        [self unregisterForKeyboardNotifications];
        [[self actionContainer] executeActionsForEventNamed:kIXLostFocus];
    }
    return shouldDismiss;
}

- (void)textDidChange:(NSNotification*)aNotification
{
    if( ![[self textView] isFirstResponder] && ![[self textField] isFirstResponder] )
        return;
    
    NSString *inputText = nil;
    if( [self isUsingUITextView] )
    {
        inputText = [[self textView] text];
    }
    else
    {
        inputText = [[self textField] text];
    }
    
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
                                                                     withTemplate:kIX_EMPTY_STRING];
    }
    if ( [self inputAllowedRegex] )
    {
        inputText = [[self inputAllowedRegex] stringByReplacingMatchesInString:inputText
                                                                       options:0
                                                                         range:NSMakeRange(0, [inputText length])
                                                                  withTemplate:kIX_EMPTY_STRING];
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
        else if ([inputTransform isEqualToString:kIXInputTransformCapitalize])
        {
            inputText = [inputText capitalizedString];
        }
        else if ([inputTransform isEqualToString:kIXInputTransformUppercaseFirst])
        {
            if (inputText.length > 0)
                inputText = [NSString stringWithFormat:@"%@%@",[[inputText substringToIndex:1] uppercaseString],[inputText substringFromIndex:1]];
        }
    }
    
    if( [self isUsingUITextView] )
    {
        [[self textView] setText:inputText];
    }
    else
    {
        [[self textField] setText:inputText];
    }
    
    [[self actionContainer] executeActionsForEventNamed:kIXTextChanged];
}

@end
