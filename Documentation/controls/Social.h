//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** Sharing is caring! Share to Twitter, Facebook, flickr, vimeo, Sina Weibo.
*/

@implementation Social

/***************************************************************/

/** This control has the following attributes:

    @param share.platform Where shall we share to?<br>*facebooktwitterflickrvimeosina_weibo*
    @param share.text What text do you want to share?<br>*(string)*
    @param share.url Shall we share a URL?<br>*(string)*
    @param share.image Ducklips?<br>*(string)*

*/

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** This control has the following attributes:

 @param facebook_available Is Facebook sharing available?<br>*(bool)*
 @param twitter_available Is Twitter sharing available?<br>*(bool)*
 @param flickr_available Is flickr sharing available?<br>*(bool)*
 @param vimeo_available Is Vimeo sharing available?<br>*(bool)*
 @param sina_weibo_available Is Sina Weibo sharing available?<br>*(bool)*

*/

-(void)Returns
{
}

/***************************************************************/
/***************************************************************/

/** This control fires the following events:


    @param share_done Fires when shared successfully
    @param share_cancelled Fires if the user dismisses the view controller

*/

-(void)Events
{
}

/***************************************************************/
/***************************************************************/

/** This control supports the following functions:


 @param present_share_controller
 
 <pre class="brush: js; toolbar: false;">
 
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "socialTest",
    "function_name": "present_share_controller"
  }
}
 
 </pre>
 
 @param dismiss_share_controller
 
 <pre class="brush: js; toolbar: false;">

{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "socialTest",
    "function_name": "dismiss_share_controller"
  }
}
 
 </pre>
 
*/

-(void)Functions
{
}

/***************************************************************/
/***************************************************************/

/** Go on, try it out!


 <pre class="brush: js; toolbar: false;">
 
{
  "_id": "socialTest",
  "_type": "Social",
  "actions": [
    {
      "on": "share_done",
      "_type": "Alert",
      "attributes": {
        "title": "share_done"
      }
    }
  ],
  "attributes": {
    "share.platform": "twitter",
    "share.text": "I can't wait for you all to see this pic!",
    "share.url": "http://duck.lips",
    "share.image": "http://images.sodahead.com/slideshows/000020095/1537637670_ducklips87y6-103619834647_xlarge.png"
  }
}
 
 </pre>

*/

-(void)Example
{
}

/***************************************************************/

@end
