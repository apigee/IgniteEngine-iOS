//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** Create calendar items and add them to the device calendar.
*/

@implementation Calendar

/***************************************************************/

/** This control has the following attributes:


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

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** This control has the following attributes:
*/

-(void)Returns
{
}

/***************************************************************/
/***************************************************************/

/** This control fires the following events:


    @param add_event_success The event was added successfully
    @param add_event_failed Event failed to add to calendar.

 */

-(void)Events
{
}

/***************************************************************/
/***************************************************************/

/** This control supports the following functions:


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

-(void)Functions
{
}

/***************************************************************/
/***************************************************************/

/** Go on, try it out!


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

-(void)Example
{
}

/***************************************************************/

@end
