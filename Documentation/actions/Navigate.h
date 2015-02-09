//
//  IXNavigateAction.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 11/27/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

/*
 
 ACTION
 
 - TYPE : "Navigate"
 
 - PROPERTIES
 
 * name="to"                        default=""              type="PATH"
 * name="nav_pop_to_view_id"        default=""              type="VIEW ID"
 * name="nav_stack_type"            default="push"          type="push,pop"
 * name="nav_animation_type"        default="default"       type="flip_from_left,flip_from_right,curl_up,curl_down"
 * name="nav_animation_delay"       default="0.0"           type="FLOAT"
 * name="nav_animation_duration"    default="0.75"          type="FLOAT"

 */

@interface Navigate

/***************************************************************/

/** Navigate has the following attributes:
 
 @param animation.delay Navigation animation delay<br><pre>float</pre>
 @param animation.duration Navigation animation duration<br><pre>float</pre>
 @param animation.type Navigation animation type<ul><li>*moveIn*</li><li>pop</li><li>replace</li><li>external</li></ul>
 @param popToId Target controller ID to pop to<br><pre>string</pre>
 @param stackType Navigation stack type<ul><li>*push*</li><li>pop</li><li>replace</li><li>external</li></ul>
 @param to.url Navigate to url<br><pre>string</pre>
 @param crossDissolve Cross dissolve
 @param curl.d Curl down
 @param curl.u Curl up
 @param external Navigate to url outside of app
 @param flip.b Flip from bottom
 @param flip.l Flip from left
 @param flip.r Flip from right
 @param flip.t Flip from top
 @param moveIn Move in
 @param pop Pop current view controller from stack
 @param push Push new view controller onto existing stack
 @param replace Replace stack with new view
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** Navigate has the following events:
 
 @param error Fires when navigation fails
 @param success Fires when navigation is successful
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** Navigate has no functions.
 
 
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** Navigate returns no values.
 
 
 
 */

-(void)Returns
{
}
/***************************************************************/

@end
