//
//  IXPicker.m
//  Ignite Engine
//
//  Created by Jeremy on 4/2/15.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXPicker.h"
#import "IXPropertyContainer.h"

#import "ActionSheetPicker.h"
#import "IXAppManager.h"

// Attributes
IX_STATIC_CONST_STRING kIXPickerType = @"type";
IX_STATIC_CONST_STRING kIXPickerTitle = @"title";

// Attribute Accepted Values
IX_STATIC_CONST_STRING kIXPickerDate = @"date";
IX_STATIC_CONST_STRING kIXPickerTime = @"time";
IX_STATIC_CONST_STRING kIXPickerTimeInterval = @"interval";
IX_STATIC_CONST_STRING kIXPickerDateAndTime = @"dateAndTime";
IX_STATIC_CONST_STRING kIXPickerCountdown = @"countdown";
IX_STATIC_CONST_STRING kIXPickerString = @"string";
IX_STATIC_CONST_STRING kIXPickerStringValues = @"stringValues";

// Returns
IX_STATIC_CONST_STRING kIXSelectedValue = @"selectedValue";
IX_STATIC_CONST_STRING kIXSelectedIndex = @"selectedIndex";

// Functions
IX_STATIC_CONST_STRING kIXPresentPicker = @"present";
IX_STATIC_CONST_STRING kIXDismissPicker = @"dismiss";

// Events
IX_STATIC_CONST_STRING kIXCancelPressed = @"cancelled";
IX_STATIC_CONST_STRING kIXDonePressed = @"done";

@interface IXPicker ()

@property (nonatomic,strong) NSString* selectedItemValue;
@property (nonatomic,strong) NSString* selectedItemIndex;
@property(nonatomic) UIDatePickerMode datePickerMode;
@property(nonatomic) NSDateFormatter * dateFormatter;

@end



@implementation IXPicker : IXBaseControl

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return [self.contentView sizeThatFits:size];
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
   
}

-(void)buildView
{
    [super buildView];
}

-(void)applySettings
{
    [super applySettings];
    
    NSString* type = [[self propertyContainer] getStringPropertyValue:kIXPickerType defaultValue:@"date"];
    
    // Type: Date, Time, Date and Time, Countdown
    if( [type isEqualToString:kIXPickerDate] || [type isEqualToString:kIXPickerTime] || [type isEqualToString:kIXPickerDateAndTime] || [type isEqualToString:kIXPickerCountdown]) {
        
        ActionDateCancelBlock cancelDate = ^(ActionSheetDatePicker *picker) {
            [[self actionContainer] executeActionsForEventNamed:kIXCancelPressed];
            IX_LOG_VERBOSE(@"Picker cancelled.");
        };
        
        ActionDateDoneBlock doneDate = ^(ActionSheetDatePicker *picker, id selectedDate, id origin) {

            _dateFormatter = [[NSDateFormatter alloc] init];
            
            if( [type isEqualToString:kIXPickerDate] ) {
                _dateFormatter.dateFormat = @"yyyy-MM-dd";
                _selectedItemValue = [_dateFormatter stringFromDate:selectedDate];
            }
            else if( [type isEqualToString:kIXPickerTime] ) {
                _dateFormatter.dateFormat = @"HH:mm";
                _selectedItemValue = [_dateFormatter stringFromDate:selectedDate];
            }
            else if( [type isEqualToString:kIXPickerDateAndTime] ) {
                _dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
                _selectedItemValue = [_dateFormatter stringFromDate:selectedDate];
            }
            else if( [type isEqualToString:kIXPickerCountdown] ) {
                
                _selectedItemValue = [NSString stringWithFormat:@"%@", selectedDate];
            }
            
            _selectedItemIndex = nil;
            
            [[self actionContainer] executeActionsForEventNamed:kIXDonePressed];
            
            IX_LOG_VERBOSE(@"Picked: selectedDate = %@", selectedDate);
            
        };
        
        if( [type isEqualToString:kIXPickerDate] ) {
            _datePickerMode = UIDatePickerModeDate;
        }
        else if( [type isEqualToString:kIXPickerTime] ) {
            _datePickerMode = UIDatePickerModeTime;
        }
        else if( [type isEqualToString:kIXPickerDateAndTime] ) {
            _datePickerMode = UIDatePickerModeDateAndTime;
        }
        else if( [type isEqualToString:kIXPickerCountdown] ) {
            _datePickerMode = UIDatePickerModeCountDownTimer;
        }
        
        _datePicker = [[ActionSheetDatePicker alloc]
                       initWithTitle:@"title"
                       datePickerMode: _datePickerMode
                       selectedDate:[NSDate date]
                       doneBlock:doneDate
                       cancelBlock:cancelDate
                       origin:self.contentView];
        _datePicker.minuteInterval = [[self propertyContainer] getIntPropertyValue:kIXPickerTimeInterval defaultValue:5];
        _datePicker.title = [[self propertyContainer] getStringPropertyValue:kIXPickerTitle defaultValue:@""];

        
    } else if( [type isEqualToString:kIXPickerString] )
    // Type: String
    {
        
        /////////////////
        // String Picker
        ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
            [[self actionContainer] executeActionsForEventNamed:kIXCancelPressed];
            IX_LOG_VERBOSE(@"Picker cancelled.");
        };
        
        ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            
            _selectedItemIndex = [NSString stringWithFormat:@"%ld", (long)selectedIndex];
            _selectedItemValue = selectedValue;
            IX_LOG_VERBOSE(@"Picked: selectedValue = %@ // selectedIndex = %ld", selectedValue, selectedIndex);
            [[self actionContainer] executeActionsForEventNamed:kIXDonePressed];
            
        };
        
        
        // kIXPickerStringValues
        
        //NSArray *array = @[@"Red", @"Green", @"Blue", @"Orange"];
        NSArray *array = [[self propertyContainer] getCommaSeperatedArrayListValue:kIXPickerStringValues defaultValue:nil];
        
        _stringPicker = [[ActionSheetStringPicker alloc]
                         initWithTitle:@"test"
                         rows:array
                         initialSelection:0
                         doneBlock:done
                         cancelBlock:cancel
                         origin:self.contentView
                         ];
        _stringPicker.title = [[self propertyContainer] getStringPropertyValue:kIXPickerTitle defaultValue:@""];
        
    }


}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    
    if( [functionName isEqualToString:kIXPresentPicker] )
    {
        NSString* type = [[self propertyContainer] getStringPropertyValue:kIXPickerType defaultValue:@"date"];

        if( [type isEqualToString:kIXPickerDate] || [type isEqualToString:kIXPickerTime] || [type isEqualToString:kIXPickerDateAndTime] || [type isEqualToString:kIXPickerCountdown]) {
            [_datePicker showActionSheetPicker];
        }
        else if( [type isEqualToString:kIXPickerString] ) {
            [_stringPicker showActionSheetPicker];
        }
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

-(NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = nil;
    if( [propertyName isEqualToString:kIXSelectedIndex] )
    {
        returnValue = _selectedItemIndex;
        IX_LOG_VERBOSE(@"Returned read-only value selectedIndex: %@", _selectedItemIndex);
    }
    else if( [propertyName isEqualToString:kIXSelectedValue] )
    {
        returnValue = _selectedItemValue;
        IX_LOG_VERBOSE(@"Returned read-only value: %@", _selectedItemValue);
        
    }
    else
    {
        returnValue = [super getReadOnlyPropertyValue:propertyName];
    }
    return returnValue;
}

@end
