//
//  IXAText.m
//  Ignite_iOS_Engine
//
//  Created by Brandon on 3/13/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXBaseControl.h"
#import "IXLogger.h"
#import "TTTAttributedLabel.h"
#import "ColorUtils.h"

//Read-only properties
static NSString* const kIXSelectedMention = @"selected_mention";
static NSString* const kIXSelectedHashtag = @"selected_hashtag";
static NSString* const kIXSelectedUrl = @"selected_url";

static NSString* kIXCurrentTouchedMention;
static NSString* kIXCurrentTouchedHashtag;
static NSURL* kIXCurrentTouchedUrl;

static NSString* kIXDefinedMentionScheme;
static NSString* kIXDefinedHashtagScheme;

static UIColor* kIXBaseTextColor;

//BOOLs - enable or disable these
static NSString* const kIXShouldHighlightMentions = @"highlight_mentions"; //default = true
static NSString* const kIXShouldHighlightHashtags = @"highlight_hashtags"; //true
static NSString* const kIXShouldHighlightHyperlinks = @"highlight_Hyperlinks"; //true
static NSString* const kIXShouldParseMarkdown = @"parse_markdown"; //false

//Defined styling properties
static NSString* const kIXText = @"text";
static NSString* const kIXTextColor = @"text.color";
static NSString* const kIXFont = @"font";

static NSString* const kIXBackgroundColor = @"background.color";

static NSString* const kIXMentionScheme = @"mention.scheme";
static NSString* const kIXMentionColor = @"mention.color";
static NSString* const kIXMentionFont = @"mention.font";

static NSString* const kIXHashtagScheme = @"hashtag.scheme";
static NSString* const kIXHashtagColor = @"hashtag.color";
static NSString* const kIXHashtagFont = @"hashtag.font";

static NSString* const kIXHyperlinkColor = @"hyperlink.color";
static NSString* const kIXHyperlinkFont = @"hyperlink.font";

//Markdown code properties
static NSString* const kIXCodeFont = @"code.font";
static NSString* const kIXCodeColor = @"code.color";
static NSString* const kIXCodeBackgroundColor = @"code.background.color";
static NSString* const kIXCodeBorderColor = @"code.border.color";
static NSString* const kIXCodeBorderRadius = @"code.border.radius";

//Paragraph properties
static NSString* const kIXTextKerning = @"kerning";
static NSString* const kIXTextAlign = @"text.align";
static NSString* const kIXLineSpacing = @"line.spacing";
static NSString* const kIXLineHeightMin = @"line.height.min";
static NSString* const kIXLineHeightMax = @"line.height.max";


@interface IXAttributedText : IXBaseControl <TTTAttributedLabelDelegate>

@property (nonatomic,strong) TTTAttributedLabel* label;
@property (nonatomic,strong) NSMutableAttributedString* attributedString;

@end

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
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    
    // Note: https://github.com/mattt/TTTAttributedLabel/pull/302 re:
    // potential crash if view is deallocated WHILE the long press is activated
    if (self.label.selectionState == TTTAttributedLabelSelectionStateLongPress)
    {
        [self performActionsForSelector:@"long_press" withUrl:url];
        DDLogDebug(@"Detected long_press for url: %@", url);
    }
    else if (self.label.selectionState == TTTAttributedLabelSelectionStateTouchUp)
    {
        [self performActionsForSelector:@"touch_up" withUrl:url];
        DDLogDebug(@"Detected touch_up for url: %@", url);
    }
}

-(void)performActionsForSelector:(NSString *)selector withUrl:(NSURL *)url
{
    //We need to nil out existing properties to prevent bad data
    kIXCurrentTouchedMention = nil;
    kIXCurrentTouchedHashtag = nil;
    kIXCurrentTouchedUrl = nil;
    
    //String is a mention @
    if ([[NSString stringWithFormat:@"%@", url] hasPrefix:kIXDefinedMentionScheme])
    {
        kIXCurrentTouchedMention = url.host;
        [[self actionContainer] executeActionsForEventNamed:[NSString stringWithFormat:@"%@_mention", selector]];
    }
    //String is a hashtag #
    else if ([[NSString stringWithFormat:@"%@", url] hasPrefix:kIXDefinedHashtagScheme])
    {
        kIXCurrentTouchedHashtag = url.host;
        [[self actionContainer] executeActionsForEventNamed:[NSString stringWithFormat:@"%@_hashtag", selector]];
    }
    //String is a url
    else if ([[NSString stringWithFormat:@"%@", url] hasPrefix:@"http"] || [[NSString stringWithFormat:@"%@", url] hasPrefix:@"ftp"])
    {
        kIXCurrentTouchedUrl = url;
        [[self actionContainer] executeActionsForEventNamed:[NSString stringWithFormat:@"%@_url", selector]];
    }
    
}

