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

/** This control has the following attributes:

    @param message.type The type of message to create<br>*textemail*
    @param message.to Send message to? (Email/Phone/iMessage address)<br>*(string)*
    @param message.cc Send a copy to?<br>*(string)*
    @param message.bcc Blind copy to? (Email)<br>*(string)*
    @param message.subject Message subject (Email)<br>*(string)*
    @param message.body Message body (Email/Text)<br>*(string)*

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


    @param message_cancelled Fires when the file is inaccessible
    @param message_failed Fires when the message fails to send
    @param message_sent Fires on message send success
 
*/

-(void)Events
{
}

/***************************************************************/
/***************************************************************/

/** This control supports the following functions:


    @param present_text_message_controller 
 
 <pre class="brush: js; toolbar: false;">
 
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "messageTest",
    "function_name": "present_text_message_controller"
  }
}
 
 </pre>

    @param present_email_controller 
 
 <pre class="brush: js; toolbar: false;">

{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "messageTest",
    "function_name": "present_email_controller"
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
  "_id": "messageTest",
  "_type": "Message",
  "actions": [
    {
      "on": "message_sent",
      "_type": "Alert",
      "attributes": {
        "title": "Message sent!"
      }
    },
    {
      "on": "message_cancelled",
      "_type": "Alert",
      "attributes": {
        "title": "Message cancelled!"
      }
    }
  ],
  "attributes": {
    "message.type": "text",
    "message.to": "555-867-5309"
  }
}
 
 </pre>

*/

-(void)Example
{
}

/***************************************************************/

@end
