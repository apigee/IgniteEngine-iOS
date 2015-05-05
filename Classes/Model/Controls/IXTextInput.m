//
//  IXTextInputControl.m
//  Ignite Engine
//
//  Created by Robert Walsh on 10/15/13.
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

#import "IXTextInput.h"

#import "IXLayout.h"
#import "IXAppManager.h"
#import "IXNavigationViewController.h"
#import "IXViewController.h"
#import "IXClickableScrollView.h"
#import "IXAttribute.h"
#import "IXNavigateAction.h"
#import "IXFormatter.h"
#import "UITextField+IXAdditions.h"
#import "IQKeyboardManager.h"

// IXTextInput Attributes
IX_STATIC_CONST_STRING kIXFont = @"font";
IX_STATIC_CONST_STRING kIXCursorColor = @"cursor.color";
IX_STATIC_CONST_STRING kIXAutoCorrect = @"autocorrect.enabled";
IX_STATIC_CONST_STRING kIXDismissOnReturn = @"dismissOnReturn.enabled";
IX_STATIC_CONST_STRING kIXIsMultiLine = @"multiline.enabled";
IX_STATIC_CONST_STRING kIXInitialText = @"text.default";
IX_STATIC_CONST_STRING kIXTextColor = @"color";
IX_STATIC_CONST_STRING kIXTextPlaceholder = @"placeholder.text";
IX_STATIC_CONST_STRING kIXTextPlaceholderColor = @"placeholder.color";
IX_STATIC_CONST_STRING kIXTextAlignment = @"text.align";
IX_STATIC_CONST_STRING kIXBackgroundColor = @"bg.color";
IX_STATIC_CONST_STRING kIXClearsOnBeginEditing = @"clearOnFocus.enabled"; // Only works on non multiline input.
IX_STATIC_CONST_STRING kIXRightImage = @"image.right"; // Must use full path within assets (aka "assets/images/image.png" ). Only works on non multiline input.
IX_STATIC_CONST_STRING kIXLeftImage = @"image.left"; // Must use full path within assets (aka "assets/images/image.png" ). Only works on non multiline input.
IX_STATIC_CONST_STRING kIXBackgroundImage = @"bg.image";
IX_STATIC_CONST_STRING kIXHidesImagesWhenEmpty = @"hideImageWhenEmpty.enabled"; // Only works on non multiline input.
IX_STATIC_CONST_STRING kIXKeyboardAppearance = @"keyboard.appearance";
IX_STATIC_CONST_STRING kIXKeyboardType = @"keyboard.type";
IX_STATIC_CONST_STRING kIXKeyboardPadding = @"keyboard.padding";
IX_STATIC_CONST_STRING kIXKeyboardReturnKey = @"keyboard.returnKey";
IX_STATIC_CONST_STRING kIXKeyboardToolbar = @"keyboard.toolbar.enabled";
IX_STATIC_CONST_STRING kIXFormat = @"format"; // Credit card, currency, password
//IX_STATIC_CONST_STRING kIXInputFormatCurrency = @"formatAsCurrency.enabled";
//IX_STATIC_CONST_STRING kIXInputFormatCreditCard = @"formatAsCreditCard.enabled";
IX_STATIC_CONST_STRING kIXInputRegexAllowed = @"regex.allowed";
IX_STATIC_CONST_STRING kIXInputRegexDisAllowed = @"regex.disallowed";
IX_STATIC_CONST_STRING kIXInputMax = @"maxChars";
IX_STATIC_CONST_STRING kIXInputTransform = @"text.transform";

// TODO: not implemented?
IX_STATIC_CONST_STRING kIXFilterDatasource = @"filter_datasource"; // not implemented

// IXTextInput Attribute Allowed Values
IX_STATIC_CONST_STRING kIXInputTransformCapitalize = @"capitalize"; // kIXInputTransform
IX_STATIC_CONST_STRING kIXInputTransformLowercase = @"lowercase"; // kIXInputTransform
IX_STATIC_CONST_STRING kIXInputTransformUppercase = @"uppercase"; // kIXInputTransform
IX_STATIC_CONST_STRING kIXInputTransformUppercaseFirst = @"ucfirst"; // kIXInputTransform
IX_STATIC_CONST_STRING kIXInputFormatPassword = @"password"; // kIXFormat
IX_STATIC_CONST_STRING kIXInputFormatCurrency = @"currency"; // kIXFormat
IX_STATIC_CONST_STRING kIXInputFormatCC = @"creditcard"; // kIXFormat

// IXTextInput Returns
IX_STATIC_CONST_STRING kIXText = @"text"; // To set the text use the kIXSetText function.

// IXTextInput Functions
IX_STATIC_CONST_STRING kIXSetText = @"setText"; // Parameter is kIXText.
IX_STATIC_CONST_STRING kIXKeyboardHide = @"dismissKeyboard";
IX_STATIC_CONST_STRING kIXKeyboardShow = @"showKeyboard";
IX_STATIC_CONST_STRING kIXFocus = @"focus";

