//
//  IXTextInputControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/15/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
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
 
 Capture input from the user
 

 <div id="container">
 <a href="../images/IXTextInput.png" data-imagelightbox="c"><img src="../images/IXTextInput.png" alt=""></a>
 
</div>
 
 */

/*
 *      /Docs
 *
 */

#import "IXTextInput.h"

#import "IXLayout.h"
#import "IXAppManager.h"
#import "IXNavigationViewController.h"
#import "IXViewController.h"
#import "IXClickableScrollView.h"
#import "IXProperty.h"
#import "IXNavigateAction.h"
#import "Formatter.h"
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
static NSString* const kIXClearsOnBeginEditing = @"clears_on_begin_editing"; // Only works on non multiline input.
static NSString* const kIXRightImage = @"image.right"; // Must use full path within assets (aka "assets/images/image.png" ). Only works on non multiline input.
static NSString* const kIXLeftImage = @"image.left"; // Must use full path within assets (aka "assets/images/image.png" ). Only works on non multiline input.
static NSString* const kIXBackgroundImage = @"image.background";
static NSString* const kIXHidesImagesWhenEmpty = @"image.hides_when_empty"; // Only works on non multiline input.

static NSString* const kIXKeyboardAppearance = @"keyboard.appearance";
static NSString* const kIXKeyboardType = @"keyboard.type";
static NSString* const kIXKeyboardPadding = @"keyboard.padding";
static NSString* const kIXKeyboardReturnKey = @"keyboard.return_key";

IX_STATIC_CONST_STRING kIXInputFormatCurrency = @"input.format.currency";
IX_STATIC_CONST_STRING kIXInputFormatCreditCard = @"input.format.credit_card";
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
static NSString* const kIXImageRightTapped = @"image.right.tapped";
static NSString* const kIXImageLeftTapped = @"image.left.tapped";

// NSCoding Key Constants
static NSString* const kIXTextFieldNSCodingKey = @"textField";
static NSString* const kIXTextViewNSCodingKey = @"textView";

static CGSize sIXKBSize;
static CGFloat const kIXKeyboardAnimationDefaultDuration = 0.25f;
static CGFloat const kIXMaxPreferredHeightForTextInput = 40.0f;
static NSString* const kIXNewLineString = @"\n";

@interface IXTextInput () <UITextFieldDelegate,UITextViewDelegate>

@property (nonatomic,strong) UIImageView* backgroundImage;
@property (nonatomic,strong) UITextField* textField;
@property (nonatomic,strong) UITextView* textView;
@property (nonatomic,strong) UIColor* defaultTextInputTintColor;

@property (nonatomic,assign,getter = isFirstLoad) BOOL firstLoad;
@property (nonatomic,assign,getter = isUsingUITextView) BOOL usingUITextView;
@property (nonatomic,assign,getter = shouldDismissOnReturn) BOOL dismissOnReturn;
@property (nonatomic,assign,getter = shouldHideImagesWhenEmpty) BOOL hideImagesWhenEmpty;
@property (nonatomic,assign,getter = isRegisteredForKeyboardNotifications) BOOL registeredForKeyboardNotifications;

@property (nonatomic,weak) IXLayout* layoutToScroll;
@property (nonatomic,assign) BOOL adjustsScrollWithScreen;
@property (nonatomic,assign) CGFloat keyboardPadding;
@property (nonatomic,assign) CGSize layoutContentSizeAtStartOfEditing;

@property (nonatomic,assign) BOOL inputFormatCurrency;
@property (nonatomic,assign) BOOL inputFormatCreditCard;

@property (nonatomic,assign) NSString *previousTextFieldContent;
@property (nonatomic,assign) UITextRange *previousSelection;

@property (nonatomic,assign) NSInteger inputMaxAllowedCharacters;
@property (nonatomic,strong) NSString* inputTransform;
@property (nonatomic,strong) NSString* inputAllowedRegexString;
@property (nonatomic,strong) NSString* inputDisallowedRegexString;
@property (nonatomic,strong) NSRegularExpression *inputAllowedRegex;
@property (nonatomic,strong) NSRegularExpression *inputDisallowedRegex;

@property (nonatomic,strong) NSArray* filterDatasource; //not implemented

@end

