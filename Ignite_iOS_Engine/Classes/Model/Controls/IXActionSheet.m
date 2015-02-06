//
//  IXActionSheet.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 7/18/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
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

// Attribute Value Available Parameters
IX_STATIC_CONST_STRING kIXSheetStyleDefault = @"default";
IX_STATIC_CONST_STRING kIXSheetStyleAutomatic = @"automatic";
IX_STATIC_CONST_STRING kIXSheetStyleBlackTranslucent = @"black.translucent";
IX_STATIC_CONST_STRING kIXSheetStyleBlackOpaque = @"black.opaque";

// Attribute Value Defaults
IX_STATIC_CONST_STRING kIXDefaultCancelButtonTitle = @"Cancel";
IX_STATIC_CONST_STRING kIXDefaultSheetTitle = nil;
IX_STATIC_CONST_STRING kIXDefaultDestructiveButtonTitle = nil;
IX_STATIC_CONST_ARRAY kIXDefaultOtherButtonTitles = nil;

// Returns

// Events
IX_STATIC_CONST_STRING kIXCancelPressed = @"cancelled";
IX_STATIC_CONST_STRING kIXButtonPressedFormat = @"%@";

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

@end

@implementation IXActionSheet

-(void)buildView
{
    
}

-(void)applySettings

{
    [super applySettings];
    
    [self setActionSheetStyle:UIActionSheetStyleAutomatic];
    
    NSString* style = [[self propertyContainer] getStringPropertyValue:kIXSheetStyle defaultValue:nil];
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
    
    [self setSheetTitle:[[self propertyContainer] getStringPropertyValue:kIXSheetTitle defaultValue:kIXDefaultSheetTitle]];
    [self setCancelButtonTitle:[[self propertyContainer] getStringPropertyValue:kIXSheetButtonTitleCancel defaultValue:kIXDefaultCancelButtonTitle]];
    [self setDestructiveButtonTitle:[[self propertyContainer] getStringPropertyValue:kIXSheetButtonTitleDestructive defaultValue:kIXDefaultDestructiveButtonTitle]];
    [self setOtherTitles:[[self propertyContainer] getCommaSeperatedArrayListValue:kIXSheetButtonTitleOthers defaultValue:kIXDefaultOtherButtonTitles]];
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
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
        
        for( NSString* otherTitle in [self otherTitles] )
        {
            [actionSheet addButtonWithTitle:otherTitle];
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
        NSString* eventName = [NSString stringWithFormat:kIXButtonPressedFormat,buttonTitle];
        [[self actionContainer] executeActionsForEventNamed:eventName];
    }
}

@end