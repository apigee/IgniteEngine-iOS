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

/** This control has the following attributes:

    @param width The width of the control<br>*(integer)*
    @param height The height of the control<br>*(integer)*
    @param alpha The alpha of the control<br>*(float)*
    @param border.width The border width<br>*(integer)*
    @param border.color Description<br>*(color)*
    @param border.radius Description<br>*(float)*
    @param background.color Description<br>*(color)*
    @param background.image Description<br>*(string)*
    @param background.image.scale Description<br>*coverstretchtilecontain*
    @param cicontext.resolution Description<br>*(float)*
    @param enabled Description<br>*(bool)*
    @param enable_tap Description<br>*(bool)*
    @param enable_swipe Description<br>*(bool)*
    @param enable_pinch Description<br>*(bool)*
    @param enable_pan Description<br>*(bool)*
    @param enable_long_press Description<br>*(bool)*
    @param enable_shadow Description<br>*(bool)*
    @param layout_type Description *(default: relative)*<br>*relativeabsolutefloat*
    @param horizontal_alignment Description *(default: relative)*<br>*leftcenterright*
    @param vertical_alignment Description *(default: relative)*<br>*topmiddlebottom*
    @param shadow_blur Description<br>*(float)*
    @param shadow_alpha Description<br>*(float)*
    @param shadow_color Description<br>*(color)*
    @param shadow_offset_right Description<br>*(float)*
    @param shadow_offset_down Description<br>*(float)*
    @param visible Description<br>*(bool)*

*/

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/**  This control has the following read-only attributes:
*/

-(void)Returns
{
}

/***************************************************************/
/***************************************************************/

/** This control fires the following events:

    @param touch Fires when the control is touched
    @param touch_up Fires when the control touch is released
    @param touch_cancelled Fires when the control touch is canceled
    @param tap Fires when the control is tapped (tap_count, integer)
    @param swipe Fires when the control is swiped (down, up, right, left)
    @param pan Fires when ?
    @param long_press Fires when the control receives a long press
    @param ** Fires when

*/
-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** This control supports the following functions:
*/

-(void)Functions
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
