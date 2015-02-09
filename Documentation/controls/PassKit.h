//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/***************************************************************/

/** PassKit has the following attributes:
 
 @param passUrl Pass URL<br><code>string</code>
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** PassKit has the following events:
 
 @param error Fires on error
 @param success Fires on success
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** PassKit has no functions.
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** PassKit returns the following values:
 
 @param error.message Returns error message<br><code>string</code>
 @param isAllowed Returns true if PassKit is available<br><code>bool</code>
 @param hasPass Returns true if passUrl contains a valid pass <br><code>bool</code>
 
 */

-(void)Returns
{
}
/***************************************************************/

/**
<pre class="brush: js; toolbar: false;">
 
{
  "_id": "passKitTest",
  "_type": "PassKit",
  "actions": [
    {
      "on": "pass.creation.success",
      "_type": "Alert",
      "attributes": {
        "title": "Pass created."
      }
    },
    {
      "on": "pass.creation.failed",
      "_type": "Alert",
      "attributes": {
        "title": "Pass failed."
      }
    }
  ],
  "attributes": {
    "pass.location": "/data/boardingpass.pkpass"
  }
}
 
</pre>
 
*/

-(void)example
{
    // Documentation: Sample Code
}

//  /[Documentation]
/*  -----------------------------  */

@end
