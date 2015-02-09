//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** Calls upon the device camera to capture an image.
*/

@implementation CellBasedControl

/***************************************************************/

/** IXCellBasedControl has the following attributes:
 
 @param reloadAnimation.enabled Animate reloading cells<br><code>bool</code>
 @param sectionHeader.controls Array of background controls<br><code>array</code>
 @param swipe.controls Array of controls accessed when swiping cell to the side<br><code>array</code>
 @param bg.blur.alpha Background blur alpha<br><code>float</code>
 @param bg.blur.tint Background blur color<br><code>color</code>
 @param bg.blur Background blur type<ul><li>extra_light</li><li>light</li><li>dark</il></ul>
 @param bg.color Background color<br><code>color</code>
 @param swipe.alpha.enabled Background controls fade in from alpha 0<br><code>bool</code>
 @param swipe.slideIn.enabled Background controls slide in from side<br><code>bool</code>
 @param cell.size.h Cell height<br><code>float</code>
 @param cell.size.w Cell width<br><code>float</code>
 @param datasource.id Datasource ID<br><code>string</code>
 @param scrollBars.h.enabled Warning: Not implemented. Display horizontal scrollbars<br><code>bool</code>
 @param scrollBars.enabled Display scrollbars<br><code>bool</code>
 @param scrollBars.v.enabled Warning: Not implemented. Display vertical scrollbars<br><code>bool</code>
 @param reloadAnimation.duration Duration of reload animation<br><code>float</code>
 @param scrolling.h.enabled Horizontal scrolling enabled<br><code>bool</code>
 @param layoutFlow Layout flow<ul><li>*vertical*</li><li>horizontal</li></ul>
 @param paging.enabled Paging enabled<br><code>bool</code>
 @param data.basepath Path to data object<br><code>string</code>
 @param pullToRefresh.color Pull to refresh color<br><code>color</code>
 @param pullToRefresh.enabled Pull to refresh enabled<br><code>bool</code>
 @param pullToRefresh.font Pull to refresh font<br><code>font</code>
 @param pullToRefresh.text Pull to refresh text<br><code>string</code>
 @param pullToRefresh.tint Pull to refresh tint <br><code>color</code>
 @param scrollTop.enabled Scroll to top when status bar touched<br><code>bool</code>
 @param scrollBars.style Scrollbar style<ul><li>*default*</li><li>black</li><li>white</li></ul>
 @param scrolling.enabled Scrolling enabled<br><code>bool</code>
 @param sectionHeader.size.h Section header height<br><code>float</code>
 @param sectionHeader.size.w Section header width<br><code>float</code>
 @param sectionHeader.xpath Section header xpath<br><code>string</code>
 @param scrolling.v.enabled Vertical scrolling enabled<br><code>bool</code>
 @param swipe.w Width cell will slide to reval background controls<br><code>float</code>
 @param zoom.enabled Zoom enabled<br><code>bool</code>
 @param zoomScale.max Zoom scale maximum<br><code>float</code>
 @param zoomScale Zoom scale minimum<br><code>float</code>
 @param zoomScale.min Zoom scale minimum<br><code>float</code>
 @param gradient <br><code>color</code>
 @param gradient <br><code>color</code>
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** CellBasedControl has the following events:
 
 @param pullToRefresh.tint Pull to refresh tint <br><code>color</code>
 @param scrollTop.enabled Scroll to top when status bar touched<br><code>bool</code>
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** CellBasedControl has no functions.
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** CellBasedControl returns no values.
 
 */

-(void)Returns
{
}
/***************************************************************/
/***************************************************************/

/** Go on, try it out!


 <pre class="brush: js; toolbar: false;">
 
{
  "_id": "cameraTest",
  "_type": "Camera",
  "actions": [
    {
      "on": "did_capture_image",
      "_type": "Alert",
      "attributes": {
        "title": "did_capture_image"
      }
    },
    {
      "on": "did_finish_saving_capture",
      "_type": "Alert",
      "attributes": {
        "title": "did_finish_saving_capture"
      }
    }
  ],
  "attributes": {
    "camera": "rear",
    "height": "100%",
    "width": "100%"
  }
}
 
 </pre>
 

*/

-(void)Example
{
}

/***************************************************************/

@end
