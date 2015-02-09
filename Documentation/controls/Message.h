//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** Send an email or SMS/iMessage.
*/

@implementation Message

/***************************************************************/

/** Message has the following attributes:
 
 @param bcc bcc recipients<br><code>string</code>
 @param body Body of message<br><code>string</code>
 @param cc cc recipients<br><code>string</code>
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** Message has the following events:
 
 @param to Recipient<br><code>string</code>
 @param subject Subject of message<br><code>string</code>
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** Message has the following functions:
 
 @param hasPass Returns true if passUrl contains a valid pass <br><code>bool</code>
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 @param cancelled Fires on cancelled
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** Message returns no values.
 
 */

-(void)Returns
{
}
/***************************************************************/
/***************************************************************/

/** Go on, try it out!

<pre class="brush: js; toolbar: false;">
{
    "_id": "messageTest",
    "_type": "Message",
    "actions": [
        {
            "_type": "Alert",
            "attributes": {
                "title": "Message sent!"
            },
            "on": "success"
        },
        {
            "_type": "Alert",
            "attributes": {
                "title": "Message cancelled!"
            },
            "on": "cancelled"
        }
    ],
    "attributes": {
        "to": "info@apigee.com",
        "type": "text"
    }
}
</pre>

*/

-(void)Example
{
}

/***************************************************************/

@end
