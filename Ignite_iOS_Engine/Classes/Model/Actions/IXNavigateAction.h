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

#import "IXBaseAction.h"

@interface IXNavigateAction : IXBaseAction

@end
