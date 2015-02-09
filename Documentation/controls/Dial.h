//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** A Dial that allows the user to turn things up or down.
*/

@implementation Dial

/***************************************************************/

/** Dial has the following attributes:
 
 @param animation.duration Animation duration<br><code>float</code>
 @param bg.image Background image<br><code>string</code>
 @param value.default Default value<br><code>float</code>
 @param fg.image Foreground image<br><code>string</code>
 @param maxAngle Maximum angle<br><code>float</code>
 @param value.max Maximum value<br><code>float</code>
 @param pointer.image Pointer image<br><code>string</code>
 @param value.min Value minimum<br><code>float</code>
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** Dial has the following events:
 
 @param touch Fires on touch
 @param touchUp Fires on touch up inside
 @param valueChanged Fires when value changes
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** Dial has the following functions:
 
 @param setValue Set value
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** Dial returns the following values:
 
 @param value Value<br><code>float</code>
 
 */

-(void)Returns
{
}
/***************************************************************/
/***************************************************************/

/** Go on, try it out!


<pre class="brush: js; toolbar: false;">
{
    "_id": "imageTest",
    "_type": "Image",
    "actions": [
        {
            "_type": "Alert",
            "attributes": {
                "message": "Sized to [[$self.size.w.computed]]pt x [[$self.size.h.computed]]pt.",
                "title": "touchUp"
            },
            "on": "touchUp"
        }
    ],
    "attributes": {
        "align.h": "center",
        "align.v": "middle",
        "color": "6c6c6c",
        "image": "/images/bgs/storage_wars.jpg",
        "image.blur.radius": 20,
        "layoutType": "absolute",
        "max.w": "100%"
    }
}
</pre>

*/

-(void)Example
{
}

/***************************************************************/

@end
