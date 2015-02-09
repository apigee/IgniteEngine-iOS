//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

#warning We should drop View from this control's name

/** Old-school UITableView.
*/

@implementation TableView

/***************************************************************/

/** IXTableView has the following attributes:
 
 @param parallaxImage.h Height of parallax image<br><code>float</code>
 @param parallaxImage Image displayed in background using parallax<br><code>string</code>
 @param layoutFlow Layout flow<ul><li>*vertical*</li><li>horizontal</li></ul>
 @param separator.style none<ul><li>*default*</li><li>none</li></ul>
 @param rowSelect.enabled Row select enabled<br><code>bool</code>
 @param rowStaysHighlighted.enabled Row stays highlighted<br><code>bool</code>
 @param separator.color Separator color<br><code>color</code>
 @param swipe.w Width cell will slide to reval background controls<br><code>float</code>
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** IXTableView has the following events:
 
 @param didSelectCell Fires on did select cell
 @param didHideCell Fires when did hide cell
 @param didBeginScrolling Fires when scrolling begins
 @param didEndScrolling Fires when scrolling ends
 @param willDisplayCell Fires when will display cell
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** IXTableView has the following functions:
 
 @param resetBgControls Resets background cell controls
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 @param setSwipeSize Sets background swipe width
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** IXTableView returns no values.
 
 */

-(void)Returns
{
}
/***************************************************************/
/***************************************************************/

/** Go on, try it out!


<pre class="brush: js; toolbar: false;">
{
    "_id": "tableSettings",
    "_type": "TableView",
    "attributes": {
        "autofill.w": true,
        "bg.color": "[[app.color]]",
        "cell.size.h": 50,
        "cell.size.w": "100%",
        "datasourceid": "test_data",
        "enabled": true,
        "fill_remaining_size.h": true,
        "margin.top": 70,
        "separator.style": "none"
    },
    "controls": [
        {
            "_type": "Layout",
            "actions": [
                {
                    "_type": "Alert",
                    "attributes": {
                        "title": "You touched: [[dataRow.name]] ([[dataRow.abbreviation]])"
                    },
                    "enabled": false,
                    "on": "touchUp"
                },
                {
                    "_type": "Navigate",
                    "attributes": {
                        "nav_animation_duration": 0,
                        "nav_animation_type": "cross_dissolve",
                        "nav_stack_type": "push",
                        "to": "Social.json"
                    },
                    "enabled": true,
                    "on": "touchUp"
                }
            ],
            "attributes": {
                "align.v": "middle",
                "layoutFlow": "horizontal",
                "layoutType": "absolute"
            },
            "controls": [
                {
                    "_type": "Text",
                    "attributes": {
                        "color": "#6c6c6c",
                        "font": "HelveticaNeue-Light:22",
                        "margin.left": 20,
                        "text": "[[dataRow.name]]"
                    }
                },
                {
                    "_type": "Text",
                    "attributes": {
                        "color": "#6c6c6c",
                        "font": "HelveticaNeue-Light:22",
                        "margin.left": 5,
                        "text": "([[dataRow.abbreviation]])"
                    }
                }
            ]
        },
        {
            "_type": "Image",
            "attributes": {
                "align.h": "right",
                "image": "../images/btn_chevron_50x50.png",
                "layoutType": "absolute",
                "size.h": 50,
                "size.w": 50
            }
        },
        {
            "_type": "Layout",
            "attributes": {
                "align.v": "bottom",
                "bg.color": "#cdcdcd",
                "layoutType": "float",
                "size.h": 1,
                "size.w": "100%"
            }
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
