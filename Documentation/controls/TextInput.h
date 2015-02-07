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

/** This control has the following attributes:

    @param font Text font<br>*(string)*
    @param cursor.color Cursor color<br>*(color)*
    @param autocorrect Enables or disables system autocorrect *(default: TRUE)*<br>*(bool)*
    @param dismiss_on_return Enables automatic closing of keyboard when return key pressed *(default: FALSE)*<br>*(bool)*
    @param layout_to_scroll Array of reference pointers of view(s) that should scroll when keyboard appears<br>*(ref)*
    @param keyboard_adjusts_screen Sets whether the keyboard appearing should automatically adjust the current view when<br>*(bool)*
    @param is_multiline Sets the input to allow multiple lines of text<br>*(bool)*
    @param initial_text Initial text present in input (not placeholder!)<br>*(string)*
    @param text.color Text color<br>*(color)*
    @param text.placeholder Placeholder text (re-appears when input is empty)<br>*(string)*
    @param text.placeholder.color Color of placeholder text<br>*(color)*
    @param text.alignment Text alignment (left, center, right, justified)<br>*(string)*
    @param background.color Background color text input view<br>*(color)*
    @param clears_on_begin_editing Clears text when input becomes first responder (only works on non-multiline input) *(default: FALSE)*<br>*(bool)*
    @param image.left Left image – must use relative path including assets/ (only available on multiline input)<br>*(path)*
    @param image.right Right image – must use relative path including assets/ (only available on multiline input)<br>*(path)*
    @param image.background <br>*(????)*
    @param image.hides_when_empty Sets whether defined image should hide when text is empty (only works on multiline input)<br>*(bool)*
    @param keyboard.appearance Keyboard tint (light, dark, default) *(default: default)*<br>*(string)*
    @param keyboard.type Keyboard type (email, number, phone, url, decimal, name_phone, numbers_punctuation, default) *(default: default)*<br>*(string)*
    @param keyboard.padding Keyboard padding *(default: 0)*<br>*(integer)*
    @param keyboard.return_key Keyboard return key type (go, next, search, done, join, send, route, emergency, google, yahoo) *(default: default)*<br>*(string)*
    @param input.format.currency Sets whether the input should be formatted as currency *(default: FALSE)*<br>*(bool)*
    @param input.format.credit_card Sets whether the input should be formatted as a credit card *(default: FALSE)*<br>*(bool)*
    @param input.regex.allowed A regular expression of explicitly allowed characters<br>*(regex)*
    @param input.regex.disallowed A regular expression of explicitly disallowed characters<br>*(regex)*
    @param input.max Maximum allowed number of characters<br>*(integer)*
    @param input.transform Text transform (capitalize, lowercase, uppercase, ucfirst)<br>*(string)*

*/

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** This control has the following attributes:

 @param text Current text value of the text input control (to set the text use the kSetText function)<br>*(string)*

*/

-(void)Returns
{
}

/***************************************************************/
/***************************************************************/

/** This control fires the following events:


    @param got_focus Fires when the input control becomes first responder
    @param lost_focus Fires when the input control loses focus
    @param return_key_pressed Fires when the user selects the return key
    @param text_changed Fires when text is changed
    @param image.right.tapped Fires when the right-hand image is tapped
    @param image.left.tapped Fires when the left-hand image is tapped

*/

-(void)Events
{
}

/***************************************************************/
/***************************************************************/

/** This control supports the following functions:


    @param set_text 
 
 <pre class="brush: js; toolbar: false;">
 
 </pre>

    @param keyboard_hide 
 
 <pre class="brush: js; toolbar: false;">
 
 </pre>

    @param keyboard_show, focus 
 
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