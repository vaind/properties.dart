dart-properties
===========

dart-properties is a simple library to manage properties files (and something more) in Dart.

The project aim is to provide a very simple and lightweight implementation of properties 
file management for Dart. Code and usage are very straightforward.

Getting started
-----------
The best way to get immediately started is to have 
a look at the unit tests provided along with the source code.

Anyway you can go on reading this quick intro.

Add the dart-properties package to your pubspec.yaml file, selecting a version range
that works with your version of the SDK. For example:

```yaml
dependencies:
  dart-properties: ">=0.1.0 <0.4.0"
```

To know something more about the released version have a look at the
[changelog][changelog] to find the version that works best for you.

If you continually update your SDK, you can use the latest version of dart-properties:

```yaml
dependencies:
  dart-properties: any
```

Running Tests
-------------

Dependencies are installed using the [Pub Package Manager][pub].
```bash
pub install

To run the tests just run the test/properties_test.dart file.