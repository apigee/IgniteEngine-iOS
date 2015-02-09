//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** Allows the user to add a contact to their device Address Book.
*/

@implementation AddressBook

/***************************************************************/

/** AddressBook has the following attributes:
 
 @param company.name Company Name<br><code>string</code>
 @param company.title Company Title<br><code>string</code>
 @param email.home Email: Home<br><code>string</code>
 @param email.work Email: Work<br><code>string</code>
 @param name.first First Name<br><code>string</code>
 @param name.last Last Name<br><code>string</code>
 @param phone.main Phone: Main<br><code>string</code>
 @param phone.mobile Phone: Mobile<br><code>string</code>
 @param url.facebook URL: Facebook<br><code>string</code>
 @param url.home URL: Home<br><code>string</code>
 @param url.homePage URL: Homepage<br><code>string</code>
 @param url.work URL: Work<br><code>string</code>
 @param url.linkedIn URL:LinkedIn<br><code>string</code>
 @param username.facebook Username: Facebook<br><code>string</code>
 @param username.linkedin Username: LinkedIn<br><code>string</code>
 @param username.twitter Username: Twitter<br><code>string</code>
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** AddressBook has the following events:
 
 @param success Fires on success
 @param error Fires when adding contact failed
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** AddressBook has the following functions:
 
 @param addContact Adds contact
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** AddressBook returns the following values:
 
 @param isAllowed Access to the device granted<br><code>bool</code>
 
 */

-(void)Returns
{
}
/***************************************************************/
/***************************************************************/

/** Go on, try it out!
 
<pre class="brush: js; toolbar: false;">
{
  "_type": "AddressBook",
  "_id": "addressBookTest",
  "actions": [
    {
      "_type": "Alert",
      "attributes": {
        "title": "add_contact_success"
      },
      "on": "add_contact_success"
    },
    {
      "_type": "Alert",
      "attributes": {
        "title": "add_contact_failed"
      },
      "on": "add_contact_failed"
    }
  ],
  "attributes": {
    "name.first": "Johnny",
    "name.last": "Appleseed",
    "company.name": "Farmers, Inc.",
    "company.title": "CEO",
    "phone.mobile": "+15551212",
    "phone.main": "+15551313",
    "email.home": "johnnyappleseed@gmail.com",
    "email.work": "johnny@appleseed.com",
    "username.twitter": "johnnyappleseed",
    "username.linkedIn": "johnnyappleseed",
    "username.facebook": "johnnyappleseed",
    "url.home": "http://johnnyappleseed.com",
    "url.homePage": "http://johnnyappleseed.com",
    "url.work": "http://farmersinc.com",
    "url.linkedIn": "",
    "url.facebook": ""
  }
}
</pre>





*/

-(void)Example
{
}

/***************************************************************/

@end
