//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** Converts Text-to-Speech; **Note:** *Device only, does not work in simulator.*
*/

#import "TextToSpeech.h"

@implementation Speech

/***************************************************************/

/** IXTextToSpeech has no attributes.
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** IXTextToSpeech has no events.
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** IXTableView has the following functions:
 
 @param continue Continues speech
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 @param pause Pauses speech
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 @param queue Queues speech
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 @param stop Stops speech
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** IXTextToSpeech returns no values.
 
 */

-(void)Returns
{
}
/***************************************************************/
/***************************************************************/

/** Go on, try it out!

<pre class="brush: js; toolbar: false;">
{
    "_id": "speechTest",
    "_type": "Speech",
    "attributes": {}
},
{
    "_id": "TextInput",
    "_type": "TextInput",
    "actions": [
        {
            "_type": "Modify",
            "attributes": {
                "_target": "session"
            },
            "on": "textChanged,focus",
            "set": {
                "text_to_speak": "[[$self.text]]"
            }
        }
    ],
    "attributes": {
        "align.h": "center",
        "color": "#6c6c6c",
        "font": "HelveticaNeue-Light:22",
        "initial_text": "How much wood could a woodchuck chuck if a woodchuck could chuck wood ?",
        "multiline.enabled": true,
        "placeholder": "Type something...",
        "size.h": 120,
        "size.w": 280,
        "text.align": "left"
    }
}
</pre>
*/

-(void)Example
{
}

/***************************************************************/

@end