// IXTextInput Events
IX_STATIC_CONST_STRING kIXGotFocus = @"focus";
IX_STATIC_CONST_STRING kIXLostFocus = @"focusLost";
IX_STATIC_CONST_STRING kIXReturnKeyPressed = @"returnKeyPressed";
IX_STATIC_CONST_STRING kIXTextChanged = @"textChanged";
IX_STATIC_CONST_STRING kIXImageRightTapped = @"rightImageTapped";
IX_STATIC_CONST_STRING kIXImageLeftTapped = @"leftImageTapped";

// NSCoding Key Constants
IX_STATIC_CONST_STRING kIXTextFieldNSCodingKey = @"textField";
IX_STATIC_CONST_STRING kIXTextViewNSCodingKey = @"textView";

static CGFloat const kIXMaxPreferredHeightForTextInput = 40.0f;
IX_STATIC_CONST_STRING kIXNewLineString = @"\n";

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

@property (nonatomic,assign) CGFloat keyboardPadding;
@property (nonatomic,assign) CGSize layoutContentSizeAtStartOfEditing;

@property (nonatomic,assign) BOOL inputFormatCurrency;
@property (nonatomic,assign) BOOL inputFormatCreditCard;

@property (nonatomic,assign) NSString *inputFormat;
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
    _registeredForKeyboardNotifications = NO;
}

