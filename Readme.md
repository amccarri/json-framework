HomeAway SBJson
===============
HomeAway SBJson is a modification of SBJson that adds reflective serialization/deserialization between JSON strings and Objective-C classes.  It was inspired by Java JSON parsing libraries like Jackson and SOJO.  The idea is to make JSON parsing easier by not requiring the developer to remember what the contents of the dictionary are going to look like at runtime, and instead just use a set of well known DTOs which the parser will unmarshall from JSON.

### Examples of using the Reflective Parser

#### The Base Case
The simplest case JSON parsing is a class with a flat structure that only includes simple objects as properties (no dictionaries, arrays, or sets).

	@interface MyFlatObj : NSOjbect
	@property (nonatomic, copy) NSString *someStringObject;
	@property (nonatomic, copy) NSString *someOtherStringObject;
	@property (nonatomic, strong) MyOtherObj *someOtherCustomObject;
	@end
	
Converting to and from JSON:

	// read from JSON
	MyFlatObj *obj = [[MyFlatObj alloc] initWithJson:aJsonString];
	
	// output json
	[obj json];
	
#### Classes with collection properties
Dealing with collection classes are tricker since Objective-C does not have a notion of generic types there is no way to automatically have the parser determine the type of object that should fill the array, so you have to provide hints if your object that you are unmarshalling to contains such a beast.  For example:

	@interface MyComplexObj : NSObj
	@property (nonatomic, strong) MyOtherObj *easyOtherObjToMap
	@property (nonatomic, strong) NSArray *arrayOfDingus;
	@property (nonatomic, strong) NSArray *arrayOfFoo;
	@end
	
	// mapping the dingus
	MyComplexObj *obj = [[MyComplexObj alloc] initWithJson:aJsonString andCollectionMaps:[JsonCollectionMap map:@"arrayOfDingus" toClass:Dingus.class],
																						 [JsonCollectionMap map:@"arrayOfFoo" toClass:Foo.class], nil];
	
The easiest way to deal with this is to have the target class override initWithJson to set up these maps.  

	@implementation MyComplexObj
	
	- (id)initWithJson:(NSString *)jsonString {
		return [self initWithJson:jsonString andCollectionMaps:[JsonCollectionMap map:@"arrayOfDingus" toClass:Dingus.class],
															   [JsonCollectionMap map:@"arrayOfFoo" toClass:Foo.class], nil];
	}
	
	@end
	
Then parsing again becomes a matter of:

	MyComplexObj *myObj = [[MyComplexObj alloc] initWithJson:jsonString];

The caveat with this approach is that your mappings will apply to all properties in the json tree.  So any property of field type arrayOfDingus or arrayOfFoo will now be mapped to the given classes.  If two different classes declare two collection properties of the same name but different content types, then that will cause problems.

#### Plain collections

If the result is just a simple array and not necessarily an object:

	NSArray *arrayOfDingus = [[NSDingus alloc] initWithArray:jsonArrayString andMappings:...collection maps...];

SBJson (aka json-framework)
===========================

JSON (JavaScript Object Notation) is a light-weight data interchange format that's easy to read and write for humans and computers alike. This library implements strict JSON parsing and generation in Objective-C.

### Streaming JSON Support

SBJson supports parsing of documents chunk-by-chunk, suitable for use with *NSURLConnection*. This means you can start parsing a JSON document before it is fully downloaded. Depending how you configure the delegates you can choose to have the entire document delivered to your process when it's finished parsing, or delivered bit-by-bit as records on a particular depth finishes downloading. For more details see *SBJsonStreamParser* in the [API docs][api].

There is also support for *writing to* JSON streams. This means you can write huge JSON documents to disk, or an HTTP destination, without having to hold the entire structure in memory. You can use this to generate a stream of tick data for a stock trading simulation, for example. For more information see *SBJsonStreamWriter* in the [API docs][api].

### API documentation integrated with Xcode

The *InstallDocumentation.sh* script allows you to generate [API documentation][api] from the source and install it into Xcode, so it's always at your fingertips. (This script requires [Doxygen][] to be installed.) After running the script from the top-level directory, open Xcode's documentation window and search for SBJson. (You might have to close and re-open Xcode for the changes to take effect.)

### TweetStream Example Project

An example project showing how to use the new streaming functionality to interact with Twitter's multi-document streams. This also shows how to link to the iOS static lib rather than having to copy the classes into your project.

### DisplayPretty Example Project

A small Mac example project showing how to link to an external JSON framework rather than copying the sources into your project. This is a fully functional (though simplistic) application that takes JSON input from a text field and presents it nicely formatted into another text field.

Features also present in previous versions
------------------------------------------

* BSD license.
* Super-simple high-level API: Calling `-JSONValue` on any NSString instance parses the JSON text in that string, and calling `-JSONRepresentation` on any NSArray or NSDictionary returns an NSString with the JSON representation of the object.
* The *SBJsonParser* and *SBJsonWriter* classes provides an object-oriented API providing a good balance between simplicity and flexibility.
* Configurable recursion depth limit for added security.
* Supports (but does not require) garbage collection.
* Sorted dictionary keys in JSON output.
* Pretty-printing of JSON output.

Installation
============

The simplest way to start using JSON in your application is to copy all the source files (the contents of the `Classes` folder) into your own Xcode project.

1. In the Finder, navigate to the `$PATH_TO_SBJSON/Classes` folder and select all the files.
1. Drag-and-drop them into your Xcode project.
1. Tick the **Copy items into destination group's folder** option.
1. Use `#import "SBJson.h"` in  your source files.

That should be it. Now create that Twitter client!

Upgrading
---------

If you're upgrading from a previous version, make sure you're deleting the old SBJson classes first, moving all the files to Trash.


Linking rather than copying
---------------------------

Copying the SBJson classes into your project isn't the only way to use this framework. (Though it is the simplest.) With Xcode 4's workspaces it has become much simpler to link to dependant projects. Linking is required if you want to use it with ARC (Automatic Reference Counting). The two examples in this distribution shows how to do the linking, for both Mac and iOS projects.

Links
=====

* [GitHub project page](http://github.com/stig/json-framework)
* [Example Projects](http://github.com/stig/json-framework/Examples)
* [Online API docs][api]
* [Frequently Asked Questions](http://github.com/stig/json-framework/wiki/FrequentlyAskedQuestions)

[api]: http://stig.github.com/json-framework/api/3.0/
[Doxygen]: http://doxygen.org
