//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** Renders an image. Supports nifty blurs, real-time color overlay and even animated GIFs.
*/

@implementation Image

/***************************************************************/

/** Image has the following attributes:
 
 @param binaryString Binary representation of image data<br><code>string</code>
 @param blur.radius Blur radius<br><code>float</code>
 @param blur.saturation Blur saturation<br><code>float</code>
 @param blur.tint Blur tint<br><code>color</code>
 @param tint Color tint image<br><code>color</code>
 @param animatedGif.duration Duration of animated GIF<br><code>float</code>
 @param transform.flip.h Flip image horizontally<br><code>bool</code>
 @param transform.flip.v Flip image vertically<br><code>bool</code>
 @param forceRedraw.enabled Force reload resource<br><code>bool</code> *FALSE*
 @param image Image<br><code>string</code>
 @param max.h Maximum height<br><code>float</code>
 @param max.w Maximum width<br><code>float</code>
 @param resizeMask Resize image mask<br><code>string</code>
 @param transform.rotate Rotate image in degrees<br><code>float</code>
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** Image has the following events:
 
 @param error Error loading image
 @param success Fires on success
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** Image has the following functions:
 
 @param loadLatestPhoto Loads latest photo
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 @param restartAnimation Restart animation
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 @param start Start GIF animation
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 @param stop Stop GIF animation
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** Image returns the following values:
 
 @param isAnimating Is animating<br><code>bool</code>
 @param source.size.h Source height<br><code>float</code>
 @param source.size.w Source width<br><code>float</code>
 
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
      "on": "touch_up",
      "attributes": {
        "title": "touch_up",
        "message": "Sized to [[$self.actual.width]]pt x [[$self.actual.height]]pt."
      }
    }
  ],
  "attributes": {
    "images.width.max": "100%",
    "images.default": "/images/bgs/storage_wars.jpg",
    "text.color": "6c6c6c",
    "images.default.blur.radius": 0,
    "layout_type": "absolute",
    "vertical_alignment": "middle",
    "horizontal_alignment": "center"
  }
}
 
 </pre>


*/

-(void)Example
{
}

/***************************************************************/

@end
