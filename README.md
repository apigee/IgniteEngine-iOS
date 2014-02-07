ignite-iOS-engine
=================

Currently a work in progress, this engine is designed to parse JSON configuration files and generates native Objective-C objects, controls, and actions.

##PHP Preparser

A php preparser is used in the build process to parse int, float, and bool values, expand various shorthand implementations, and rewrite key:value paired controls to numbered array lists.

####Usage

 1. Ensure you have `php` >= 5.2.0 installed on your system.
 2. Pass a properly formatted iOS engine JSON file as an argument to *process.php* like so:
    `php process.php format_1.2.json`
 3. The preparser will append **_parsed** to the filename, and output the corrected file in the same directory.

---

##Todo List

####Text/Text input

- Input constraints (lowercase, uppercase, regular expressions?)
- Inline styling / markdown?
- Wraparound/append/prepend text for input ("Email: bob@something.com" -- user typed bob@something.com, Email is prepended)
  - This should NOT affect the actual content of the input. Perhaps it draws a label on either side?
- Allow centering of text *on the text element* instead of the layout
- Allow setting height and width on text element and positioning text within (instead of having to test within a Layout) Alt: set line-height for text widget
- This: http://stackoverflow.com/questions/11259983/vertically-align-uilabel

####Actions/Events:

- Find a means of chaining actions together to avoid massive arrays of actions.
- Ability to apply the same action to multiple IDs
- Ability to make touchable action area have a larger area than the element.
- Change "id" in attributes field to "target" so it isn't so ambiguous
- Why is "duration" under attributes and the target parameters under "parametesr"? Clean up and make it not ambiguous
- Multiple even/action triggers for a single event on: [touch_up, touch_cancelled]
- Change "None" (transition type) to "Default"
- Implement `UINavigationControllerDelegate` navigation style for slideout menus instead of displaying it as nested layouts.
- Simplify (can we merge?!) "event_name" and "on". Should be a single event listener. On "touch" On "custom_event".
- No "attributes" on actions only "target" then subkey "attributes" (instead of parameters)
- Change "focus_lost" to "blur"
- Change "on" to "trigger"
- Alerts "Title" and "Text"

####Data:

- ~~Can we implement an option to auto-map entity_attributes so we don't need to specify them?~~
- ~~Perhaps a simpler way of coverting json into dict/array so we don't have to handle complex maps. As it is, it's really (uncessarily) convoluted~~
- ~~We should have simpler JSON serialization approach. Leave in complex stuff for fallback?~~
- ~~Perform actions directly in the on-load event of the datasource~~
- Ability to reference length of longest entry.
- Default auto_load: false (add new action for "load", "refresh", "unload")

For example:

    array = (asdf, asdfasdf, asdflkjlakjsdlkjsdf);
    array.maxlength (returns 19)

####Objects:

- Eventually plan to build a visualizer that identifies and audits elements. Need to be able to tell the difference between UI controls and content. If necessary, just make one a subclass of the other so we don't end up duplicating Obj-c
- Define Button type, other types (Image should actually be IMAGE not a button)
so we can apply different states (and have it auto-detect image based on -active -disabled, etc.). Also color overlay for different states (active: alpha:0, disabled:overlay-#FFFFFF, etc.)
- Allow background image on elements? With cover, contain, stretch, position/offset
- Change "images.default" to something simpler if there's only one image?

####Core:

- File inclusion? Or is this done?
- Need to redefine [object]_[property] methodology (margin_left, text_placeholder, etc.) vs. the inverse.
- Properties need to be broken in to blocks rather than using underscores everywhere
- JSON should be true/false - parser should convert to YES/NO?
- Add into build parser a check for duplicate IDs? Or do we allow duplicate IDs?
- Would like a short-hand approach, and support for comments
- Mailbox style notification bar notices
- Ability to reload and reset all config
- Common naming convention/best practice for IDs
- Variables for things (colors, styles)
- Support for raw retina position & dimension values (640px instead of 320pt)
- Allow for classes to apply to multiple objects and actions to apply to multiple classes/ids
- Devise shorthand approach so we can use `view` and `view.controls` or even `myView.controls`.
- Rename AppConfig to something else not RFML like
- Implement 'self' (or 'this') for actions and properties
- Support for multiple ongoing projects running off the same framework
- ~~swap "enabled: false" to "disabled: true" (industry standard)~~

####Documentation:

- All of it. :| No seriously.

####Short-codes:

- Clean up implementation (use industry standards like {{}})
- Regular expression validation

####Tables:

- Have a fade-out **option** for top and bottom (text fades as it slides out of view)
- Allow action to be applied to entire table cell
- Easy way of creating list objects? If not, data will do. How to implement local data sources? Should be able to define a local datasource directly in the table element

####Formatting:
- need to properly define shorthand margin/padding etc.
- Define text styles in a separate file and reference them?
- Enhance tableview/Text to support horizontal formatting
- Default all elements to be 100% width or fill remaining width?
- change "layout_type" to "position"?

####Notes:

- Visible YES/NO?? vs. Alpha 0? We should combine these

####Layouts:

- Default width should be 100%
- Improve layout_type to support right and left alignment; default shoudl be relative and wrap [one][besidethenext] (instead of requiring float and h_align right)
- [align_left] [align_right] <-- big deal, since this will improve scalability
- Think "anchors" and x,y distance from an anchor point. 0123456789 ??
- Fill remaining height/width (define a header and footer, say, and have middle body stretch to fit). Should go hand in hand with anchor layouts. (looks like this is done?)

####Images:

- Should default to size of image (in points) ? Or for button backgrounds?

####Styles:

- Programmatic font interface? else we include this in the docs
- horizontal/vertical_alignment screws up 100% h/w. Need to be more clear how this is performed (or if alignment is defined, either ignore height/width or include it in the calculation)
- Inheriting styles (default styles)- set default font, then it doesn't need to be defined (only font.size)

