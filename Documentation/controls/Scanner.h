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

/** IXScanner has the following attributes:
 
 @param autoClose.enabled Automatically close the scanner view controller<br><code>bool</code> *TRUE*
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** IXScanner has the following events:
 
 @param success Fires on success
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** IXSlider has the following functions:
 
 @param dismiss Dismisses the reader
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 @param present Presents scanner view controller
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** IXScanner returns the following values:
 
 @param data Returns data contained in code scanned<br><code>string</code>
 
 */

-(void)Returns
{
}
/***************************************************************/
/***************************************************************/

/** Go on, try it out!

<pre class="brush: js; toolbar: false;">
{
    "_id": "scannerTest",
    "_type": "Scanner",
    "actions": [
        {
            "_type": "Alert",
            "attributes": {
                "message": "[[$self.data]]",
                "title": "Scanned."
            },
            "on": "scanned"
        }
    ],
    "attributes": {
        "autoClose.enabled": true
    }
} 
</pre>

*/

-(void)Example
{
}

/***************************************************************/

@end
