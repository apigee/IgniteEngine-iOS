ignite-iOS-engine
=================

- Currently a work in progress, this engine is designed to parse JSON configuration files and generates native Objective-C objects, controls, and actions.

Preparser
=========

A php preparser is used in the build process to parse int, float, and bool values, expand various shorthand implementations, and rewrite key:value paired controls to numbered array lists.

Usage
-----

Ensure you have `php` >= 5.2.0 installed on your system.

Pass a properly formatted iOS engine JSON file as an argument to *process.php* like so:

`php process.php format_1.2.json`

The preparser will append **_parsed** to the filename, and output the corrected file in the same directory.
