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

/** Calendar has the following attributes:
 
 @param isAllowed Access to the device granted<br><code>bool</code>
 @param alarmOffset Alarm offset<br><code>float</code>
 @param allDay.enabled All day event<br><code>bool</code> *FALSE*
 @param date.end Date end<br><code>date</code>
 @param date.format Date format<br><code>date</code>
 @param date.start Date start<br><code>date</code>
 @param location Location<br><code>string</code>
 @param notes Notes<br><code>string</code>
 @param repeatFrequency Repeat frequency<br><code>int</code>
 @param title Title<br><code>string</code>
 @param url URL<br><code>string</code>
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** Calendar has the following events:
 
 @param error Error occured when adding event
 @param success Fires on success
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** Calendar has the following functions:
 
 @param addEvent Add event
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** Calendar returns the following values:
 
 */

-(void)Returns
{
}
/***************************************************************/
/***************************************************************/

/** Go on, try it out!


 <pre class="brush: js; toolbar: false;">
{
    "_id": "calendarTest",
    "_type": "Calendar",
    "actions": [
        {
            "_type": "Alert",
            "attributes": {
                "title": "success"
            },
            "on": "success"
        },
        {
            "_type": "Alert",
            "attributes": {
                "title": "error"
            },
            "on": "error"
        }
    ],
    "attributes": {
        "alarm.offset": -1800,
        "allDay.enabled": false,
        "date.end": "2016-01-01 00:00:00",
        "date.format": "yyyy-MM-dd HH:mm:ss",
        "date.start": "2015-12-31 23:00:00",
        "location": "1234 Some Street, City, State Zip",
        "notes": "Event Notes",
        "repeatFrequency": "none",
        "title": "Event Title",
        "url": "http://meetings-are-fun.com"
    }
}
 </pre>

*/

-(void)Example
{
}

/***************************************************************/

@end
