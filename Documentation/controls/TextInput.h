//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** Capture input from the user
*/

@implementation TextInput

/***************************************************************/

/** IXTextInput has the following attributes:
 
 @param keyboardAdjustsScreen.enabled Adjust a target layout to accomodate keyboard<br><code>bool</code>
 @param bg.color Background color<br><code>color</code>
 @param bg.image Background image<br><code>string</code>
 @param clearOnFocus.enabled Clear existing text on focus<br><code>bool</code> *FALSE*
 @param color Color<br><code>color</code>
 @param cursor.color Cursor color<br><code>color</code>
 @param text.default Default text<br><code>string</code>
 @param dismissOnReturn.enabled Dismiss keyboard on return key press<br><code>bool</code> *TRUE*
 @param font Font<br><code>font</code>
 @param formatAsCreditCard.enabled Format text as a credit card<br><code>bool</code> *FALSE*
 @param formatAsCurrency.enabled Format text as currency<br><code>bool</code> *FALSE*
 @param hideImageWhenEmpty.enabled Hide image when empty<br><code>bool</code> *FALSE*
 @param image.left Image displayed on left<br><code>string</code>
 @param image.right Image displayed on right<br><code>string</code>
 @param keyboard.appearance Keyboard appearance<ul><li>*light*</li><li>dark</li></ul>
 @param keyboard.padding Keyboard padding<br><code>float</code>
 @param keyboard.returnKey Keyboard return key<ul><li>*done*</li><li>go</li><li>next</li><li>search</li><li>done</li><li>join</li><li>send</li><li>route</li><li>emergency</li><li>google</li><li>yahoo</li></ul>
 @param keyboard.type Keyboard type<ul><li>*default*</li><li>email</li><li>number</li><li>phone</li><li>url</li><li>decimal</li><li>name_phone</li><li>numbers_punctuation</li><li>emergency</li><li>google</li><li>yahoo</li></ul>
 @param layout_to_scroll Layout to scroll<br><code>string</code>
 @param maxChars Maximum allowed characters<br><code>int</code>
 @param multiline.enabled Multiline<br><code>bool</code>
 @param placeholder.text Placeholder text<br><code>string</code>
 @param placeholder.color Placeholder text color<br><code>color</code>
 @param regex.allowed Regex allowed<br><code>string</code>
 @param regex.disallowed Regex disallowed<br><code>string</code>
 @param text.align   Text alignment<ul><li>*left*</li><li>center</li><li>right</li></ul>
 @param text.transform Transform text<ul><li>capitalize</li><li>lowercase</li><li>uppercase</li><li>ucfirst</li></ul>
 @param autocorrect.enabled Use autocorrect<br><code>bool</code> *TRUE*
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** IXTextInput has the following events:
 
 @param focus Fires on focus
 @param focusLost Fires on focus lost
 @param leftImageTapped Fires when left image tapped
 @param returnKeyPressed Fires when return key pressed
 @param rightImageTapped Fires when right image tapped
 @param textChanged Fires when text changed
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** IXTextInput has the following functions:
 
 @param dismissKeyboard Dismisses the keyboard
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 @param getFocus Gives focus
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 @param setText Sets text
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** IXTextInput returns the following values:
 
 @param text Returns text<br><code>string</code>
 
 */

-(void)Returns
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