@implementation IXTextInput

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

    @param font Text font<br>*(string)*
    @param cursor.color Cursor color<br>*(color)*
    @param autocorrect Enables or disables system autocorrect *(default: TRUE)*<br>*(bool)*
    @param dismiss_on_return Enables automatic closing of keyboard when return key pressed *(default: FALSE)*<br>*(bool)*
    @param layout_to_scroll Array of reference pointers of view(s) that should scroll when keyboard appears<br>*(ref)*
    @param keyboard_adjusts_screen Sets whether the keyboard appearing should automatically adjust the current view when<br>*(bool)*
    @param is_multiline Sets the input to allow multiple lines of text<br>*(bool)*
    @param initial_text Initial text present in input (not placeholder!)<br>*(string)*
    @param text.color Text color<br>*(color)*
    @param text.placeholder Placeholder text (re-appears when input is empty)<br>*(string)*
    @param text.placeholder.color Color of placeholder text<br>*(color)*
    @param text.alignment Text alignment (left, center, right, justified)<br>*(string)*
    @param background.color Background color text input view<br>*(color)*
    @param clears_on_begin_editing Clears text when input becomes first responder (only works on non-multiline input) *(default: FALSE)*<br>*(bool)*
    @param image.left Left image – must use relative path including assets/ (only available on multiline input)<br>*(path)*
    @param image.right Right image – must use relative path including assets/ (only available on multiline input)<br>*(path)*
    @param image.background <br>*(????)*
    @param image.hides_when_empty Sets whether defined image should hide when text is empty (only works on multiline input)<br>*(bool)*
    @param keyboard.appearance Keyboard tint (light, dark, default) *(default: default)*<br>*(string)*
    @param keyboard.type Keyboard type (email, number, phone, url, decimal, name_phone, numbers_punctuation, default) *(default: default)*<br>*(string)*
    @param keyboard.padding Keyboard padding *(default: 0)*<br>*(integer)*
    @param keyboard.return_key Keyboard return key type (go, next, search, done, join, send, route, emergency, google, yahoo) *(default: default)*<br>*(string)*
    @param input.format.currency Sets whether the input should be formatted as currency *(default: FALSE)*<br>*(bool)*
    @param input.format.credit_card Sets whether the input should be formatted as a credit card *(default: FALSE)*<br>*(bool)*
    @param input.regex.allowed A regular expression of explicitly allowed characters<br>*(regex)*
    @param input.regex.disallowed A regular expression of explicitly disallowed characters<br>*(regex)*
    @param input.max Maximum allowed number of characters<br>*(integer)*
    @param input.transform Text transform (capitalize, lowercase, uppercase, ucfirst)<br>*(string)*

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

 @param text Current text value of the text input control (to set the text use the kIXSetText function)<br>*(string)*

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


    @param got_focus Fires when the input control becomes first responder
    @param lost_focus Fires when the input control loses focus
    @param return_key_pressed Fires when the user selects the return key
    @param text_changed Fires when text is changed
    @param image.right.tapped Fires when the right-hand image is tapped
    @param image.left.tapped Fires when the left-hand image is tapped

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


    @param set_text 
 
 <pre class="brush: js; toolbar: false;">
 
 </pre>

    @param keyboard_hide 
 
 <pre class="brush: js; toolbar: false;">
 
 </pre>

    @param keyboard_show, focus 
 
 <pre class="brush: js; toolbar: false;">
 
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
    [self unregisterForKeyboardNotifications];
    [_textField setDelegate:nil];
    [_textView setDelegate:nil];
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:[self textView] forKey:kIXTextViewNSCodingKey];
    [aCoder encodeObject:[self textField] forKey:kIXTextFieldNSCodingKey];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if( self )
    {
        [self setTextView:[aDecoder decodeObjectForKey:kIXTextViewNSCodingKey]];
        [self setTextField:[aDecoder decodeObjectForKey:kIXTextFieldNSCodingKey]];
    }
    return self;
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
        
        [self setBackgroundImage:[[UIImageView alloc] initWithFrame:CGRectZero]];
        [[self contentView] addSubview:[self backgroundImage]];
        
        NSString* initialText = [[self propertyContainer] getStringPropertyValue:kIXInitialText defaultValue:nil];
        
        [self setUsingUITextView:[[self propertyContainer] getBoolPropertyValue:kIXIsMultiLine defaultValue:NO]];
        
        if( [self isUsingUITextView] )
        {
            if( [self textView] == nil )
            {
                [self setTextView:[[UITextView alloc] initWithFrame:[[self contentView] bounds]]];
                [[self textView] setText:initialText];
            }
            [self setDefaultTextInputTintColor:[[self textView] tintColor]];
            
            [[self textView] setDelegate:self];
            [[self textView] setBackgroundColor:[UIColor whiteColor]];
            
            [[self contentView] addSubview:[self textView]];
        }
        else
        {
            if( [self textField] == nil )
            {
                [self setTextField:[[UITextField alloc] initWithFrame:[[self contentView] bounds]]];
                [[self textField] setText:initialText];
            }
            [self setDefaultTextInputTintColor:[[self textField] tintColor]];
            
            [[self textField] setDelegate:self];
            [[self textField] setBackgroundColor:[UIColor whiteColor]];
            
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
    
    [[self backgroundImage] setFrame:rect];
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
    
    [self setHideImagesWhenEmpty:[[self propertyContainer] getBoolPropertyValue:kIXHidesImagesWhenEmpty defaultValue:NO]];
    
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
        
        [[self textField] setClearsOnBeginEditing:[[self propertyContainer] getBoolPropertyValue:kIXClearsOnBeginEditing defaultValue:NO]];
        
        [[self textField] setRightViewMode:UITextFieldViewModeAlways];
        [[self textField] setLeftViewMode:UITextFieldViewModeAlways];
        
        [[self textField] setRightView:nil];
        [[self textField] setLeftView:nil];
        
        NSString* rightImage = [[self propertyContainer] getStringPropertyValue:kIXRightImage defaultValue:nil];
        if( [rightImage length] > 0 )
        {
            UIImageView* rightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:rightImage]];
            [rightImageView setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightViewTapDetected:)];
            [tapGestureRecognizer setNumberOfTapsRequired:1];
            [rightImageView addGestureRecognizer:tapGestureRecognizer];
            
            [[self textField] setRightView:rightImageView];
        }
        
        NSString* leftImage = [[self propertyContainer] getStringPropertyValue:kIXLeftImage defaultValue:nil];
        if( [leftImage length] > 0 )
        {
            UIImageView* leftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:leftImage]];
            [leftImageView setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftViewTapDetected:)];
            [tapGestureRecognizer setNumberOfTapsRequired:1];
            [leftImageView addGestureRecognizer:tapGestureRecognizer];
            
            [[self textField] setLeftView:leftImageView];
        }
        
        if( [self shouldHideImagesWhenEmpty] && [[[self textField] text] length] <= 0 )
        {
            [[self backgroundImage] setHidden:YES];
            [[[self textField] rightView] setHidden:YES];
            [[[self textField] leftView] setHidden:YES];
        }
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
    
    __weak typeof(self) weakSelf = self;
    [[self propertyContainer] getImageProperty:kIXBackgroundImage
                                  successBlock:^(UIImage *image) {
                                      [[weakSelf backgroundImage] setImage:image];
                                  } failBlock:^(NSError *error) {
                                      [[weakSelf backgroundImage] setImage:nil];
                                  }];
    
    [self setDismissOnReturn:[[self propertyContainer] getBoolPropertyValue:kIXDismissOnReturn defaultValue:YES]];
    [self setInputMaxAllowedCharacters:[[self propertyContainer] getIntPropertyValue:kIXInputMax defaultValue:0]];
    [self setInputTransform:[[self propertyContainer] getStringPropertyValue:kIXInputTransform defaultValue:nil]];
    [self setInputDisallowedRegexString:[[self propertyContainer] getStringPropertyValue:kIXInputRegexDisAllowed defaultValue:nil]];
    [self setFilterDatasource:[[self propertyContainer] getCommaSeperatedArrayListValue:kIXFilterDatasource defaultValue:nil]];
    
    [self setInputFormatCurrency:[[self propertyContainer] getBoolPropertyValue:kIXInputFormatCurrency defaultValue:NO]];
    
    [self setInputFormatCreditCard:[[self propertyContainer] getBoolPropertyValue:kIXInputFormatCreditCard defaultValue:NO]];
    
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
    
    [self setKeyboardPadding:[[self propertyContainer] getFloatPropertyValue:kIXKeyboardPadding defaultValue:0.0f]];
    [self setLayoutToScroll:layoutToScroll];
    
    
}

