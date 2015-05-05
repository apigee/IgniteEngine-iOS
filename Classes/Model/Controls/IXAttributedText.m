//
//  IXAttrubtedText.m
//  Ignite Engine
//
//  Created by Brandon on 3/13/14.
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

#import "IXBaseControl.h"
#import "IXLogger.h"
#import "TTTAttributedLabel.h"
#import "ColorUtils.h"

// Attributes
IX_STATIC_CONST_STRING kIXText = @"text";
IX_STATIC_CONST_STRING kIXTextColor = @"color";
IX_STATIC_CONST_STRING kIXFont = @"font";
IX_STATIC_CONST_STRING kIXBackgroundColor = @"bg.color";
IX_STATIC_CONST_STRING kIXMentionScheme = @"mentions.scheme";
IX_STATIC_CONST_STRING kIXMentionColor = @"mentions.color";
IX_STATIC_CONST_STRING kIXMentionFont = @"mentions.font";
IX_STATIC_CONST_STRING kIXHashtagScheme = @"hashtags.scheme";
IX_STATIC_CONST_STRING kIXHashtagColor = @"hashtags.color";
IX_STATIC_CONST_STRING kIXHashtagFont = @"hashtags.font";
IX_STATIC_CONST_STRING kIXHyperlinkColor = @"links.color";
IX_STATIC_CONST_STRING kIXHyperlinkFont = @"links.font";
IX_STATIC_CONST_STRING kIXCodeFont = @"code.font";
IX_STATIC_CONST_STRING kIXCodeColor = @"code.color";
IX_STATIC_CONST_STRING kIXCodeBackgroundColor = @"code.bg.color";
IX_STATIC_CONST_STRING kIXCodeBorderColor = @"code.border.color";
IX_STATIC_CONST_STRING kIXCodeBorderRadius = @"code.border.radius";
IX_STATIC_CONST_STRING kIXTextKerning = @"kerning";
IX_STATIC_CONST_STRING kIXTextAlign = @"text.align";
IX_STATIC_CONST_STRING kIXLineSpacing = @"lineSpacing";
IX_STATIC_CONST_STRING kIXLineHeightMin = @"lineHeight.min";
IX_STATIC_CONST_STRING kIXLineHeightMax = @"lineHeight.max";
IX_STATIC_CONST_STRING kIXShouldHighlightMentions = @"mentions.enabled"; // default: true
IX_STATIC_CONST_STRING kIXShouldHighlightHashtags = @"hashtags.enabled"; // default: true
IX_STATIC_CONST_STRING kIXShouldHighlightHyperlinks = @"links.enabled"; // default: true
IX_STATIC_CONST_STRING kIXShouldParseMarkdown = @"markdown.enabled"; // default: false

// Attribute Accepted Values
IX_STATIC_CONST_STRING kIXLeft = @"left";
IX_STATIC_CONST_STRING kIXRight = @"right";
IX_STATIC_CONST_STRING kIXCenter = @"center";
IX_STATIC_CONST_STRING kIXJustified = @"justified";
IX_STATIC_CONST_STRING kIXNatural = @"natural";

// Attribute Defaults
IX_STATIC_CONST_STRING kIXDefaultTextAlign = @"left";

// Returns
IX_STATIC_CONST_STRING kIXSelectedMention = @"selectedMention";
IX_STATIC_CONST_STRING kIXSelectedHashtag = @"selectedHashtag";
IX_STATIC_CONST_STRING kIXSelectedUrl = @"selectedLink";

// Events
IX_STATIC_CONST_STRING kIXLongPressMention = @"longPressMention";
IX_STATIC_CONST_STRING kIXLongPressHashtag = @"longPressHashtag";
IX_STATIC_CONST_STRING kIXLongPressLink = @"longPressLink";
IX_STATIC_CONST_STRING kIXTouchUpMention = @"touchUpMention";
IX_STATIC_CONST_STRING kIXTouchUpHashtag = @"touchUpHashtag";
IX_STATIC_CONST_STRING kIXTouchUpLink = @"touchUpLink";

// Functions
// *none*

@interface IXAttributedText : IXBaseControl <TTTAttributedLabelDelegate>

@property (nonatomic,strong) TTTAttributedLabel* label;
@property (nonatomic,strong) NSMutableAttributedString* attributedString;

