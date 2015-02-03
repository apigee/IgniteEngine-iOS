//
//  IXTextControl.m
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
 
 Words, letters & fonts.
 

 <div id="container">
 <a href="../images/IXText.png" data-imagelightbox="c"><img src="../images/IXText.png" alt=""></a>
 
</div>
 
 */

/*
 *      /Docs
 *
 */

#import "IXText.h"

#import "UILabel+IXAdditions.h"
#import "NSString+FontAwesome.h"

// IXText Properties
static NSString* const kIXText = @"text";
static NSString* const kIXTextAlignment = @"text.alignment";
static NSString* const kIXTextColor = @"text.color";
static NSString* const kIXFont = @"font";
static NSString* const kIXSizeToFit = @"size_to_fit";

@interface IXText ()

@property (nonatomic,strong) UILabel* label;
@property (nonatomic,assign,getter = shouldSizeLabelToFit) BOOL sizeLabelToFit;

@end

@implementation IXText

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

    @param text Text to display<br>*(string)*
    @param text.alignment Alignment of the text *(default: left)*<br>*leftrightcenterjustifiednatural*
    @param text.color Color of the text *(default: #000000)*<br>*(color)*
    @param font The text font name and size (font:size) *(default: HelveticaNeue:20)*<br>*(string)*
    @param size_to_fit Shall the size the text to fit dynamically? *(default: FALSE)*<br>*(bool)*

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

-(void)buildView
{
    [super buildView];
    
    _label = [[UILabel alloc] initWithFrame:CGRectZero];
    _sizeLabelToFit = YES;
    
    [[self contentView] addSubview:[self label]];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    CGSize sizeThatFits = [[self label] sizeThatFits:size];
    float height = ceilf([[self label] sizeForFixedWidth:size.width].height);
    return CGSizeMake(sizeThatFits.width, height);
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [[self label] setFrame:rect];
    if( [self shouldSizeLabelToFit] )
    {
        [[self label] sizeToFit];
    }
}

-(void)applySettings
{
    [super applySettings];
    
    [[self label] setUserInteractionEnabled:[[self contentView] isEnabled]];
    [[self label] setTextColor:[[self propertyContainer] getColorPropertyValue:kIXTextColor defaultValue:[UIColor blackColor]]];
    [[self label] setFont:[[self propertyContainer] getFontPropertyValue:kIXFont defaultValue:[UIFont fontWithName:@"HelveticaNeue" size:20.0f]]];

    NSString* text = [[self propertyContainer] getStringPropertyValue:kIXText defaultValue:nil];
    if( [[[[self label] font] familyName] isEqualToString:kFontAwesomeFamilyName] )
    {
        [[self label] setText:[NSString fontAwesomeIconStringForIconIdentifier:text]];
    }
    else
    {
        [[self label] setText:text];
    }
    [[self label] setTextAlignment:[UILabel ix_textAlignmentFromString:[[self propertyContainer] getStringPropertyValue:kIXTextAlignment defaultValue:nil]]];
    [[self label] setNumberOfLines:0];
    [[self label] setLineBreakMode:NSLineBreakByWordWrapping];
    
    BOOL sizeLabelToFitDefaultValue = ([[self label] textAlignment] == NSTextAlignmentLeft);
    [self setSizeLabelToFit:[[self propertyContainer] getBoolPropertyValue:kIXSizeToFit defaultValue:sizeLabelToFitDefaultValue]];
}

@end
