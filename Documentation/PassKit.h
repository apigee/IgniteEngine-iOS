//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** Interact with Passbook Passes directly without calling out to Safari.
*/

@implementation PassKit

/*  -----------------------------  */
//  [Documentation]

/** This control has the following attributes:

    @param pass.location http:// or /path/to/pass.passkit  <br>    *(string)*
 
*/

-(void)attributes
{
    // Documentation: Config
}

/** Events
 
 PassKit has the following events:
 
 @param pass.creation.success Fires when the pass is displayed successfully
 @param pass.creation.failed Fires when an error occurs when displaying the pass
 
*/

-(void)events
{
    // Documentation: Events
}

/** Functions
 
 @param pass.controller.present Present PassKit view controller
 
 <pre class="brush: js; toolbar: false;">
    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "passkitTest",
        "function_name": "pass.controller.present"
      }
    }
 </pre>

 
 @param pass.controller.dismiss Dismiss PassKit view controller
 
 <pre class="brush: js; toolbar: false;">
     {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "passkitTest",
        "function_name": "pass.controller.dismiss"
      }
    }
 </pre>

 */

-(void)functions
{
    // Documentation: Functions
}

/***************************************************************/
/***************************************************************/

/** Read-Only Attributes
 
 @param passkit.available	 *(bool)*   |   Is Does this device support PassKit?
 @param passkit.containsPass *(bool)*   |   Does the file you’ve pointed to actually contain a PassKit pass?
 @param pass.error *(string)*   |   Whoopsie.
 
*/

-(void)returns
{
    // Documentation: Read-only Attributes
}

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