@property (nonatomic,strong) NSString* currentTouchedMention;
@property (nonatomic,strong) NSString* currentTouchedHashtag;
@property (nonatomic,strong) NSURL* currentTouchedUrl;

@property (nonatomic,strong) NSString* definedMentionScheme;
@property (nonatomic,strong) NSString* definedHashtagScheme;

@property (nonatomic,strong) UIColor* baseTextColor;

@end


IX_STATIC_CONST_STRING kIXPrefixLongPress = @"longPress"; // prefixes the event
IX_STATIC_CONST_STRING kIXPrefixTouchUp = @"touchUp"; // prefixes the event

@implementation IXAttributedText

-(void)buildView
{
    [super buildView];
    self.label = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.label];
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [self.label setFrame:rect];
    [self.label sizeToFit];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return [self.label sizeThatFits:size];
}

//Event handler

- (void)attributedLabel:(TTTAttributedLabel *)label didLongPressLinkWithURL:(NSURL *)url atPoint:(CGPoint)point
{
    [self performActionsForSelector:kIXPrefixLongPress withUrl:url];
    IX_LOG_DEBUG(@"Detected long press for url: %@", url);
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    [self performActionsForSelector:kIXPrefixTouchUp withUrl:url];
    IX_LOG_DEBUG(@"Detected touch up inside for url: %@", url);
}

-(void)performActionsForSelector:(NSString *)selector withUrl:(NSURL *)url
{
    //We need to nil out existing properties to prevent bad data
    _currentTouchedMention = nil;
    _currentTouchedHashtag = nil;
    _currentTouchedUrl = nil;
    
    //String is a mention @
    if ([[NSString stringWithFormat:@"%@", url] hasPrefix:_definedMentionScheme])
    {
        _currentTouchedMention = url.host;
        if ([selector isEqualToString:kIXPrefixLongPress])
            [[self actionContainer] executeActionsForEventNamed:kIXLongPressMention];
        else if ([selector isEqualToString:kIXPrefixTouchUp])
            [[self actionContainer] executeActionsForEventNamed:kIXTouchUpMention];
    }
    //String is a hashtag #
    else if ([[NSString stringWithFormat:@"%@", url] hasPrefix:_definedHashtagScheme])
    {
        _currentTouchedHashtag = url.host;
        if ([selector isEqualToString:kIXPrefixLongPress])
            [[self actionContainer] executeActionsForEventNamed:kIXLongPressHashtag];
        else if ([selector isEqualToString:kIXPrefixTouchUp])
            [[self actionContainer] executeActionsForEventNamed:kIXTouchUpHashtag];
    }
    //String is a url
    else if ([[NSString stringWithFormat:@"%@", url] hasPrefix:@"http"] || [[NSString stringWithFormat:@"%@", url] hasPrefix:@"ftp"])
    {
        _currentTouchedUrl = url;
        if ([selector isEqualToString:kIXPrefixLongPress])
            [[self actionContainer] executeActionsForEventNamed:kIXLongPressLink];
        else if ([selector isEqualToString:kIXPrefixTouchUp])
            [[self actionContainer] executeActionsForEventNamed:kIXTouchUpLink];
    }
    
}

-(NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = nil;
    if( [propertyName isEqualToString:kIXSelectedMention] && _currentTouchedMention )
    {
        returnValue = [NSString stringWithFormat:@"%@", _currentTouchedMention];
    }
    else if( [propertyName isEqualToString:kIXSelectedHashtag] && _currentTouchedHashtag )
    {
        returnValue = [NSString stringWithFormat:@"%@", _currentTouchedHashtag];
    }
    else if( [propertyName isEqualToString:kIXSelectedUrl] && _currentTouchedUrl )
    {
        returnValue = [NSString stringWithFormat:@"%@", _currentTouchedUrl];
    }
    else
    {
        returnValue = [super getReadOnlyPropertyValue:propertyName];
    }
    return returnValue;
}