-(void)createTextInputView
{
    if( [self isFirstLoad] )
    {
        [self setFirstLoad:NO];
        
        [self setBackgroundImage:[[UIImageView alloc] initWithFrame:CGRectZero]];
        [[self contentView] addSubview:[self backgroundImage]];
        
        BOOL shouldShowKeyboardToolbar = [[self attributeContainer] getBoolValueForAttribute:kIXKeyboardToolbar defaultValue:NO];
        [IQKeyboardManager sharedManager].enableAutoToolbar = shouldShowKeyboardToolbar;
        
        NSString* initialText = [[self attributeContainer] getStringValueForAttribute:kIXInitialText defaultValue:nil];
        
        [self setUsingUITextView:[[self attributeContainer] getBoolValueForAttribute:kIXIsMultiLine defaultValue:NO]];
        
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
    
    UIFont* font = [[self attributeContainer] getFontValueForAttribute:kIXFont defaultValue:[UIFont fontWithName:@"HelveticaNeue" size:20.0f]];
    UIColor* textColor = [[self attributeContainer] getColorValueForAttribute:kIXTextColor defaultValue:[UIColor blackColor]];
    UIColor* tintColor = [[self attributeContainer] getColorValueForAttribute:kIXCursorColor defaultValue:[self defaultTextInputTintColor]];
    UIColor* backgroundColor = [[self attributeContainer] getColorValueForAttribute:kIXBackgroundColor defaultValue:[UIColor whiteColor]];
    NSTextAlignment textAlignment = [UITextField ix_textAlignmentFromString:[[self attributeContainer] getStringValueForAttribute:kIXTextAlignment defaultValue:nil]];
    UITextAutocorrectionType autoCorrectionType = [UITextField ix_booleanToTextAutocorrectionType:[[self attributeContainer] getBoolValueForAttribute:kIXAutoCorrect defaultValue:YES]];
    
    UIKeyboardAppearance keyboardAppearance = [UITextField ix_stringToKeyboardAppearance:[[self attributeContainer] getStringValueForAttribute:kIXKeyboardAppearance defaultValue:kIX_DEFAULT]];
    UIKeyboardType keyboardType = [UITextField ix_stringToKeyboardType:[[self attributeContainer] getStringValueForAttribute:kIXKeyboardType defaultValue:kIX_DEFAULT]];
    UIReturnKeyType returnKeyType = [UITextField ix_stringToReturnKeyType:[[self attributeContainer] getStringValueForAttribute:kIXKeyboardReturnKey defaultValue:kIX_DEFAULT]];
    
    [self setHideImagesWhenEmpty:[[self attributeContainer] getBoolValueForAttribute:kIXHidesImagesWhenEmpty defaultValue:NO]];
    [self setInputFormat:[[self attributeContainer] getStringValueForAttribute:kIXFormat defaultValue:nil]];

    if( ![self isUsingUITextView] )
    {
        [[self textField] setEnabled:[[self contentView] isEnabled]];
        
        NSString* placeHolderText = [[self attributeContainer] getStringValueForAttribute:kIXTextPlaceholder defaultValue:nil];
        if( [placeHolderText length] > 0 )
        {
            UIColor* placeHolderTextColor = [[self attributeContainer] getColorValueForAttribute:kIXTextPlaceholderColor defaultValue:[UIColor lightGrayColor]];
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
        if ([[self inputFormat] isEqualToString:kIXInputFormatPassword]) {
            [[self textField] setSecureTextEntry:YES];
        }

        [[self textField] setClearsOnBeginEditing:[[self attributeContainer] getBoolValueForAttribute:kIXClearsOnBeginEditing defaultValue:NO]];
        
        [[self textField] setRightViewMode:UITextFieldViewModeAlways];
        [[self textField] setLeftViewMode:UITextFieldViewModeAlways];
        
        [[self textField] setRightView:nil];
        [[self textField] setLeftView:nil];

        for( NSString* imagePropertyName in @[kIXRightImage,kIXLeftImage] )
        {
            NSString* imageLocationString = [[self attributeContainer] getStringValueForAttribute:imagePropertyName defaultValue:nil];
            if( [imageLocationString length] > 0 )
            {
                UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageLocationString]];
                [imageView setUserInteractionEnabled:YES];

                BOOL isRightViewImage = [imagePropertyName isEqualToString:kIXRightImage];
                SEL imageTapSelector = isRightViewImage ? @selector(rightViewTapDetected:) : @selector(leftViewTapDetected:);

                UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:imageTapSelector];
                [tapGestureRecognizer setNumberOfTapsRequired:1];
                [imageView addGestureRecognizer:tapGestureRecognizer];

                if( isRightViewImage )
                {
                    [[self textField] setRightView:imageView];
                }
                else
                {
                    [[self textField] setLeftView:imageView];
                }
            }
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
        if ([[self inputFormat] isEqualToString:kIXInputFormatPassword]) {
            [[self textView] setSecureTextEntry:YES];
        }
    }

    __weak typeof(self) weakSelf = self;
    [[self attributeContainer] getImageAttribute:kIXBackgroundImage
                                  successBlock:^(UIImage *image) {
                                      [[weakSelf backgroundImage] setImage:image];
                                  } failBlock:^(NSError *error) {
                                      [[weakSelf backgroundImage] setImage:nil];
                                  }];
    
    [self setDismissOnReturn:[[self attributeContainer] getBoolValueForAttribute:kIXDismissOnReturn defaultValue:YES]];
    [self setInputMaxAllowedCharacters:[[self attributeContainer] getIntValueForAttribute:kIXInputMax defaultValue:0]];
    [self setInputTransform:[[self attributeContainer] getStringValueForAttribute:kIXInputTransform defaultValue:nil]];
    [self setInputDisallowedRegexString:[[self attributeContainer] getStringValueForAttribute:kIXInputRegexDisAllowed defaultValue:nil]];
    [self setFilterDatasource:[[self attributeContainer] getCommaSeparatedArrayOfValuesForAttribute:kIXFilterDatasource defaultValue:nil]];

    [self setInputAllowedRegexString:[[self attributeContainer] getStringValueForAttribute:kIXInputRegexAllowed defaultValue:nil]];
    if( [[self inputAllowedRegexString] length] > 1 )
    {
        NSMutableString *positiveAssertion = [[self inputAllowedRegexString] mutableCopy];
        [positiveAssertion insertString:@"^" atIndex:1];
        [self setInputAllowedRegexString:positiveAssertion];
    }
    
    [self setKeyboardPadding:[[self attributeContainer] getFloatValueForAttribute:kIXKeyboardPadding defaultValue:0.0f]];
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

-(void)applyFunction:(NSString*)functionName withParameters:(IXAttributeContainer*)parameterContainer
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
        NSString* text = [parameterContainer getStringValueForAttribute:kIXText defaultValue:nil];
        NSString* placeholderText = [parameterContainer getStringValueForAttribute:kIXTextPlaceholder defaultValue:nil];
        
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
                [[self attributeContainer] addAttribute:[IXAttribute attributeWithAttributeName:kIXTextPlaceholder rawValue:placeholderText] replaceOtherAttributesWithSameName:YES];
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
    [self registerForKeyboardNotifications];

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
    
    if( [self inputFormat] )
    {
        if ([_inputFormat isEqualToString:kIXInputFormatCC]) {
            _previousTextFieldContent = textField.text;
            _previousSelection = textField.selectedTextRange;
            
            [self reformatAsCardNumber:_textField];
        }
        else if ([_inputFormat isEqualToString:kIXInputFormatCurrency]) {
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
                
                if([[IXFormatter currencyFormatter] maximumFractionDigits] > 0){
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
                
                NSNumber* number = [[IXFormatter basicFormatter] numberFromString: clean_string];
                NSMutableString *numberString = [[[IXFormatter currencyFormatter] stringFromNumber:number] mutableCopy];
                [numberString deleteCharactersInRange:NSMakeRange(0, 1)];
                [textField setText:numberString];
                [[self actionContainer] executeActionsForEventNamed:kIXTextChanged];
            }
            return NO;
        }
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