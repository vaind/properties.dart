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

Create a new properties instance from file

```dart
Properties p = new Properties.fromFile(filepath);
```

get a property out of it

```dart
String value = p.get('test.key.1');
```

then add a brand new property, choosing whether to overwrite the entry or not

```dart
bool added = p.add('test.key.3', 'value 3', true);
```

listen to "property added" events

```dart
p.onAdd.listen((AddEvent e) {
        eventType = e.type;
        key = e.key;
        value = e.value;
});
```

export the content as a JSON sting, optionally choosing to export key having a
given prefix and/or suffix

```dart
String jsonexport = p.toJSON([prefix, suffix]);
```

filter and extract property entries that matches custom conditions

```dart
Map<String,String> filtered = p.every((s) => s.startsWith('test'));
```

To know something more about the released version have a look at the
CHANGELOG to find the version that works best for you.

Running Tests
-------------
To run the tests just run the test/properties_test.dart file.