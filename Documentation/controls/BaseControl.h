//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** Base control. Lots of things inherit attributes from this baby.
*/

@implementation BaseControl

/***************************************************************/

/** BaseControl has the following attributes:
 
 @param alpha Alpha<br><code>float</code>
 @param bg.color Background color<br><code>color</code>
 @param bg.image Background image<br><code>string</code>
 @param pan.enabled Border color<br><code>bool</code>
 @param border.color Border color<br><code>color</code>
 @param border.radius Border radius<br><code>float</code>
 @param border.size Border width<br><code>float</code>
 @param bg.scale Description coverstretchtilecontain<ul><li>cover</li><li>stretch</li><li>tile</li><li>contain</li></ul>
 @param longPress.enabled Enable long press<br><code>bool</code>
 @param enabled Enabled<br><code>bool</code>
 @param size.h Height<br><code>float</code>
 @param align.h Horizontal Alignment<ul><li>*left*</li><li>center</li><li>right</li></ul>
 @param layoutType Layout type<ul><li>*relative*</li><li>absolute</li><li><br><code>float</code></li></ul> *relative*
 @param shadow.blur Shador blur<br><code>float</code>
 @param shadow.alpha Shadow alpha<br><code>float</code>
 @param pinch.enabled Shadow color<br><code>color</code>
 @param shadow.color Shadow color<br><code>color</code>
 @param shadow.enabled Shadow enabled<br><code>bool</code>
 @param shadow.offset.b Shadow offset down<br><code>float</code>
 @param shadow.offset.r Shadow offset right<br><code>float</code>
 @param pixelRatio Snapshot resolution scale<br><code>float</code>
 @param swipe.enabled Swipe enabled<br><code>bool</code>
 @param tap.enabled Tap enabled<br><code>bool</code>
 @param size.w The width of the control <br><code>float</code>
 @param align.v Vertical Alignment<ul><li>*top*</li><li>middle</li><li>bottom</li></ul>
 @param visible Visible<br><code>bool</code>
 @param autofill.w Automatically fill remaining width<br><code>bool</code>
 @param autofill.h Automatically fill remaining height<br><code>bool</code>
 @param autosize.includeInParent What does this actually do?<br><code>bool</code>
 @param position.t Top position<br><code>float</code>
 @param position.l Left position<br><code>float</code>
 @param position.b Bottom position<br><code>float</code>
 @param padding Sets all 4 sides to this value.<br><code>float</code>
 @param padding.top Top padding<br><code>float</code>
 @param padding.right Right padding<br><code>float</code>
 @param padding.bottom Bottom padding<br><code>float</code>
 @param padding.left Left padding<br><code>float</code>
 @param margin Sets all 4 sides to this value.<br><code>float</code>
 @param margin.top Top margin<br><code>float</code>
 @param margin.right Right margin<br><code>float</code>
 @param margin.bottom Bottom margin<br><code>float</code>
 @param margin.left Left margin<br><code>float</code>
 @param pan.resetOnRelease.enabled When panning, resets the control to it's original position on touch up.<br><code>bool</code> *FALSE*
 @param pan.snapToBounds.enabled When panning, snaps back to the bounds of the superview on touch up.<br><code>bool</code> *TRUE*
 @param pinch.direction Configures the zoom direction of pinch/zoom.<ul><li>*both*</li><li>horizontal</li><li>vertical</li></ul> *both*
 @param pinch.resetOnRelease.enabled When pinching, resets back to it's original dimensions on touch up.<br><code>bool</code> *TRUE*
 @param pinch.zoomScale.max Maximum pinch zoom ratio.<br><code>float</code> *2*
 @param pinch.zoomScale.min Minumum pinch zoom ratio.<br><code>float</code> *1*
 @param pinch.zoomScale.elasticity Minumum elasticity of pinch zoom (you can pinch smaller than 1.0, but it resets on touch up).<br><code>float</code> *0.5*
 @param tap.count Minimum number of taps to recognize.<br><code>int</code>
 @param swipe.direction [required] Sets the direction in which to detect swipe gestures.<ul><li>up</li><li>down</li><li>left</li><li>right</li></ul>
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** BaseControl has the following events:
 
 @param touch Fires on touch
 @param touchUp Fires on touch up inside
 @param touchCancelled Fires on touch up outside
 @param longPress Fires when a long press is detected
 @param pan Fires when pan detected
 @param swipe Fires when swipe detected
 @param tap Fires when tap detected
 @param pinch.in Fires on pinch in
 @param pinch.out Fires on pinch out
 @param snapshot.success Fires when snapshot is saved successfully
 @param snapshot.error Fires when snapshot fails to save
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** BaseControl has the following functions:
 
 @param spin Spins the control; supports parameter ""direction""=""reverse"". Stop spinning by using ""stop_animating"" function.
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 @param stopAnimating Cancells and gracefully ends all animations on the control. Currently only supports spin animation.
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 @param takeSnapshot Takes a snapshot of the view. Supports parameter ""saveToLocation"".
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** BaseControl returns the following values:
 
 @param transform.scale Occurs on pinch - returns the new transform scale ratio.<br><code>float</code> *float*
 @param position Actual position on screen<br><code>float</code>
 @param position.x Actual position on screen, X axis<br><code>float</code>
 @param position.y Actual position on screen, Y axis<br><code>float</code>
 @param size.h.computed Computed height of control<br><code>float</code>
 @param size.w.computed Computed width of control<br><code>float</code>
 
 */

-(void)Returns
{
}
/***************************************************************/
/***************************************************************/

/** Go on, try it out!
*/

-(void)Example
{
}

/***************************************************************/

@end
