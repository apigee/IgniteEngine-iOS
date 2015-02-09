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

/** IXSocial has the following attributes:
 
 @param platform facebook<ul><li>facebook</li><li>twitter</li><li>flickr</li><li>vimeo</li><li>sinaWeibo</li></ul>
 @param image Image<br><code>string</code>
 @param text Text<br><code>string</code>
 @param url URL<br><code>string</code>
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** IXSocial has the following events:
 
 @param cancelled Fires on cancelled
 @param success Fires on success
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** IXSocial has the following functions:
 
 @param dismiss Dismisses the share controller
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 @param present Presents share view controller
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** IXSocial returns the following values:
 
 @param isAllowed.facebook Returns true if Facebook is available<br><code>bool</code>
 @param isAllowed.flickr Returns true if Flickr is available<br><code>bool</code>
 @param isAllowed.sinaWeibo Returns true if Sina Weibo is available<br><code>bool</code>
 @param isAllowed.twitter Returns true if Twitter is available<br><code>bool</code>
 @param isAvailable.vimeo Returns true if Vimeo is available<br><code>bool</code>
 
 */

-(void)Returns
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
            "_type": "Alert",
            "attributes": {
                "title": "success"
            },
            "on": "success"
        }
    ],
    "attributes": {
        "image": "http://images.sodahead.com/slideshows/000020095/1537637670_ducklips87y6-103619834647_xlarge.png",
        "platform": "twitter",
        "text": "I can't wait for you all to see this pic!",
        "url": "http://duck.lips"
    }
}</pre>

*/

-(void)Example
{
}

/***************************************************************/

@end
