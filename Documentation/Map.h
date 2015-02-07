//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** Displays a native iOS Map. Can display a single annotation, or, point to a Data Provider to display a whole heap of pins.
*/

@implementation Map

/***************************************************************/

/** This control has the following attributes:

    @param dataprovider_id Data Provider ID<br>*(string)*
    @param shows_user_location Display user's location *(default: FALSE)*<br>*(bool)*
    @param shows_points_of_interest Show points of interest *(default: TRUE)*<br>*(bool)*
    @param shows_buildings Show buildings *(default: TRUE)*<br>*(bool)*
    @param map_type Map type *(default: standard)*<br>*standard, satellite, hybrid*
    @param zoom_level Default zoom level<br>*(int)*
    @param center.latitude Center map on this latitude<br>*(float)*
    @param center.longitude Center map on this longitude<br>*(float)*
    @param annotation.image Custom pin image<br>*(string)*
    @param annotation.image.center.offset.x Custom pin image offset X<br>*(float)*
    @param annotation.image.center.offset.y Custom pin image offset Y<br>*(float)*
    @param annotation.title Annotation title<br>*(string)*
    @param annotation.subtitle Annotation subtitle<br>*(string)*
    @param annotation.latitude Annotation latitude<br>*(float)*
    @param annotation.longitude Annotation longitude<br>*(float)*
    @param annotation.accessory.left.image Map type *(default: standard)*<br>*standard, satellite, hybrid*
    @param annotation.pin.color Annotation pin color (when not using custom pin image) *(default: red)*<br>*red, green, purple*
    @param annotation.pin.animates_drop Animate pins dropping from the sky *(default: TRUE)*<br>*(bool)*

*/

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** This control has the following attributes:





*/

-(void)Returns
{
}

/***************************************************************/
/***************************************************************/

/** This control fires the following events:


    @param touch Fires when an annotation is touched
    @param touch_up Fires on annotation touch up inside

*/

-(void)Events
{
}

/***************************************************************/
/***************************************************************/

/** This control supports the following functions:


    @param reload_annotations 
<pre class="brush: js; toolbar: false;">

</pre>
    @param show_all_annotations 
<pre class="brush: js; toolbar: false;">

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
