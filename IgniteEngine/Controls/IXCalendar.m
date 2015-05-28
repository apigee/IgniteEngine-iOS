//
//  IXCalendar.m
//  Ignite Engine
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

#import "IXCalendar.h"

#import "NSString+IXAdditions.h"

@import EventKit;

// IXCalendar Attributes
IX_STATIC_CONST_STRING kIXEventAllDay = @"allDay.enabled";
IX_STATIC_CONST_STRING kIXEventTitle = @"title";
IX_STATIC_CONST_STRING kIXEventLocation = @"location";
IX_STATIC_CONST_STRING kIXEventURL = @"url";
IX_STATIC_CONST_STRING kIXEventNotes = @"notes";
IX_STATIC_CONST_STRING kIXEventDateFormat = @"date.format";
IX_STATIC_CONST_STRING kIXEventDateStart = @"date.start";
IX_STATIC_CONST_STRING kIXEventDateEnd = @"date.end";
IX_STATIC_CONST_STRING kIXEventAlarmOffset = @"alarmOffset";
IX_STATIC_CONST_STRING kIXEventRecurrenceFrequency = @"repeatFrequency";

// kIXEventRecurrenceFrequency Accepted Values
IX_STATIC_CONST_STRING kIXEventRecurrenceFrequencyNone = @"none";
IX_STATIC_CONST_STRING kIXEventRecurrenceFrequencyDaily = @"daily";
IX_STATIC_CONST_STRING kIXEventRecurrenceFrequencyWeekly = @"weekly";
IX_STATIC_CONST_STRING kIXEventRecurrenceFrequencyMonthly = @"monthly";
IX_STATIC_CONST_STRING kIXEventRecurrenceFrequencyYearly = @"yearly";

// IXCalendar ReadOnly Attributes
IX_STATIC_CONST_STRING kIXAccessGranted = @"isAllowed";

// IXCalendar Functions
IX_STATIC_CONST_STRING kIXAddEvent = @"addEvent";

// IXCalendar Events
IX_STATIC_CONST_STRING kIXAddEventSuccess = @"success";
IX_STATIC_CONST_STRING kIXAddEventFailed = @"error";

@interface IXCalendar ()

@property (nonatomic,assign) BOOL accessWasGranted;
@property (nonatomic,strong) EKEventStore* eventStore;
@property (nonatomic,strong) NSDateFormatter* dateFormatter;

@property (nonatomic,assign) BOOL allDayEvent;
@property (nonatomic,strong) NSString* eventTitle;
@property (nonatomic,strong) NSString* eventLocation;
@property (nonatomic,strong) NSURL* eventURL;
@property (nonatomic,strong) NSString* eventNotes;

@property (nonatomic,strong) NSDate* eventStartDate;
@property (nonatomic,strong) NSDate* eventEndDate;

@property (nonatomic,assign) CGFloat eventAlarmOffset;
@property (nonatomic,strong) NSString* eventRecurrenceFrequency;

@end

@implementation IXCalendar

-(void)buildView
{
    _dateFormatter = [[NSDateFormatter alloc] init];

    _eventStore = [[EKEventStore alloc] init];
    [_eventStore requestAccessToEntityType:EKEntityTypeEvent
                                completion:^(BOOL granted, NSError *error) {
                                    [self setAccessWasGranted:granted];
                                }];
}

-(void)applySettings
{
    [super applySettings];

    [self setAllDayEvent:[[self attributeContainer] getBoolValueForAttribute:kIXEventAllDay defaultValue:NO]];
    [self setEventTitle:[[self attributeContainer] getStringValueForAttribute:kIXEventTitle defaultValue:nil]];
    [self setEventLocation:[[self attributeContainer] getStringValueForAttribute:kIXEventLocation defaultValue:nil]];
    [self setEventURL:[[self attributeContainer] getURLValueForAttribute:kIXEventURL basePath:nil defaultValue:nil]];
    [self setEventNotes:[[self attributeContainer] getStringValueForAttribute:kIXEventNotes defaultValue:nil]];

    NSString* eventDateFormat = [[self attributeContainer] getStringValueForAttribute:kIXEventDateFormat defaultValue:nil];
    [[self dateFormatter] setDateFormat:eventDateFormat];

    NSString* eventStartDate = [[self attributeContainer] getStringValueForAttribute:kIXEventDateStart defaultValue:nil];
    NSString* eventEndDate = [[self attributeContainer] getStringValueForAttribute:kIXEventDateEnd defaultValue:nil];

    [self setEventStartDate:[[self dateFormatter] dateFromString:eventStartDate]];
    [self setEventEndDate:[[self dateFormatter] dateFromString:eventEndDate]];

    [self setEventAlarmOffset:[[self attributeContainer] getFloatValueForAttribute:kIXEventAlarmOffset defaultValue:CGFLOAT_MAX]];
    [self setEventRecurrenceFrequency:[[self attributeContainer] getStringValueForAttribute:kIXEventRecurrenceFrequency defaultValue:kIXEventRecurrenceFrequencyNone]];
}

-(NSString *)getReadOnlyPropertyValue:(NSString *)propertyName
{
    if( [propertyName isEqualToString:kIXAccessGranted] )
    {
        return [NSString ix_stringFromBOOL:[self accessWasGranted]];
    }
    else
    {
        return [super getReadOnlyPropertyValue:propertyName];
    }
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXAttributeContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXAddEvent] )
    {
        EKEvent* event = [EKEvent eventWithEventStore:[self eventStore]];
        [event setCalendar:[[self eventStore] defaultCalendarForNewEvents]];
        [event setAllDay:[self allDayEvent]];
        [event setTitle:[self eventTitle]];
        [event setLocation:[self eventLocation]];
        [event setNotes:[self eventNotes]];
        [event setStartDate:[self eventStartDate]];
        [event setEndDate:[self eventEndDate]];
        [event setURL:[self eventURL]];

        if( [self eventAlarmOffset] != CGFLOAT_MAX )
        {
            [event addAlarm:[EKAlarm alarmWithRelativeOffset:[self eventAlarmOffset]]];
        }

        if( ![[self eventRecurrenceFrequency] isEqualToString:kIXEventRecurrenceFrequencyNone] )
        {
            if( [[self eventRecurrenceFrequency] isEqualToString:kIXEventRecurrenceFrequencyDaily] )
            {
                [event addRecurrenceRule:[[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyDaily interval:1 end:nil]];
            }
            else if( [[self eventRecurrenceFrequency] isEqualToString:kIXEventRecurrenceFrequencyWeekly] )
            {
                [event addRecurrenceRule:[[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly interval:1 end:nil]];
            }
            else if( [[self eventRecurrenceFrequency] isEqualToString:kIXEventRecurrenceFrequencyMonthly] )
            {
                [event addRecurrenceRule:[[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyMonthly interval:1 end:nil]];
            }
            else if( [[self eventRecurrenceFrequency] isEqualToString:kIXEventRecurrenceFrequencyYearly] )
            {
                [event addRecurrenceRule:[[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyYearly interval:1 end:nil]];
            }
        }

        NSError *error = nil;
        [[self eventStore] saveEvent:event
                                span:EKSpanThisEvent
                               error:&error];

        if( error == nil )
        {
            [[self actionContainer] executeActionsForEventNamed:kIXAddEventSuccess];
        }
        else
        {
            [[self actionContainer] executeActionsForEventNamed:kIXAddEventFailed];
        }
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}


@end