-(NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = nil;
    if( [propertyName isEqualToString:kIXSelectedMention] && kIXCurrentTouchedMention )
    {
        returnValue = [NSString stringWithFormat:@"%@", kIXCurrentTouchedMention];
    }
    else if( [propertyName isEqualToString:kIXSelectedHashtag] && kIXCurrentTouchedHashtag )
    {
        returnValue = [NSString stringWithFormat:@"%@", kIXCurrentTouchedHashtag];
    }
    else if( [propertyName isEqualToString:kIXSelectedUrl] && kIXCurrentTouchedUrl )
    {
        returnValue = [NSString stringWithFormat:@"%@", kIXCurrentTouchedUrl];
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
    NSString* text = [self.propertyContainer getStringPropertyValue:kIXText defaultValue:@""];
    kIXDefinedMentionScheme = [self.propertyContainer getStringPropertyValue:kIXMentionScheme defaultValue:@"mention://"];
    kIXDefinedHashtagScheme = [self.propertyContainer getStringPropertyValue:kIXHashtagScheme defaultValue:@"hashtag://"];
    
    self.label.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    self.label.textColor = [UIColor blackColor];
    self.label.lineBreakMode = NSLineBreakByWordWrapping;
    self.label.numberOfLines = 0;
    self.label.userInteractionEnabled = YES;
    self.label.delegate = self;
    
    self.label.backgroundColor = [self.propertyContainer getColorPropertyValue:kIXBackgroundColor defaultValue:[UIColor clearColor]];
    
    //Set alignment
    NSString* textAlignmentString = [self.propertyContainer getStringPropertyValue:kIXTextAlign defaultValue:@"left"];
    NSTextAlignment textAlignment = [self getTextAlignmentFromPropertyValue:textAlignmentString];
    
    //Double check that the label supports attributed text
    if ([self.label respondsToSelector:@selector(setAttributedText:)])
    {
        BOOL highlightMentions = [self.propertyContainer getBoolPropertyValue:kIXShouldHighlightMentions defaultValue:true];
        BOOL highlightHashtags = [self.propertyContainer getBoolPropertyValue:kIXShouldHighlightHashtags defaultValue:true];
        BOOL highlightHyperlinks = [self.propertyContainer getBoolPropertyValue:kIXShouldHighlightHyperlinks defaultValue:true];
        BOOL shouldParseMarkdown = [self.propertyContainer getBoolPropertyValue:kIXShouldParseMarkdown defaultValue:false];
        
        kIXBaseTextColor = [self.propertyContainer getColorPropertyValue:kIXTextColor defaultValue:[UIColor blackColor]];
        UIColor *mentionColor = [self.propertyContainer getColorPropertyValue:kIXMentionColor defaultValue:[UIColor blackColor]];
        UIColor *hashtagColor = [self.propertyContainer getColorPropertyValue:kIXHashtagColor defaultValue:[UIColor blackColor]];
        UIColor *hyperlinkColor = [self.propertyContainer getColorPropertyValue:kIXHyperlinkColor defaultValue:[UIColor blackColor]];
        
        UIFont *defaultFont = [self.propertyContainer getFontPropertyValue:kIXFont defaultValue:[UIFont systemFontOfSize:16.0f]];
        UIFont *mentionFont = [self.propertyContainer getFontPropertyValue:kIXMentionFont defaultValue:defaultFont];
        UIFont *hashtagFont = [self.propertyContainer getFontPropertyValue:kIXHashtagFont defaultValue:defaultFont];
        UIFont *hyperlinkFont = [self.propertyContainer getFontPropertyValue:kIXHyperlinkFont defaultValue:defaultFont];
        
        CGFloat textKerning = [self.propertyContainer getFloatPropertyValue:kIXTextKerning defaultValue:0];
        CGFloat lineSpacing = [self.propertyContainer getFloatPropertyValue:kIXLineSpacing defaultValue:-0.01];
        CGFloat minLineHeight = [self.propertyContainer getFloatPropertyValue:kIXLineHeightMin defaultValue:-0.01];
        CGFloat maxLineHeight = [self.propertyContainer getFloatPropertyValue:kIXLineHeightMax defaultValue:-0.01];
        
        //Define attributedString
        self.attributedString = [[NSMutableAttributedString alloc] initWithString:text];
        NSRange lengthOfAttributedString = NSMakeRange(0, self.attributedString.length);
        
        //Set default text styling (font, size, color, kerning)
        [self.attributedString addAttribute:NSForegroundColorAttributeName value:kIXBaseTextColor range:lengthOfAttributedString];
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
            UIFont *codeFont = [self.propertyContainer getFontPropertyValue:kIXCodeFont defaultValue:[UIFont fontWithName:@"Menlo-Regular" size:defaultFont.pointSize - 2]];
            UIColor *codeColor = [self.propertyContainer getColorPropertyValue:kIXCodeColor defaultValue:[UIColor blackColor]];
            UIColor *codeBackgroundColor = [self.propertyContainer getColorPropertyValue:kIXCodeBackgroundColor defaultValue:[[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:0.3]];
            UIColor *codeBorderColor = [self.propertyContainer getColorPropertyValue:kIXCodeBorderColor defaultValue:[[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:0.7]];
            
            NSNumber *codeBorderRadius = [NSNumber numberWithInteger:[self.propertyContainer getIntPropertyValue:kIXCodeBorderRadius defaultValue:3]];
            
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
                NSString *mention = [NSString stringWithFormat:@"%@%@", kIXDefinedMentionScheme, [[[self.attributedString string] substringWithRange:range] substringFromIndex:2]];
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
                NSString *tag = [NSString stringWithFormat:@"%@%@", kIXDefinedHashtagScheme, [[[self.attributedString string] substringWithRange:range] substringFromIndex:2]];
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
            DDLogDebug(@"ERROR: %@", exception);
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
                        foreColor = kIXBaseTextColor;
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
            DDLogDebug(@"ERROR: %@", exception);
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
    if ([property isEqualToString:@"left"])
    {
        return NSTextAlignmentLeft;
    }
    else if ([property isEqualToString:@"right"])
    {
        return NSTextAlignmentRight;
    }
    else if ([property isEqualToString:@"center"])
    {
        return NSTextAlignmentCenter;
    }
    else if ([property isEqualToString:@"justified"])
    {
        return NSTextAlignmentJustified;
    }
    else if ([property isEqualToString:@"natural"])
    {
        return NSTextAlignmentNatural;
    }
    else
        return NSTextAlignmentLeft;
}

@end
