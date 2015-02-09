//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** A slider that moves side-to-side.
*/

@implementation Slider
/***************************************************************/

/** IXSlider has the following attributes:
 
 @param capInsets.max Cap inset maximum image<br><code>string</code>
 @param capInsets.min Cap inset minimum image<br><code>string</code>
 @param value.default Default value<br><code>float</code>
 @param image.max Maximum track image<br><code>string</code>
 @param value.max Maximum value<br><code>float</code>
 @param image.min Minimum track image<br><code>string</code>
 @param thumbImage Thumb image<br><code>string</code>
 @param value.min Value minimum<br><code>float</code>
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** IXSlider has the following events:
 
 @param valueChanged Fires when the slider value changed
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** IXSlider has the following functions:
 
 @param setValue Sets the value of the slider
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** IXSlider returns the following values:
 
 @param value Returns the value of the slider<br><code>float</code>
 
 */

-(void)Returns
{
}
/***************************************************************/
/***************************************************************/

/** Go on, try it out!

 
<pre class="brush: js; toolbar: false;">
{
    "_id": "sliderTest",
    "_type": "Slider",
    "actions": [
        {
            "_type": "Refresh",
            "attributes": {
                "_target": "title"
            },
            "on": "valueChanged"
        }
    ],
    "attributes": {
        "align.h": "center",
        "align.v": "middle",
        "layoutType": "absolute",
        "size.w": 280
    }
}
</pre>

*/

-(void)Example
{
}

/***************************************************************/

@end
