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

/** Map has the following attributes:
 
 @param animatePinDrop.enabled Animate pins dropping onto map<br><code>bool</code> *TRUE*
 @param center.lat Center map on latitude<br><code>float</code>
 @param center.long Center map on longitude<br><code>float</code>
 @param pin.color Color of pin<ul><li>*red*</li><li>green</li><li>purple</il></ul>
 @param datasource.id Datasource ID<br><code>string</code>
 @param buildings.enabled Display buildings on maps<br><code>bool</code> *TRUE*
 @param pin.leftImage Image displayed on the left of the pin detail<br><code>string</code>
 @param pin.image Image used instead of default pin<br><code>string</code>
 @param pin.lat Latiude of pin<br><code>float</code>
 @param pin.long Longitude of pin<br><code>float</code>
 @param mapType Map type<ul><li>*standard*</li><li>satellite</li><li>hybrid</li></ul>
 @param pin.centerOffset.x Offset image on the x axis<br><code>float</code>
 @param pin.centerOffset.y Offset image on the y axis<br><code>float</code>
 @param pointsOfInterest.enabled Points of interest enabled<br><code>bool</code>
 @param pin.subtitle Subtitle of pin detail<br><code>string</code>
 @param pin.title Title of pin detail<br><code>string</code>
 @param userLocation.enabled User location enabled<br><code>bool</code>
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** Map has the following events:
 
 @param touch Fires on touch
 @param touchUp Fires on touch up inside
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** Map has the following functions:
 
 @param refreshPins Refreshes pins on map
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 @param showAllPins Reloads view to display all pins
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** Map returns no values.
 
 */

-(void)Returns
{
}
/***************************************************************/
/***************************************************************/

/** Go on, try it out!

<pre class="brush: js; toolbar: false;">
{
    "_id": "mapControl",
    "_type": "Map",
    "actions": [
        {
            "_type": "Alert",
            "attributes": {
                "title": "You touched on [[$self.pin.title]]."
            },
            "on": "touchUp"
        }
    ],
    "attributes": {
        "animatePinDrop.enabled": true,
        "pin": {
            "lat": "37.333916",
            "long": "-121.894076",
            "subtitle": "Subtitle",
            "title": "Title"
        },
        "size.h": "100%",
        "size.w": "100%",
        "userLocation.enabled": true,
        "zoomLevel": 12
    }
}
</pre>
*/

-(void)Example
{
}

/***************************************************************/

@end
