//
//  IXAttributedText.h
//  Ignite_iOS_Engine
//
//  Created by Brandon on 3/09/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXBaseControl.h"
#import "IXLogger.h"
#import "ColorUtils.h"

@interface IX_deprecated_AttributedText : IXBaseControl <UITextViewDelegate>

@property (nonatomic,strong) UITextView* textView;
@property (nonatomic,strong) NSMutableAttributedString* attributedString;

@end

@implementation IX_deprecated_AttributedText

-(void)buildView
{
    [super buildView];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectZero];
    [[self contentView] addSubview:self.textView];
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [self.textView setFrame:rect];
    [self.textView sizeToFit];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return [self.textView sizeThatFits:size];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    NSLog(@"%@", URL);
    return NO;
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSLog(@"Changed");
}

-(void)applySettings
{
    [super applySettings];
    
    //self.attributedLabel.numberOfLines = 0;
    self.textView.backgroundColor = [self.propertyContainer getColorPropertyValue:@"background.color" defaultValue:[UIColor clearColor]];
    self.textView.userInteractionEnabled = NO;
    self.textView.delaysContentTouches = NO;
    self.textView.editable = NO;
    self.textView.dataDetectorTypes = UIDataDetectorTypeAll;
    self.textView.delegate = self;


    //NSLinkAttributeName isn't backwards compatible with iOS 6. This should gracefully fail, at least adding URL actions to substrings.
    //Should probably implement this for pre-ios7? http://fredandrandall.com/blog/2011/08/16/automatic-link-detection-in-an-nstextview/
    //if (!NSClassFromString(NSLinkAttributeName))
    //    self.textView.linkTextAttributes = NO;

    NSString* text = [self.propertyContainer getStringPropertyValue:@"text" defaultValue:@""];
    
    // If attributed text is supported (iOS6+)
    if ([self.textView respondsToSelector:@selector(setAttributedText:)]) {
        
        BOOL highlightMentions = [self.propertyContainer getBoolPropertyValue:@"highlight.mentions" defaultValue:true];
        BOOL highlightHashtags = [self.propertyContainer getBoolPropertyValue:@"highlight.hashtags" defaultValue:true];
        BOOL highlightHyperlinks = [self.propertyContainer getBoolPropertyValue:@"highlight.hyperlinks" defaultValue:true];
        BOOL shouldParseMarkdown = [self.propertyContainer getBoolPropertyValue:@"markdown" defaultValue:false];
        
        UIColor *textColor = [self.propertyContainer getColorPropertyValue:@"text.color" defaultValue:[UIColor blackColor]];
        UIColor *mentionColor = [self.propertyContainer getColorPropertyValue:@"mention.color" defaultValue:[UIColor blackColor]];
        UIColor *hashtagColor = [self.propertyContainer getColorPropertyValue:@"hashtag.color" defaultValue:[UIColor blackColor]];
        UIColor *hyperlinkColor = [self.propertyContainer getColorPropertyValue:@"hyperlink.color" defaultValue:[UIColor blackColor]];
       
        UIFont *defaultFont = [self.propertyContainer getFontPropertyValue:@"font" defaultValue:[UIFont systemFontOfSize:16.0f]];
        UIFont *mentionFont = [self.propertyContainer getFontPropertyValue:@"mention.font" defaultValue:defaultFont];
        UIFont *hashtagFont = [self.propertyContainer getFontPropertyValue:@"hashtag.font" defaultValue:defaultFont];
        UIFont *hyperlinkFont = [self.propertyContainer getFontPropertyValue:@"hyperlink.font" defaultValue:defaultFont];
        
        CGFloat textKerning = [self.propertyContainer getFloatPropertyValue:@"text.kerning" defaultValue:0];
        CGFloat lineSpacing = [self.propertyContainer getFloatPropertyValue:@"line.spacing" defaultValue:-0.01];
        CGFloat minLineHeight = [self.propertyContainer getFloatPropertyValue:@"line.height.min" defaultValue:-0.01];
        CGFloat maxLineHeight = [self.propertyContainer getFloatPropertyValue:@"line.height.max" defaultValue:-0.01];
        
        //Define attributedString
        self.attributedString = [[NSMutableAttributedString alloc] initWithString:text];
        NSRange lengthOfAttributedString = NSMakeRange(0, self.attributedString.length);
        
        //Set default text styling (font, size, color, kerning)
        [self.attributedString addAttribute:NSForegroundColorAttributeName value:textColor range:lengthOfAttributedString];
        [self.attributedString addAttribute:NSFontAttributeName value:defaultFont range:lengthOfAttributedString];
        [self.attributedString addAttribute:NSKernAttributeName value:[NSNumber numberWithFloat:textKerning] range:lengthOfAttributedString];
        
        //Set line height attributes
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        if (lineSpacing != -0.01)
            paragraphStyle.lineSpacing = lineSpacing;
        if (minLineHeight != -0.01)
            paragraphStyle.minimumLineHeight = minLineHeight;
        if (maxLineHeight != -0.01)
            paragraphStyle.maximumLineHeight = maxLineHeight;
        
        [self.attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:lengthOfAttributedString];
        
        
        
        
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
                    //This isn't backwards compatible with iOS 6. Need a fix?
                    [self.attributedString addAttribute:NSLinkAttributeName value:link range:range];
                }
            }
        }
        
        if (highlightMentions)
        {
            NSArray *mentionsArray = [self rangesOfString:@"(?:\\s|^)@\\w+" inString:[self.attributedString string]];
            for (NSValue *rangeVal in mentionsArray)
            {
                NSRange range = [rangeVal rangeValue];
                NSString *mentionScheme = [self.propertyContainer getStringPropertyValue:@"mention.scheme" defaultValue:@"mention:"];
                NSString *mention = [NSString stringWithFormat:@"%@%@", mentionScheme, [[[self.attributedString string] substringWithRange:range] substringFromIndex:2]];
                if (range.location != NSNotFound) {
                    [self.attributedString addAttribute:NSFontAttributeName value:mentionFont range:range];
                    [self.attributedString addAttribute:NSForegroundColorAttributeName value:mentionColor range:range];
                    [self.attributedString addAttribute:@"mention_touched" value:@(YES) range:range];
                    //This isn't backwards compatible with iOS 6. Need a fix?
                    [self.attributedString addAttribute:NSLinkAttributeName value:mention range:range];
                }
            }
        }
        
        if (highlightHashtags)
        {
            NSArray *hashtagsArray = [self rangesOfString:@"(?:\\s|^)#\\w+" inString:[self.attributedString string]];
            for (NSValue *rangeVal in hashtagsArray)
            {
                NSRange range = [rangeVal rangeValue];
                NSString *tagScheme = [self.propertyContainer getStringPropertyValue:@"tag.scheme" defaultValue:@"tag:"];
                NSString *tag = [NSString stringWithFormat:@"%@%@", tagScheme, [[[self.attributedString string] substringWithRange:range] substringFromIndex:2]];
                if (range.location != NSNotFound) {
                    [self.attributedString addAttribute:NSFontAttributeName value:hashtagFont range:range];
                    [self.attributedString addAttribute:NSForegroundColorAttributeName value:hashtagColor range:range];
                    //This isn't backwards compatible with iOS 6. Need a fix?
                    [self.attributedString addAttribute:NSLinkAttributeName value:tag range:range];
                }
            }
        }
        
        //Should we parse markdown you think?
        if (shouldParseMarkdown)
        {
            //Format bold **bold**
            [self formatMarkdownBlockMatchingRegex:@"\\*{2}(?!\\s).+?(?<!\\s)\\*{2}"
                       andReplaceCharsMatchingRegex:@"(\\*{2}(?!\\s)|(?<!\\s)\\*{2})"
                                         withChars:@""
                                     thenAddAttributes:@{
                                                     NSFontAttributeName: [UIFont boldSystemFontOfSize:defaultFont.pointSize]
                                                     }];
            
            //Format italic *italic*
            [self formatMarkdownBlockMatchingRegex:@"\\*(?!\\s).+?(?<!\\s)\\*"
                       andReplaceCharsMatchingRegex:@"(\\*(?!\\s)|(?<!\\s)\\*)"
                                         withChars:@""
                                    thenAddAttributes:@{
                                                     NSFontAttributeName: [UIFont italicSystemFontOfSize:defaultFont.pointSize]
                                                     }];
            
            
            //Format underline __underline__
            [self formatMarkdownBlockMatchingRegex:@"\\_{2}(?!\\s).+?(?<!\\s)\\_{2}"
                       andReplaceCharsMatchingRegex:@"(\\_{2}(?!\\s)|(?<!\\s)\\_{2})"
                                         withChars:@""
                                     thenAddAttributes:@{
                                                     NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                                     }];
            
            //Define code font properties
            UIFont *codeFont = [UIFont fontWithName:@"Menlo-Regular" size:defaultFont.pointSize - 3];
            UIColor *codeColor = [self.propertyContainer getColorPropertyValue:@"code.color" defaultValue:[UIColor blackColor]];
            UIColor *codeHighlightColor = [self.propertyContainer getColorPropertyValue:@"code.highlight.color" defaultValue:[[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:0.3]];

            //Format code `code`
            //This block will need to be replaced with the one below once we're ready to implement in production
            [self formatMarkdownBlockMatchingRegex:@"`.*?`"
                      andReplaceCharsMatchingRegex:@""
                                         withChars:@""
                                 thenAddAttributes:@{
                                                     NSFontAttributeName: codeFont,
                                                     NSForegroundColorAttributeName: codeColor,
                                                     NSBackgroundColorAttributeName: codeHighlightColor,
                                                     NSKernAttributeName: @-0.5
                                                     }];
            
            //Rewrite [markdown](urls)
            [self rewriteMarkdownUrlBlocksWithAttributes:@{
                                                           NSFontAttributeName: hyperlinkFont,
                                                           NSForegroundColorAttributeName: hyperlinkColor,
                                                           NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                                           }];
            
            //Rewrite {#FFFFFF,#000000|colored and highlighted text}
            [self rewriteColoredBlocks];
            
            
            //Format code `code` with fancy backgrounds
            
             
             //This bit sadly isn't up to snuff yet; commenting it out until we're ready to rock
            
            /*
             [self formatMarkdownBlockMatchingRegex:@"`.*?`"
                       andReplaceCharsMatchingRegex:@""
                                          withChars:@""
                                    thenAddAttributes:@{
                                                     //really wanted to add a code font size offset in here, but it breaks the computation of the outline box
                                                     NSFontAttributeName: codeFont,
                                                     NSForegroundColorAttributeName: codeColor
                                                     }];
            */
        }
        
        //Set alignment and apply text
        self.textView.attributedText = self.attributedString;
        self.textView.textAlignment = [self getTextAlignmentFromPropertyValue:[self.propertyContainer getStringPropertyValue:@"text.align" defaultValue:@"left"]];
        
        _textView.textAlignment = NSTextAlignmentCenter;
         
        //update static length
        //lengthOfAttributedString = NSMakeRange(0, self.attributedString.length);
        
        //And then we have to draw the code block rectangles
        
        //The code block stuff that really isn't ready for production. It's miscalculating where to draw the rectangles
         
        if (shouldParseMarkdown)
        {
            UIColor *codeHighlightColor = [self.propertyContainer getColorPropertyValue:@"code.highlight.color" defaultValue:[[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:0.3]];
            UIColor *codeHighlightBorderColor = [self.propertyContainer getColorPropertyValue:@"code.highlight.border.color" defaultValue:[[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]];
            
            //Add code outlines
            [self formatMarkdownCodeBlockWithAttributes:@{
                                                          @"backgroundColor": codeHighlightColor,
                                                          @"borderColor": codeHighlightBorderColor
                                                          }];
            
            //We have to do this once more after replacing the `
            self.textView.attributedText = self.attributedString;
        }
        self.textView.attributedText = self.attributedString;

    }
    
    // If attributed text is NOT supported (iOS5-)
    else {
        self.textView.text = text;
    }
}

- (void)formatMarkdownBlockMatchingRegex:(NSString *)matchRegex
             andReplaceCharsMatchingRegex:(NSString *)removeRegex
                               withChars:(NSString *)replaceChars
                           thenAddAttributes:(NSDictionary *)attributes
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
            //This isn't backwards compatible with iOS 6. Need a fix?
            [self.attributedString addAttribute:NSLinkAttributeName value:linkString range:fullRange];
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
    for (NSTextCheckingResult *match in matches)
    {
        @try {
            NSRange fullRange = [match rangeAtIndex:0];
            NSRange titleRange = [match rangeAtIndex:1];
            NSRange textRange = [match rangeAtIndex:2];
            
            NSString *fullString = [[self.attributedString string] substringWithRange:fullRange];
            NSString *colorList = [[self.attributedString string] substringWithRange:titleRange];
            NSString *text = [[self.attributedString string] substringWithRange:textRange];
            
            NSArray *colorsArray = [colorList componentsSeparatedByString:@","];
            if (colorsArray.count > 0)
            {
                
                UIColor *foreColor = ( colorsArray[0] != nil ) ? [UIColor colorWithString:colorsArray[0]] : nil;
                [self.attributedString addAttribute:NSForegroundColorAttributeName value:foreColor range:fullRange];
            }
            if (colorsArray.count > 1)
            {
                UIColor *backColor = ( colorsArray[1] != nil ) ? [UIColor colorWithString:colorsArray[1]] : nil;
                [self.attributedString addAttribute:NSBackgroundColorAttributeName value:backColor range:fullRange];
            }

            [[self.attributedString mutableString] replaceOccurrencesOfString:fullString withString:text options:NO range:fullRange];
        }
        @catch (NSException *exception) {
            DDLogDebug(@"ERROR: %@", exception);
        }
    }
}

