//
//  IXCalendar.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 7/18/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
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
 
 Create calendar items and add them to the device calendar.
 

 <div id="container">
 <ul>
 <li><a href="../images/IXCalendar_0.png" data-imagelightbox="c"><img src="../images/IXCalendar_0.png"></a></li>
 <li><a href="../images/IXCalendar_1.png" data-imagelightbox="c"><img src="../images/IXCalendar_1.png"></a></li>
 </ul>
</div>
 
*/

/*
 *      /Docs
 *
*/

#import "IXCalendar.h"

#import "NSString+IXAdditions.h"

@import EventKit;

// IXCalendar Attributes
IX_STATIC_CONST_STRING kIXEventAllDay = @"event.allDay";
IX_STATIC_CONST_STRING kIXEventTitle = @"event.title";
IX_STATIC_CONST_STRING kIXEventLocation = @"event.location";
IX_STATIC_CONST_STRING kIXEventURL = @"event.url";
IX_STATIC_CONST_STRING kIXEventNotes = @"event.notes";
IX_STATIC_CONST_STRING kIXEventDateFormat = @"event.date.format";
IX_STATIC_CONST_STRING kIXEventDateStart = @"event.date.start";
IX_STATIC_CONST_STRING kIXEventDateEnd = @"event.date.end";
IX_STATIC_CONST_STRING kIXEventAlarmOffset = @"event.alarm.offset";
IX_STATIC_CONST_STRING kIXEventRecurrenceFrequency = @"event.recurrence.frequency";

// kIXEventRecurrenceFrequency Accepted Values
IX_STATIC_CONST_STRING kIXEventRecurrenceFrequencyNone = @"none";
IX_STATIC_CONST_STRING kIXEventRecurrenceFrequencyDaily = @"daily";
IX_STATIC_CONST_STRING kIXEventRecurrenceFrequencyWeekly = @"weekly";
IX_STATIC_CONST_STRING kIXEventRecurrenceFrequencyMonthly = @"monthly";
IX_STATIC_CONST_STRING kIXEventRecurrenceFrequencyYearly = @"yearly";

// IXCalendar ReadOnly Attributes
IX_STATIC_CONST_STRING kIXAccessGranted = @"access_granted";

// IXCalendar Functions
IX_STATIC_CONST_STRING kIXAddEvent = @"add_event";

// IXCalendar Events
IX_STATIC_CONST_STRING kIXAddEventSuccess = @"add_event_success";
IX_STATIC_CONST_STRING kIXAddEventFailed = @"add_event_failed";

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


    @param event.allDay All day event? *(default: FALSE)*<br>*(bool)*
    @param event.title Event Title<br>*(string)*
    @param event.location Location<br>*(string)*
    @param event.url URL<br>*(string)*
    @param event.notes Notes<br>*(string)*
    @param event.date.format Date Format<br>*(string)*
    @param event.date.start Date Start<br>*(date)*
    @param event.date.end Date End<br>*(date)*
    @param event.alarm.offset Alarm Offset<br>*(float)*
"    @param event.recurrence.frequency Recurrance Frequency<br>*none
daily
weekly
monthly
yearly*"
    @param access_granted Permission status (Read-only)<br>*(bool)*

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


    @param add_event_success The event was added successfully
    @param add_event_failed Event failed to add to calendar.

 */

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


    @param add_event Adds an event to the device calendar

 <pre class="brush: js; toolbar: false;">
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "calendarTest",
    "function_name": "add_event"
  }
} 
 </pre>

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
{
  "_type": "Calendar",
  "_id": "calendarTest",
  "actions": [
    {
      "_type": "Alert",
      "attributes": {
        "title": "add_event_success"
      },
      "on": "add_event_success"
    },
    {
      "_type": "Alert",
      "attributes": {
        "title": "add_event_failed"
      },
      "on": "add_event_failed"
    }
  ],
  "attributes": {
    "event.title": "Event Title",
    "event.allDay": false,
    "event.location": "1234 Some Street, City, State Zip",
    "event.notes": "Event Notes",
    "event.url": "http://meetings-are-fun.com",
    "event.date.format": "yyyy-MM-dd HH:mm:ss",
    "event.date.start": "2015-12-31 23:00:00",
    "event.date.end": "2016-01-01 00:00:00",
    "event.alarm.offset": -1800,
    "event.recurrence.frequency": "none"
  }
}
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

    [self setAllDayEvent:[[self propertyContainer] getBoolPropertyValue:kIXEventAllDay defaultValue:NO]];
    [self setEventTitle:[[self propertyContainer] getStringPropertyValue:kIXEventTitle defaultValue:nil]];
    [self setEventLocation:[[self propertyContainer] getStringPropertyValue:kIXEventLocation defaultValue:nil]];
    [self setEventURL:[[self propertyContainer] getURLPathPropertyValue:kIXEventURL basePath:nil defaultValue:nil]];
    [self setEventNotes:[[self propertyContainer] getStringPropertyValue:kIXEventNotes defaultValue:nil]];

    NSString* eventDateFormat = [[self propertyContainer] getStringPropertyValue:kIXEventDateFormat defaultValue:nil];
    [[self dateFormatter] setDateFormat:eventDateFormat];

    NSString* eventStartDate = [[self propertyContainer] getStringPropertyValue:kIXEventDateStart defaultValue:nil];
    NSString* eventEndDate = [[self propertyContainer] getStringPropertyValue:kIXEventDateEnd defaultValue:nil];

    [self setEventStartDate:[[self dateFormatter] dateFromString:eventStartDate]];
    [self setEventEndDate:[[self dateFormatter] dateFromString:eventEndDate]];

    [self setEventAlarmOffset:[[self propertyContainer] getFloatPropertyValue:kIXEventAlarmOffset defaultValue:CGFLOAT_MAX]];
    [self setEventRecurrenceFrequency:[[self propertyContainer] getStringPropertyValue:kIXEventRecurrenceFrequency defaultValue:kIXEventRecurrenceFrequencyNone]];
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

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
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
