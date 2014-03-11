//
//  IXAttributedText.h
//  Ignite_iOS_Engine
//
//  Created by Brandon on 3/09/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXBaseControl.h"
#import "IXLogger.h"

@interface IXAttributedText : IXBaseControl

@property (nonatomic,strong) UITextView* textView;
@property (nonatomic,strong) NSMutableAttributedString* attributedString;

@end

@implementation IXAttributedText

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

-(void)applySettings
{
    [super applySettings];
    
    //self.attributedLabel.lineBreakMode = NSLineBreakByWordWrapping;
    //self.attributedLabel.numberOfLines = 0;
    self.textView.textAlignment = NSTextAlignmentCenter;
    self.textView.backgroundColor = [self.propertyContainer getColorPropertyValue:@"background.color" defaultValue:[UIColor clearColor]];
    [self.textView setUserInteractionEnabled:NO];
    
    NSString* text = [[self propertyContainer] getStringPropertyValue:@"text" defaultValue:@""];
    
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
        CGFloat lineSpacing = [self.propertyContainer getFloatPropertyValue:@"text.line.spacing" defaultValue:-0.01];
        CGFloat minLineHeight = [self.propertyContainer getFloatPropertyValue:@"text.line.minheight" defaultValue:-0.01];
        CGFloat maxLineHeight = [self.propertyContainer getFloatPropertyValue:@"text.line.maxheight" defaultValue:-0.01];
        
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
        
        if (highlightMentions)
        {
            NSArray *mentionsArray = [self rangesOfString:@"(?:\\s|^)@\\w+" inString:[self.attributedString string]];
            for (NSValue *rangeValue in mentionsArray)
            {
                NSRange range = [rangeValue rangeValue];
                if (range.location != NSNotFound) {
                    [self.attributedString addAttribute:NSFontAttributeName value:mentionFont range:range];
                    [self.attributedString addAttribute:NSForegroundColorAttributeName value:mentionColor range:range];
                }
            }
        }
        
        if (highlightHashtags)
        {
            NSArray *hashtagsArray = [self rangesOfString:@"(?:\\s|^)#\\w+" inString:[self.attributedString string]];
            for (NSValue *rangeValue in hashtagsArray)
            {
                NSRange range = [rangeValue rangeValue];
                if (range.location != NSNotFound) {
                    [self.attributedString addAttribute:NSFontAttributeName value:hashtagFont range:range];
                    [self.attributedString addAttribute:NSForegroundColorAttributeName value:hashtagColor range:range];
                }
            }
        }
        
        if (highlightHyperlinks)
        {
            NSArray *hyperlinksArray = [self rangesOfString:@"\\b([A-Za-z]+://[^\\s(),]+|[^\\s(),]+\\.(?:[^\\s(),]{2,}))" inString:[self.attributedString string]];
            for (NSValue *rangeValue in hyperlinksArray)
            {
                NSRange range = [rangeValue rangeValue];
                if (range.location != NSNotFound) {
                    [self.attributedString addAttribute:NSFontAttributeName value:hyperlinkFont range:range];
                    [self.attributedString addAttribute:NSForegroundColorAttributeName value:hyperlinkColor range:range];
                }
            }
        }
        
        self.textView.attributedText = self.attributedString;
        
        //Should we parse markdown you think?
        if (shouldParseMarkdown)
        {
            UIColor *codeColor = [self.propertyContainer getColorPropertyValue:@"code.color" defaultValue:[UIColor blackColor]];
            UIColor *codeHighlightColor = [self.propertyContainer getColorPropertyValue:@"code.highlight.color" defaultValue:[[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:0.3]];
            UIColor *codeHighlightBorderColor = [self.propertyContainer getColorPropertyValue:@"code.highlight.border.color" defaultValue:[[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]];
            
            //Format bold **bold**
            [self formatMarkdownBlockMatchingRegex:@"\\*{2}(?!\\s).+?(?<!\\s)\\*{2}"
                       andRemoveCharsMatchingRegex:@"(\\*{2}(?!\\s)|(?<!\\s)\\*{2})"
                                     addAttributes:@{
                                                     NSFontAttributeName: [UIFont boldSystemFontOfSize:defaultFont.pointSize]
                                                     }];
            
            //Format italic *italic*
            [self formatMarkdownBlockMatchingRegex:@"\\*(?!\\s).+?(?<!\\s)\\*"
                       andRemoveCharsMatchingRegex:@"(\\*(?!\\s)|(?<!\\s)\\*)"
                                     addAttributes:@{
                                                     NSFontAttributeName: [UIFont italicSystemFontOfSize:defaultFont.pointSize]
                                                     }];
            
            
            //Format underline __underline__
            [self formatMarkdownBlockMatchingRegex:@"\\_{2}(?!\\s).+?(?<!\\s)\\_{2}"
                       andRemoveCharsMatchingRegex:@"(\\_{2}(?!\\s)|(?<!\\s)\\_{2})"
                                     addAttributes:@{
                                                     NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                                     }];
            
            //Format code `code`
            [self formatMarkdownCodeBlockWithAttributes:@{
                                                     //really wanted to add a code font size offset in here, but it breaks the computation of the outline box
                                                     NSFontAttributeName: [UIFont fontWithName:@"Menlo-Regular" size:defaultFont.pointSize],
                                                     NSForegroundColorAttributeName: codeColor
                                                     }
                                withHighlightProperties:@{
                                                          @"backgroundColor": codeHighlightColor,
                                                          @"borderColor": codeHighlightBorderColor
                                                          }];
            
            //And finally update textview one last time
            self.textView.attributedText = self.attributedString;
        }
    }
    
    // If attributed text is NOT supported (iOS5-)
    else {
        self.textView.text = text;
    }
}

- (void)formatMarkdownBlockMatchingRegex:(NSString *)matchRegex
             andRemoveCharsMatchingRegex:(NSString *)removeRegex
                           addAttributes:(NSDictionary *)attributesDict
{
    NSArray *matchesArray = [self rangesOfString:matchRegex inString:[self.attributedString string]];
    for (NSValue *rangeValue in matchesArray)
    {
        NSRange range = [rangeValue rangeValue];
        if (range.location != NSNotFound) {
            for (id key in attributesDict)
            {
                id value = [attributesDict objectForKey:key];
                [self.attributedString addAttribute:key value:value range:range];
            }
        }
    }
    [[self.attributedString mutableString] replaceOccurrencesOfString:removeRegex withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, self.attributedString.length)];
}

