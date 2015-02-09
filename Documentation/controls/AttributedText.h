//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** A text label that automagically detects things like @mentions, #hastags, and http://links
*/

@implementation AttributedText

/***************************************************************/

/** AttributedText has the following attributes:
 
 @param mentions.enabled Apply style to (@) mentions<br><code>bool</code>
 @param hashtags.enabled Apply style to (#) hashtags<br><code>bool</code> *TRUE*
 @param links.enabled Apply style to (http://) hyperlinks<br><code>bool</code>
 @param bg.color Background color<br><code>color</code>
 @param code.bg.color    Background color of `code` <br><code>color</code>
 @param code.border.color    Border color of `code`<br><code>color</code>
 @param code.border.radius   Border radius of `code`<br><code>float</code>
 @param code.color   Color of `code` text<br><code>color</code>
 @param hashtags.color    Color of hashtags<br><code>color</code>
 @param links.color Color of hyperlinks<br><code>color</code>
 @param mentions.color    Color of mentions<br><code>color</code>
 @param color Color of normal text<br><code>color</code>
 @param code.font    Font of `code`<br><code>font</code>
 @param hashtags.font     Font of hashtags<br><code>font</code>
 @param links.font Font of hyperlinks<br><code>font</code>
 @param mentions.font     Font of mentions<br><code>font</code>
 @param font Font of normal text<br><code>font</code>
 @param kerning Kearning<br><code>float</code>
 @param lineHeight.max Line height maximum<br><code>int</code>
 @param lineHeight.min Line height minimum<br><code>int</code>
 @param lineSpacing Line spacing<br><code>float</code>
 @param markdown.enabled Parse Markdown<br><code>bool</code>
 @param hashtags.scheme   Regex for hashtags<br><code>string</code>
 @param mentions.scheme   Regex for mentions<br><code>string</code>
 @param text Text<br><code>string</code>
 @param text.align   Text alignment<br><code>string</code>
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** AttributedText has the following events:
 
 @param longPressMention Fires on long press of an @mention<br><code>string</code>
 @param longPressHashtag Fires on long press of a #hashtag<br><code>string</code>
 @param longPressLink Fires on long press of a hyperlink<br><code>string</code>
 @param touchUpMention Fires on touch up of an @mention<br><code>string</code>
 @param touchUpHashtag Fires on touch up of a #hashtag<br><code>string</code>
 @param touchUpLink Fires on touch up of a hyperlink<br><code>string</code>
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** AttributedText has no functions.
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** AttributedText returns the following values:
 
 @param selectedMention Value of mention selected<br><code>string</code>
 @param selectedLink Value of url selected<br><code>string</code>
 @param alpha Alpha<br><code>float</code>
 
 */

-(void)Returns
{
}
/***************************************************************/
/***************************************************************/

/** Go on, try it out!

<pre class="brush: js; toolbar: false;">
{
    "_id": "attributedText",
    "_type": "AttributedText",
    "actions": [
        {
            "_type": "Alert",
            "attributes": {
                "message": "[[$self.selectedMention]]",
                "title": "You long_press'd:"
            },
            "on": "longPressMention"
        }
    ],
    "attributes": {
        "align.h": "center",
        "align.v": "middle",
        "layoutType": "absolute",
        "size.w": "200",
        "text": "Johnny, @paula, silly and @sally were #hoodwinked.",
        "text.align": "center"
    }
}
</pre>
*/

-(void)Example
{
}

/***************************************************************/

@end
