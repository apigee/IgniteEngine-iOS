//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** A menu that is presented from the bottom of the screen and gives the user the ability to select from several buttons.
*/

@implementation Scanner

/***************************************************************/

/** This control has the following attributes:
 
 @param auto_close Automatically close the Scanner view controller upon scan? *(default: TRUE)*<br>*(bool)*
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** This control has the following attributes:
 
 @param data Data contained in the scanned code<br>*(string)*
 
 */

-(void)Returns
{
}

/***************************************************************/
/***************************************************************/

/** This control fires the following events:

 
 @param scanned Fires when a code is scanned successfully
 
*/

-(void)Events
{
}

/***************************************************************/
/***************************************************************/

/** This control supports the following functions:

 
 @param present_reader Present Scanner view controller
 
<pre class="brush: js; toolbar: false;">

{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "scannerTest",
    "function_name": "present_reader"
  }
}

</pre>
 
 @param dismiss_reader Dismiss Scanner view controller
 
  <pre class="brush: js; toolbar: false;">
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "scannerTest",
    "function_name": "dismiss_reader"
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
 
 </pre>

*/

-(void)Example
{
}

/***************************************************************/

@end