-(void)rightViewTapDetected:(UITapGestureRecognizer*)tapRecognizer
{
    [[self actionContainer] executeActionsForEventNamed:kIXImageRightTapped];
}

-(void)leftViewTapDetected:(UITapGestureRecognizer*)tapRecognizer
{
    [[self actionContainer] executeActionsForEventNamed:kIXImageLeftTapped];
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
            
            if( [self shouldHideImagesWhenEmpty] )
            {
                if( [[[self textField] text] length] > 0 )
                {
                    [[self backgroundImage] setHidden:NO];
                    [[self textField].rightView setHidden:NO];
                    [[[self textField] leftView] setHidden:NO];
                }
                else
                {
                    [[self backgroundImage] setHidden:YES];
                    [[self textField].rightView setHidden:YES];
                    [[[self textField] leftView] setHidden:YES];
                }
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
        point.y += [textInputView bounds].size.height - keyboardHeight - [self keyboardPadding];
        
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
        point.y -= scrollViewHeight - keyboardHeight - textInputBounds.size.height - [self keyboardPadding];
        
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

// Credit Card Formatting
// Version 1.2
// Source and explanation: http://stackoverflow.com/a/19161529/1709587
-(void)reformatAsCardNumber:(UITextField *)textField
{
    // In order to make the cursor end up positioned correctly, we need to
    // explicitly reposition it after we inject spaces into the text.
    // targetCursorPosition keeps track of where the cursor needs to end up as
    // we modify the string, and at the end we set the cursor position to it.
    NSUInteger targetCursorPosition =
    [textField offsetFromPosition:textField.beginningOfDocument
                       toPosition:textField.selectedTextRange.start];
    
    NSString *cardNumberWithoutSpaces =
    [self removeNonDigits:textField.text
andPreserveCursorPosition:&targetCursorPosition];
    
    if ([cardNumberWithoutSpaces length] > 19) {
        // If the user is trying to enter more than 19 digits, we prevent
        // their change, leaving the text field in  its previous state.
        // While 16 digits is usual, credit card numbers have a hard
        // maximum of 19 digits defined by ISO standard 7812-1 in section
        // 3.8 and elsewhere. Applying this hard maximum here rather than
        // a maximum of 16 ensures that users with unusual card numbers
        // will still be able to enter their card number even if the
        // resultant formatting is odd.
        [textField setText:_previousTextFieldContent];
        textField.selectedTextRange = _previousSelection;
        return;
    }
    
    NSString *cardNumberWithSpaces =
    [self insertSpacesEveryFourDigitsIntoString:cardNumberWithoutSpaces
                      andPreserveCursorPosition:&targetCursorPosition];
    
    textField.text = cardNumberWithSpaces;
    UITextPosition *targetPosition =
    [textField positionFromPosition:[textField beginningOfDocument]
                             offset:targetCursorPosition];
    
    [textField setSelectedTextRange:
     [textField textRangeFromPosition:targetPosition
                           toPosition:targetPosition]
     ];
}

/*
 Removes non-digits from the string, decrementing `cursorPosition` as
 appropriate so that, for instance, if we pass in `@"1111 1123 1111"`
 and a cursor position of `8`, the cursor position will be changed to
 `7` (keeping it between the '2' and the '3' after the spaces are removed).
 */
- (NSString *)removeNonDigits:(NSString *)string
    andPreserveCursorPosition:(NSUInteger *)cursorPosition
{
    NSUInteger originalCursorPosition = *cursorPosition;
    NSMutableString *digitsOnlyString = [NSMutableString new];
    for (NSUInteger i=0; i<[string length]; i++) {
        unichar characterToAdd = [string characterAtIndex:i];
        if (isdigit(characterToAdd)) {
            NSString *stringToAdd =
            [NSString stringWithCharacters:&characterToAdd
                                    length:1];
            
            [digitsOnlyString appendString:stringToAdd];
        }
        else {
            if (i < originalCursorPosition) {
                (*cursorPosition)--;
            }
        }
    }
    
    return digitsOnlyString;
}

/*
 Inserts spaces into the string to format it as a credit card number,
 incrementing `cursorPosition` as appropriate so that, for instance, if we
 pass in `@"111111231111"` and a cursor position of `7`, the cursor position
 will be changed to `8` (keeping it between the '2' and the '3' after the
 spaces are added).
 */
- (NSString *)insertSpacesEveryFourDigitsIntoString:(NSString *)string
                          andPreserveCursorPosition:(NSUInteger *)cursorPosition
{
    NSMutableString *stringWithAddedSpaces = [NSMutableString new];
    NSUInteger cursorPositionInSpacelessString = *cursorPosition;
    for (NSUInteger i=0; i<[string length]; i++) {
        if ((i>0) && ((i % 4) == 0)) {
            [stringWithAddedSpaces appendString:@" "];
            if (i < cursorPositionInSpacelessString) {
                (*cursorPosition)++;
            }
        }
        unichar characterToAdd = [string characterAtIndex:i];
        NSString *stringToAdd =
        [NSString stringWithCharacters:&characterToAdd length:1];
        
        [stringWithAddedSpaces appendString:stringToAdd];
    }
    
    return stringWithAddedSpaces;
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
    
    if( ![self isUsingUITextView] && [[[self textField] text] length] <= 0 && [self shouldHideImagesWhenEmpty] )
    {
        [[self backgroundImage] setHidden:YES];
        [[[self textField] rightView] setHidden:YES];
        [[[self textField] leftView] setHidden:YES];
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

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if( [self inputFormatCreditCard] )
    {
        _previousTextFieldContent = textField.text;
        _previousSelection = textField.selectedTextRange;
        
        [self reformatAsCardNumber:_textField];
    }
    
    if( [self inputFormatCurrency] )
    {
        NSMutableCharacterSet *numberSet = [[NSCharacterSet decimalDigitCharacterSet] mutableCopy];
        [numberSet formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
        NSCharacterSet *nonNumberSet = [numberSet invertedSet];
        
        BOOL result = NO;
        
        if([string length] == 0){
            result = YES;
        }
        else{
            if([string stringByTrimmingCharactersInSet:nonNumberSet].length > 0){
                result = YES;
            }
        }
        
        if(result){
            NSMutableString* mstring = [[textField text] mutableCopy];
            
            if([string length] > 0){
                [mstring insertString:string atIndex:range.location];
            }
            else {
                [mstring deleteCharactersInRange:range];
            }
            
            NSLocale* locale = [NSLocale currentLocale];
            NSString *localCurrencySymbol = [locale objectForKey:NSLocaleCurrencySymbol];
            NSString *localGroupingSeparator = [locale objectForKey:NSLocaleGroupingSeparator];
            
            NSString* clean_string = [[mstring stringByReplacingOccurrencesOfString:localGroupingSeparator
                                                                         withString:@""]
                                      stringByReplacingOccurrencesOfString:localCurrencySymbol
                                      withString:@""];
            
            if([[Formatters currencyFormatter] maximumFractionDigits] > 0){
                NSMutableString *mutableCleanString = [clean_string mutableCopy];
                
                if([string length] > 0){
                    NSRange theRange = [mutableCleanString rangeOfString:@"."];
                    if( theRange.location != NSNotFound )
                    {
                        [mutableCleanString deleteCharactersInRange:theRange];
                        [mutableCleanString insertString:@"." atIndex:(theRange.location + 1)];
                    }
                    clean_string = mutableCleanString;
                }
                else {
                    [mutableCleanString insertString:@"0" atIndex:0];
                    NSRange theRange = [mutableCleanString rangeOfString:@"."];
                    if( theRange.location != NSNotFound )
                    {
                        [mutableCleanString deleteCharactersInRange:theRange];
                        [mutableCleanString insertString:@"." atIndex:(theRange.location - 1)];
                    }
                    clean_string = mutableCleanString;
                }
            }
            
            NSNumber* number = [[Formatters basicFormatter] numberFromString: clean_string];
            NSMutableString *numberString = [[[Formatters currencyFormatter] stringFromNumber:number] mutableCopy];
            [numberString deleteCharactersInRange:NSMakeRange(0, 1)];
            [textField setText:numberString];
            [[self actionContainer] executeActionsForEventNamed:kIXTextChanged];
        }
        return NO;
    }
    
    return YES;
    
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
        
        if( [self shouldHideImagesWhenEmpty] )
        {
            if( [inputText length] > 0 )
            {
                [[self backgroundImage] setHidden:NO];
                [[self textField].rightView setHidden:NO];
                [[[self textField] leftView] setHidden:NO];
            }
            else
            {
                [[self backgroundImage] setHidden:YES];
                [[self textField].rightView setHidden:YES];
                [[[self textField] leftView] setHidden:YES];
            }
        }
    }
    
    [[self actionContainer] executeActionsForEventNamed:kIXTextChanged];
}

@end