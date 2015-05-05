//
//  IXActionSheet.m
//  IgniteEngine
//
//  Created by Robert Walsh on 7/18/14.
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

#import "IXActionSheet.h"
#import "IXAppManager.h"
#import "IXNavigationViewController.h"

// Attributes
IX_STATIC_CONST_STRING kIXSheetStyle = @"style";
IX_STATIC_CONST_STRING kIXSheetTitle = @"title";
IX_STATIC_CONST_STRING kIXSheetButtonTitleCancel = @"buttons.cancel";
IX_STATIC_CONST_STRING kIXSheetButtonTitleDestructive = @"buttons.destructive";
IX_STATIC_CONST_STRING kIXSheetButtonTitleOthers = @"buttons.others";

// Attribute Accepted Values
IX_STATIC_CONST_STRING kIXSheetStyleDefault = @"default";
IX_STATIC_CONST_STRING kIXSheetStyleAutomatic = @"automatic";
IX_STATIC_CONST_STRING kIXSheetStyleBlackTranslucent = @"black.translucent";
IX_STATIC_CONST_STRING kIXSheetStyleBlackOpaque = @"black.opaque";

// Attribute Defaults
IX_STATIC_CONST_STRING kIXDefaultCancelButtonTitle = @"Cancel";

// Returns

// Events
IX_STATIC_CONST_STRING kIXDestructivePressed = @"destructive";
IX_STATIC_CONST_STRING kIXCancelPressed = @"cancelled";

// Functions
IX_STATIC_CONST_STRING kIXShowSheet = @"present";
IX_STATIC_CONST_STRING kIXDismissSheet = @"dismiss";

@interface IXActionSheet () <UIActionSheetDelegate>

@property (nonatomic,strong) UIActionSheet* actionSheet;
@property (nonatomic,strong) NSString* sheetTitle;
@property (nonatomic,assign) UIActionSheetStyle actionSheetStyle;
@property (nonatomic,strong) NSString* cancelButtonTitle;
@property (nonatomic,strong) NSString* destructiveButtonTitle;
@property (nonatomic,strong) NSArray* otherTitles;
@property (nonatomic,strong) NSMutableDictionary* titlesMap;

@end

@implementation IXActionSheet

-(void)buildView
{
    
}

-(void)applySettings

{
    [super applySettings];
    
    [self setActionSheetStyle:UIActionSheetStyleAutomatic];
    
    NSString* style = [[self attributeContainer] getStringValueForAttribute:kIXSheetStyle defaultValue:nil];
    if( [style isEqualToString:kIXSheetStyleDefault] )
    {
        [self setActionSheetStyle:UIActionSheetStyleDefault];
    }
    else if( [style isEqualToString:kIXSheetStyleBlackTranslucent] )
    {
        [self setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    }
    else if( [style isEqualToString:kIXSheetStyleBlackOpaque] )
    {
        [self setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    }
    
    [self setSheetTitle:[[self attributeContainer] getStringValueForAttribute:kIXSheetTitle defaultValue:nil]];
    [self setCancelButtonTitle:[[self attributeContainer] getStringValueForAttribute:kIXSheetButtonTitleCancel defaultValue:kIXDefaultCancelButtonTitle]];
    [self setDestructiveButtonTitle:[[self attributeContainer] getStringValueForAttribute:kIXSheetButtonTitleDestructive defaultValue:nil]];
    [self setOtherTitles:[[self attributeContainer] getCommaSeparatedArrayOfValuesForAttribute:kIXSheetButtonTitleOthers defaultValue:nil]];
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXAttributeContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXShowSheet] )
    {
        if( [self actionSheet] != nil && [[self actionSheet] isVisible] )
        {
            [[self actionSheet] dismissWithClickedButtonIndex:0 animated:NO];
            [self setActionSheet:nil];
        }
        
        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:[self sheetTitle]
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:[self destructiveButtonTitle]
                                                        otherButtonTitles:nil];
        _titlesMap = [NSMutableDictionary new];
        for( NSString* otherButton in [self otherTitles] )
        {
            NSArray* otherTitles = [otherButton componentsSeparatedByString:kIX_COLON_SEPERATOR];
            _titlesMap[[otherTitles lastObject]] = [otherTitles firstObject];
            [actionSheet addButtonWithTitle:[otherTitles lastObject]];
        }
        
        if ([self destructiveButtonTitle] != nil) {
            _titlesMap[[self destructiveButtonTitle]] = kIXDestructivePressed;
        }
        
        if( [self cancelButtonTitle] != nil )
        {
            [actionSheet addButtonWithTitle:[self cancelButtonTitle]];
            [actionSheet setCancelButtonIndex:[actionSheet numberOfButtons] - 1];
        }
        
        [self setActionSheet:actionSheet];
        [[self actionSheet] showInView:[[[IXAppManager sharedAppManager] rootViewController] view]];
    }
    else if( [functionName isEqualToString:kIXDismissSheet] )
    {
        if( [self actionSheet] != nil && [[self actionSheet] isVisible] )
        {
            [[self actionSheet] dismissWithClickedButtonIndex:0 animated:NO];
            [self setActionSheet:nil];
        }
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == [actionSheet cancelButtonIndex] )
    {
        [[self actionContainer] executeActionsForEventNamed:kIXCancelPressed];
    }
    else
    {
        NSString* buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        NSString* eventName;
        if ([_titlesMap objectForKey:buttonTitle]) {
            eventName = _titlesMap[buttonTitle];
        } else {
            eventName = buttonTitle;
        }
        [[self actionContainer] executeActionsForEventNamed:eventName];
    }
}

@end