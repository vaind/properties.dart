# Changelog

## Unreleased

* Add null-safety. ([#1](https://github.com/vaind/properties.dart/pull/1))

## 1.0.0 - 2022-01-30

* Update to Dart SDK 2.0+

## 0.5.4 - beta

* Compatibility update for SDK 0.5.13+1.r23552
* Getters and setters using [].
* Write to file method first working implementation and fixes.

## 0.5.3

* Fixed error on Event.
* Fixed carriage return problem on line parsing.
* Minor code improvements on merge and other.
* Deprecated enable/disable events triggering.

## 0.5.2+1 - 21-03-2013

* Compatibility update for SDK 0.4.2

## 0.5.2 - 21-03-2013

* Fixed a bug on merge methods, now managing existing empty properties without overwriting them in any case.
* Improved testing on merge methods.
* Now managing special characters for values decoding as UTF-8 the bytes read from file.

## 0.5.1 - 17-03-2013

* Fixed a bug on event triggering and management.
* Code refactoring to improve properties management.

## 0.5 - 16-03-2013

* Now files are read as bytes enabling deeper property management features.
* Added multi-line value support.
* Now the first non-escaped equal is parsed as key-value separator.
* Added getBool method with customizable evaluator.
* Minor doc improvements.
* Unit tests improvements.

## 0.4.4 - 16-03-2013

* Added new named constructor fromMap.
* Added getList method to get a list out of a property's value.
* Now every method returns a Properties instance instead of a Map.
* Minor code improvements.
* Minor doc improvements.

## 0.4.3 - 12-03-2013

* Added support for defaults (value and key) on getter methods.
* Added property updated event support.
* Now events may be enabled/disabled.
* Some minor, implementation fixes.

## 0.4.2 - 03-03-2013

* Minor fixes.
* Added two new methods to get integer and double out of a property.

## 0.4.1 - 02-03-2013

* Project structure refactoring in order to be published with PUB.

## 0.4.0 - 27-02-2013

* the method everyKey() is now every() and may optionally filter on property's value too;
* added AddEvent? class, extending PropertiesEvent?, having key and value properties set to the corresponding values of the newly added property;
* add key has now an additional optional parameter to decide whether to overwrite existing property, if any;
* improved doc and tests.

## 0.3.0 - 20-02-2013

* addFromXXX methods have been renamed into mergeXXX, giving the user the capability to choose whether to overwrite or keep existing matching properties:

  ```dart
  // dinamically merge properties from input Properties object into the
  // current instance's properties, without overwriting eventually existing   properties
  p.merge(anotherPropertiesInstance, false);

  // dinamically merge properties from input JSON object into the
  // current instance's properties, overwriting existing ones
  p.mergeJSON('{"test.key.3":"value 3","test.key.4":"value 4"}', true);
  ```

* added very simple event management: now one may listen to "add property" events triggered when a new property is added at runtime

  ```dart
  p.onAdd.listen((PropertiesEvent e) => print("Received: " + e.type));
  ```

## 0.2.0 - 17-02-2013

* Added some tools to work with JSON objects too

   ```dart
   // create a new instance from a JSON map
   Properties p = new Properties.fromJSON(jsonMap);

   // export the (whole) content as a JSON map
   p.toJSON(prefix:"keyprefix", suffix:"keysuffix");

   // dinamically add new properties to the current instance from JSON
   p.addFromJSON('{"test.key.3":"value 3","test.key.4":"value 4"}');
   ```

## 0.1.0 - 16-02-2013

* First release: basic tools, support for plain old properties files.