- (void)formatMarkdownCodeBlockWithAttributes:(NSDictionary *)attributesDict withHighlightProperties:(NSDictionary *)highlightProperties
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"`.+?`" options:NO error:nil];
    NSArray *matchesArray = [regex matchesInString:[self.attributedString string] options:NO range:NSMakeRange(0, self.attributedString.length)];
    for (NSTextCheckingResult *match in matchesArray)
    {
        NSRange range = [match range];
        if (range.location != NSNotFound) {
            
            //strip first and last `
            [[self.attributedString mutableString] replaceOccurrencesOfString:@"(^`|`$)" withString:@"" options:NSRegularExpressionSearch range:range];

            //range.length = range.length - 1;
            //range.location = range.location - 1;
            //[[self.attributedString mutableString] replaceCharactersInRange:NSMakeRange(range.location, 1) withString:@""];
            //adjust range for stripping last `
            //range.location = range.location - 1;
            //range.length = range.length - 1;
            
            //[[self.attributedString mutableString] replaceCharactersInRange:NSMakeRange(range.location, 1) withString:@""];
            //and adjust again
            
            //Need to update text here so we can accurately determine code block locations
            self.textView.attributedText = self.attributedString;
            
            CGRect codeRect = [self frameOfTextRange:range];
            UIView *highlightView = [[UIView alloc] initWithFrame:codeRect];
            highlightView.layer.cornerRadius = 4;
            highlightView.layer.borderWidth = 1;
            highlightView.backgroundColor = [highlightProperties valueForKey:@"backgroundColor"];
            highlightView.layer.borderColor = [[highlightProperties valueForKey:@"borderColor"] CGColor];
            [self.contentView insertSubview:highlightView atIndex:0];
            for (id key in attributesDict)
            {
                id value = [attributesDict objectForKey:key];
                [self.attributedString addAttribute:key value:value range:range];
            }
            
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

- (CGRect)frameOfTextRange:(NSRange)range
{
    UITextPosition *beginning = self.textView.beginningOfDocument;
    UITextPosition *start = [self.textView positionFromPosition:beginning offset:range.location];
    UITextPosition *end = [self.textView positionFromPosition:start offset:range.length];
    UITextRange *textRange = [self.textView textRangeFromPosition:start toPosition:end];
    CGRect rect = [self.textView firstRectForRange:textRange];
    
    return [self.textView convertRect:rect fromView:self.textView.textInputView];
}

@end
