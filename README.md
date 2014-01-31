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

####Actions:

- Find a means of chaining actions together to avoid massive arrays of actions.
- Ability to apply the same action to multiple IDs
- Ability to make touchable action area have a larger area than the element.

####Data:

- Can we implement an option to auto-map entity_attributes so we don't need to specify them?
- Perhaps a simpler way of coverting json into dict/array so we don't have to handle complex maps
- Ability to reference length of longest entry. For example:
    array = (asdf, asdfasdf, asdflkjlakjsdlkjsdf);
    array.maxlength (returns 19)

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

####Documentation:

- All of it. :| No seriously.

####Short-codes:

- Clean up implementation (use industry standards like {{}})
- Regular expression validation

####Tables:

- Have a fade-out **option** for top and bottom (text fades as it slides out of view)
- Allow action to be applied to entire table cell

####Formatting:
- need to properly define shorthand margin/padding etc.
- Define text styles in a separate file and reference them?
- Enhance tableview/Text to support horizontal formatting
- Default all elements to be 100% width?

####Notes:

- Visible YES/NO?? vs. Alpha 0? We should combine these