/*
 
 //Not implemented
 */
- (void)formatMarkdownCodeBlockWithAttributes:(NSDictionary *)attributesDict
{
    NSMutableString *theString = [_textView.attributedText.string mutableCopy];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"`.+?`" options:NO error:nil];
    NSArray *matchesArray = [regex matchesInString:theString options:NO range:NSMakeRange(0, theString.length)];
    
    NSMutableAttributedString *theAttributedString = self.attributedString;
    for (NSTextCheckingResult *match in matchesArray)
    {
        NSRange range = [match range];
        if (range.location != NSNotFound) {
            [theAttributedString addAttributes:attributesDict range:range];
        }
    }
    
    _textView.attributedText = theAttributedString;
    
    for (NSTextCheckingResult *match in matchesArray)
    {
        NSRange range = [match range];
        if (range.location != NSNotFound) {
            
            CGRect codeRect = [self frameOfTextRange:range];
            UIView *highlightView = [[UIView alloc] initWithFrame:codeRect];
            highlightView.layer.cornerRadius = 4;
            highlightView.layer.borderWidth = 1;
            highlightView.backgroundColor = [UIColor yellowColor];
            highlightView.layer.borderColor = [[UIColor redColor] CGColor];
            [_textView insertSubview:highlightView atIndex:0];
        }
    }
}

- (void)formatSelectorBlockMatchingRegex:(NSString *)matchRegex
                                withFont:(UIFont *)font
                               withColor:(UIColor *)color
                            isUnderlined:(BOOL *)isUnderlined
{
    NSArray *highlightsArray = [self rangesOfString:matchRegex inString:[self.attributedString string]];
    for (NSValue *rangeVal in highlightsArray)
    {
        NSRange range = [rangeVal rangeValue];
        if (range.location != NSNotFound) {
            [self.attributedString addAttribute:NSFontAttributeName value:font range:range];
            [self.attributedString addAttribute:NSForegroundColorAttributeName value:color range:range];
            if (isUnderlined)
                [self.attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:range];
        }
    }
}
//*/


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

/*
 
 Not implemented
 */
- (CGRect)frameOfTextRange:(NSRange)range
{
    self.textView.selectedRange = range;
    UITextRange *textRange = [self.textView selectedTextRange];
    CGRect rect = [self.textView firstRectForRange:textRange];
    return rect;
}

 //*/

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
    return NSTextAlignmentLeft;
}

@end
