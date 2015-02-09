//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** The jack of all trades. Use me everywhere.
*/

@implementation Layout

/***************************************************************/

/** Layout has the following attributes:
 
 @param bg.blur.alpha Background blur alpha<br><code>float</code>
 @param bg.blur.tint Background blur color<br><code>color</code>
 @param bg.blur Background blur type<ul><li>xlight</li><li>light</li><li>dark</il></ul>
 @param scrollBars.h.enabled Display horizontal scrollbars<br><code>bool</code>
 @param scrollBars.enabled Display scrollbars<br><code>bool</code>
 @param scrollBars.v.enabled Display vertical scrollbars<br><code>bool</code>
 @param scrolling.h.enabled Horizontal scrolling enabled<br><code>bool</code>
 @param layoutFlow Layout flow<ul><li>*vertical*</li><li>horizontal</li></ul>
 @param scrollTop.enabled Scroll to top when status bar touched<br><code>bool</code>
 @param scrollBars.style Scrollbar style<ul><li>*default*</li><li>black</li><li>white</li></ul>
 @param scrolling.v.enabled Vertical scrolling enabled<br><code>bool</code>
 @param zoom.enabled Zoom enabled<br><code>bool</code>
 @param zoomScale.max Zoom scale minimum<br><code>float</code>
 @param zoomScale.min Zoom scale minimum<br><code>float</code>
 @param gradient.top <br><code>color</code>
 @param gradient.bottom <br><code>color</code>
 @param zoomScale <br><code>float</code>
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** Layout fires no events.
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** Layout has no functions.
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** Layout returns no values.
 
 */

-(void)Returns
{
}
/***************************************************************/
/***************************************************************/

/** Go on, try it out!


<pre class="brush: js; toolbar: false;">
{
    "_id": "layoutTest",
    "_type": "Layout",
    "attributes": {
        "align.h": "center",
        "align.v": "middle",
        "layoutType": "absolute",
        "padding": 75,
        "padding.left": 60,
        "padding.right": 60,
        "padding.top": 145,
        "size.h": "100%",
        "size.w": "100%"
    },
    "controls": [
        {
            "_id": "layoutTest",
            "_type": "Layout",
            "attributes": {
                "bg.color": "#cdcdcd",
                "layoutFlow": "horizontal",
                "size.h": "100%",
                "size.w": "100%"
            },
            "controls": [
                {
                    "_id": "layoutTest",
                    "_type": "Layout",
                    "attributes": {
                        "bg.color": "#696969",
                        "size.h": "100%",
                        "size.w": 50
                    }
                },
                {
                    "_id": "layoutTest",
                    "_type": "Layout",
                    "attributes": {
                        "bg.color": "#69696950",
                        "size.h": "100%",
                        "size.w": 50
                    }
                },
                {
                    "_id": "layoutTest",
                    "_type": "Layout",
                    "attributes": {
                        "bg.color": "#69696925",
                        "size.h": "100%",
                        "size.w": 50
                    }
                },
                {
                    "_id": "layoutTest",
                    "_type": "Layout",
                    "attributes": {
                        "bg.color": "#69696900",
                        "size.h": "100%",
                        "size.w": 50
                    }
                }
            ]
        }
    ]
}
</pre>

*/

-(void)Example
{
}

/***************************************************************/

@end