//Apply settings
-(void)applySettings
{
    [super applySettings];
    
    //Initial definitions
    NSString* text = [self.attributeContainer getStringValueForAttribute:kIXText defaultValue:@""];
    _definedMentionScheme = [self.attributeContainer getStringValueForAttribute:kIXMentionScheme defaultValue:@"mention://"];
    _definedHashtagScheme = [self.attributeContainer getStringValueForAttribute:kIXHashtagScheme defaultValue:@"hashtag://"];
    _baseTextColor = [self.attributeContainer getColorValueForAttribute:kIXTextColor defaultValue:[UIColor blackColor]];
    
    self.label.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    self.label.textColor = _baseTextColor;
    self.label.lineBreakMode = NSLineBreakByWordWrapping;
    self.label.numberOfLines = 0;
    self.label.userInteractionEnabled = YES;
    self.label.delegate = self;
    
    self.label.backgroundColor = [self.attributeContainer getColorValueForAttribute:kIXBackgroundColor defaultValue:[UIColor clearColor]];
    
    //Set alignment
    NSString* textAlignmentString = [self.attributeContainer getStringValueForAttribute:kIXTextAlign defaultValue:kIXDefaultTextAlign];
    NSTextAlignment textAlignment = [self getTextAlignmentFromPropertyValue:textAlignmentString];
    
    //Double check that the label supports attributed text
    if ([self.label respondsToSelector:@selector(setAttributedText:)])
    {
        BOOL highlightMentions = [self.attributeContainer getBoolValueForAttribute:kIXShouldHighlightMentions defaultValue:true];
        BOOL highlightHashtags = [self.attributeContainer getBoolValueForAttribute:kIXShouldHighlightHashtags defaultValue:true];
        BOOL highlightHyperlinks = [self.attributeContainer getBoolValueForAttribute:kIXShouldHighlightHyperlinks defaultValue:true];
        BOOL shouldParseMarkdown = [self.attributeContainer getBoolValueForAttribute:kIXShouldParseMarkdown defaultValue:false];
        
        
        UIColor *mentionColor = [self.attributeContainer getColorValueForAttribute:kIXMentionColor defaultValue:[UIColor blackColor]];
        UIColor *hashtagColor = [self.attributeContainer getColorValueForAttribute:kIXHashtagColor defaultValue:[UIColor blackColor]];
        UIColor *hyperlinkColor = [self.attributeContainer getColorValueForAttribute:kIXHyperlinkColor defaultValue:[UIColor blackColor]];
        
        UIFont *defaultFont = [self.attributeContainer getFontValueForAttribute:kIXFont defaultValue:[UIFont systemFontOfSize:16.0f]];
        UIFont *mentionFont = [self.attributeContainer getFontValueForAttribute:kIXMentionFont defaultValue:defaultFont];
        UIFont *hashtagFont = [self.attributeContainer getFontValueForAttribute:kIXHashtagFont defaultValue:defaultFont];
        UIFont *hyperlinkFont = [self.attributeContainer getFontValueForAttribute:kIXHyperlinkFont defaultValue:defaultFont];
        
        CGFloat textKerning = [self.attributeContainer getFloatValueForAttribute:kIXTextKerning defaultValue:0];
        CGFloat lineSpacing = [self.attributeContainer getFloatValueForAttribute:kIXLineSpacing defaultValue:-0.01];
        CGFloat minLineHeight = [self.attributeContainer getFloatValueForAttribute:kIXLineHeightMin defaultValue:-0.01];
        CGFloat maxLineHeight = [self.attributeContainer getFloatValueForAttribute:kIXLineHeightMax defaultValue:-0.01];
        
        //Define attributedString
        self.attributedString = [[NSMutableAttributedString alloc] initWithString:text];
        NSRange lengthOfAttributedString = NSMakeRange(0, self.attributedString.length);
        
        //Set default text styling (font, size, color, kerning)
        [self.attributedString addAttribute:NSForegroundColorAttributeName value:_baseTextColor range:lengthOfAttributedString];
        [self.attributedString addAttribute:NSFontAttributeName value:defaultFont range:lengthOfAttributedString];
        [self.attributedString addAttribute:NSKernAttributeName value:[NSNumber numberWithFloat:textKerning] range:lengthOfAttributedString];
        
        //Set paragraph styles
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        if (lineSpacing != -0.01) paragraphStyle.lineSpacing = lineSpacing;
        if (minLineHeight != -0.01) paragraphStyle.minimumLineHeight = minLineHeight;
        if (maxLineHeight != -0.01) paragraphStyle.maximumLineHeight = maxLineHeight;
        paragraphStyle.alignment = textAlignment;
        [self.attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:lengthOfAttributedString];
        
        
        //Should we parse markdown you think?
        if (shouldParseMarkdown)
        {
            //Define markdown-specific properties
            UIFont *codeFont = [self.attributeContainer getFontValueForAttribute:kIXCodeFont defaultValue:[UIFont fontWithName:@"Menlo-Regular" size:defaultFont.pointSize - 2]];
            UIColor *codeColor = [self.attributeContainer getColorValueForAttribute:kIXCodeColor defaultValue:[UIColor blackColor]];
            UIColor *codeBackgroundColor = [self.attributeContainer getColorValueForAttribute:kIXCodeBackgroundColor defaultValue:[[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:0.3]];
            UIColor *codeBorderColor = [self.attributeContainer getColorValueForAttribute:kIXCodeBorderColor defaultValue:[[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:0.7]];
            
            NSNumber *codeBorderRadius = [NSNumber numberWithInteger:[self.attributeContainer getIntValueForAttribute:kIXCodeBorderRadius defaultValue:3]];
            
            //Format bold **bold**
            [self formatMarkdownBlockMatchingRegex:@"\\*{2}(?!\\s).+?(?<!\\s)\\*{2}"
                      andReplaceCharsMatchingRegex:@"(\\*{2}(?!\\s)|(?<!\\s)\\*{2})"
                                         withChars:@""
                                    withAttributes:@{
                                                     NSFontAttributeName: [UIFont boldSystemFontOfSize:defaultFont.pointSize]
                                                     }];
            
            //Format italic *italic*
            [self formatMarkdownBlockMatchingRegex:@"\\*(?!\\s).+?(?<!\\s)\\*"
                      andReplaceCharsMatchingRegex:@"(\\*(?!\\s)|(?<!\\s)\\*)"
                                         withChars:@""
                                    withAttributes:@{
                                                     NSFontAttributeName: [UIFont italicSystemFontOfSize:defaultFont.pointSize]
                                                     }];
            
            
            //Format underline __underline__
            [self formatMarkdownBlockMatchingRegex:@"\\_{2}(?!\\s).+?(?<!\\s)\\_{2}"
                      andReplaceCharsMatchingRegex:@"(\\_{2}(?!\\s)|(?<!\\s)\\_{2})"
                                         withChars:@""
                                    withAttributes:@{
                                                     NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                                     }];
            
            //Format strikethrough ~~strikethrough~~
            [self formatMarkdownBlockMatchingRegex:@"~{2}(?!\\s).+?(?<!\\s)~{2}"
                      andReplaceCharsMatchingRegex:@"(~{2}(?!\\s)|(?<!\\s)~{2})"
                                         withChars:@""
                                    withAttributes:@{
                                                     (NSString *)kTTTStrikeOutAttributeName: [NSNumber numberWithInt:NSUnderlineStyleThick]
                                                     }];
            
            //Format code `code`
            //This block will need to be replaced with the one below once we're ready to implement in production
            [self formatMarkdownBlockMatchingRegex:@"`.*?`"
                      andReplaceCharsMatchingRegex:@"`"
                                         withChars:@""
                                    withAttributes:@{
                                                     NSFontAttributeName: codeFont,
                                                     NSForegroundColorAttributeName: codeColor,
                                                     (NSString *)kTTTBackgroundFillColorAttributeName: (id)codeBackgroundColor.CGColor,
                                                     (NSString *)kTTTBackgroundStrokeColorAttributeName: (id)codeBorderColor.CGColor,
                                                     (NSString *)kTTTBackgroundCornerRadiusAttributeName: (id)codeBorderRadius,
                                                     
                                                     //Padding's not working because C is stupid.
                                                     //(NSString *)kTTTBackgroundFillPaddingAttributeName: (UIEdgeInsets)codePadding,
                                                     
                                                     NSKernAttributeName: [NSNumber numberWithInt:textKerning - 0.5]
                                                     }];
            
            //We need to set the attributedText here because links are being added to the label not the attributed text.
            self.label.attributedText = self.attributedString;
            
            //Rewrite [markdown](urls)
            [self rewriteMarkdownUrlBlocksWithAttributes:@{
                                                           NSFontAttributeName: hyperlinkFont,
                                                           NSForegroundColorAttributeName: hyperlinkColor,
                                                           NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                                           }];
            
            //Rewrite {#FFFFFF,#000000|colored and highlighted text}
            [self rewriteColoredBlocks];
        }
        
        
        if (highlightHyperlinks)
        {
            NSArray *hyperlinksArray = [self rangesOfString:@"\\b([A-Za-z]+://[^\\s(),]+|[^\\s(),]+\\.(?:[^\\s(),]{2,}))" inString:[self.attributedString string]];
            for (NSValue *rangeVal in hyperlinksArray)
            {
                NSRange range = [rangeVal rangeValue];
                NSString *link = [[self.attributedString string] substringWithRange:range];
                if (range.location != NSNotFound) {
                    [self.attributedString addAttribute:NSFontAttributeName value:hyperlinkFont range:range];
                    [self.attributedString addAttribute:NSForegroundColorAttributeName value:hyperlinkColor range:range];
                    //We need to set the attributedText here because links are being added to the label not the attributed text.
                    self.label.attributedText = self.attributedString;
                    [self.label addLinkToURL:[NSURL URLWithString:link] withRange:range];
                    //Old way, this does't allow styling though.
                    //[self.attributedString addAttribute:NSLinkAttributeName value:link range:range];
                }
            }
        }
        
        if (highlightMentions)
        {
            NSArray *mentionsArray = [self rangesOfString:@"(?:\\s|^)@\\w+" inString:[self.attributedString string]];
            for (NSValue *rangeVal in mentionsArray)
            {
                NSRange range = [rangeVal rangeValue];
                NSString *mention = [NSString stringWithFormat:@"%@%@", _definedMentionScheme, [[[self.attributedString string] substringWithRange:range] substringFromIndex:2]];
                if (range.location != NSNotFound) {
                    [self.attributedString addAttribute:NSFontAttributeName value:mentionFont range:range];
                    [self.attributedString addAttribute:NSForegroundColorAttributeName value:mentionColor range:range];
                    [self.label addLinkToURL:[NSURL URLWithString:mention] withRange:range];
                }
            }
        }
        
        if (highlightHashtags)
        {
            NSArray *hashtagsArray = [self rangesOfString:@"(?:\\s|^)#\\w+" inString:[self.attributedString string]];
            for (NSValue *rangeVal in hashtagsArray)
            {
                NSRange range = [rangeVal rangeValue];
                NSString *tag = [NSString stringWithFormat:@"%@%@", _definedHashtagScheme, [[[self.attributedString string] substringWithRange:range] substringFromIndex:2]];
                if (range.location != NSNotFound) {
                    [self.attributedString addAttribute:NSFontAttributeName value:hashtagFont range:range];
                    [self.attributedString addAttribute:NSForegroundColorAttributeName value:hashtagColor range:range];
                    [self.label addLinkToURL:[NSURL URLWithString:tag] withRange:range];
                }
            }
        }
        
        //Set attributed text
        self.label.attributedText = self.attributedString;
    }
    //If label doesn't support attributed text...
    else
    {
        self.label.text = text;
        self.label.textAlignment = textAlignment;
    }
}

- (void)formatMarkdownBlockMatchingRegex:(NSString *)matchRegex
            andReplaceCharsMatchingRegex:(NSString *)removeRegex
                               withChars:(NSString *)replaceChars
                          withAttributes:(NSDictionary *)attributes
{
    NSArray *matches = [self rangesOfString:matchRegex inString:[self.attributedString string]];
    for (NSValue *rangeVal in matches)
    {
        NSRange range = [rangeVal rangeValue];
        if (range.location != NSNotFound) {
            [self.attributedString addAttributes:attributes range:range];
        }
    }
    [[self.attributedString mutableString] replaceOccurrencesOfString:removeRegex withString:replaceChars options:NSRegularExpressionSearch range:NSMakeRange(0, self.attributedString.length)];
}

- (void)rewriteMarkdownUrlBlocksWithAttributes:(NSDictionary *)attributes
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[(.+)\\]\\((.+?)\\)" options:NO error:nil];
    NSArray *matches = [regex matchesInString:[self.attributedString string]
                                      options:0
                                        range:NSMakeRange(0, [[self.attributedString string] length])];
    for (NSTextCheckingResult *match in matches)
    {
        @try {
            NSRange fullRange = [match rangeAtIndex:0];
            NSRange titleRange = [match rangeAtIndex:1];
            NSRange linkRange = [match rangeAtIndex:2];
            
            NSString *fullString = [[self.attributedString string] substringWithRange:fullRange];
            NSString *titleString = [[self.attributedString string] substringWithRange:titleRange];
            NSString *linkString = [[self.attributedString string] substringWithRange:linkRange];
            
            [self.attributedString addAttributes:attributes range:fullRange];
            [self.label addLinkToURL:[NSURL URLWithString:linkString] withRange:NSMakeRange(titleRange.location - 1, titleRange.length)];
            //We need to set the attributedText here because links are being added to the label not the attributed text.
            self.label.attributedText = self.attributedString;
            
            //this is for debugging link positions only
            //self.label.activeLinkAttributes = @{(NSString *)kTTTBackgroundFillColorAttributeName: (id)[UIColor redColor].CGColor};
            
            [[self.attributedString mutableString] replaceOccurrencesOfString:fullString withString:titleString options:NO range:fullRange];
        }
        @catch (NSException *exception) {
            IX_LOG_DEBUG(@"ERROR: %@", exception);
        }
    }
}


- (void)rewriteColoredBlocks
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\{([#\\w,]+)\\|(.*?)\\}" options:NO error:nil];
    NSArray *matches = [regex matchesInString:[self.attributedString string]
                                      options:0
                                        range:NSMakeRange(0, [[self.attributedString string] length])];
    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator])
    {
        @try {
            NSRange fullRange = [match rangeAtIndex:0];
            NSRange colorRange = [match rangeAtIndex:1];
            NSRange textRange = [match rangeAtIndex:2];
            
            NSString *fullString = [[self.attributedString string] substringWithRange:fullRange];
            NSString *colorList = [[self.attributedString string] substringWithRange:colorRange];
            NSString *text = [[self.attributedString string] substringWithRange:textRange];
            
            NSArray *colorsArray = [colorList componentsSeparatedByString:@","];
            if (colorsArray.count > 0)
            {
                if (colorsArray[0] != nil)
                {
                    UIColor *foreColor;
                    if ([colorsArray[0] isEqualToString:@""])
                        foreColor = _baseTextColor;
                    else
                        foreColor = [UIColor colorWithString:colorsArray[0]];
                    [self.attributedString addAttribute:NSForegroundColorAttributeName value:foreColor range:fullRange];
                }
            }
            if (colorsArray.count > 1)
            {
                UIColor *backColor = ( colorsArray[1] != nil ) ? [UIColor colorWithString:colorsArray[1]] : nil;
                [self.attributedString addAttribute:(NSString *)kTTTBackgroundFillColorAttributeName value:(id)backColor.CGColor range:fullRange];
            }
            
            [[self.attributedString mutableString] replaceOccurrencesOfString:fullString withString:text options:NO range:fullRange];
            //We need to set the attributedText here because links are being added to the label not the attributed text.
            self.label.attributedText = self.attributedString;
        }
        @catch (NSException *exception) {
            IX_LOG_DEBUG(@"ERROR: %@", exception);
        }
    }
}

- (NSArray *)rangesOfString:(NSString *)searchString inString:(NSString *)str {
    NSMutableArray *results = [NSMutableArray array];
    NSRange searchRange = NSMakeRange(0, [str length]);
    NSRange range;
    while ((range = [str rangeOfString:searchString options:NSRegularExpressionSearch|NSCaseInsensitiveSearch range:searchRange]).location != NSNotFound) {
        [results addObject:[NSValue valueWithRange:range]];
        searchRange = NSMakeRange(NSMaxRange(range), [str length] - NSMaxRange(range));
    }
    return results;
}

- (NSTextAlignment)getTextAlignmentFromPropertyValue:(NSString *)property
{
    if ([property isEqualToString:kIXLeft])
    {
        return NSTextAlignmentLeft;
    }
    else if ([property isEqualToString:kIXRight])
    {
        return NSTextAlignmentRight;
    }
    else if ([property isEqualToString:kIXCenter])
    {
        return NSTextAlignmentCenter;
    }
    else if ([property isEqualToString:kIXJustified])
    {
        return NSTextAlignmentJustified;
    }
    else if ([property isEqualToString:kIXNatural])
    {
        return NSTextAlignmentNatural;
    }
    else
        return NSTextAlignmentLeft;
}

@end
