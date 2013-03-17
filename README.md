Properties
===========

Properties is a simple library to manage properties files (and something more) in Dart.

The project aim is to provide a simple and lightweight implementation of properties 
file management for Dart adding some useful but not so common features. 
Code and usage are very straightforward, just have a look at the Getting Started section below.

To know something more about the released version have a look at the
[CHANGELOG][changelog] to find the version that works best for you.

Getting started
-----------
The best way to get immediately started is to have 
a look at the unit tests provided along with the source code.

Anyway you can go on reading this quick intro.

Using Properties you can:

- create a new properties instance from file

```dart
Properties p = new Properties.fromFile(filepath);
```

- get a property out of it

```dart
String value = p.get('test.key.1');
```

..optionally providing a default value..

```dart
String defval = p.get('test.key.X', defval:'value X');
```

..or a default key..

```dart
String defkey = p.get('test.key.X', defkey:'test.key.1');
```

- get an int, a double or a bool value

```dart
int anInt = p.getInt('test.key.integer');
double aDouble = p.getDouble('test.key.double');
bool aBool = p.getBool('test.key.bool');
```

- get a list

```dart
List<String> list = p.getList('test.key.listofvalues');
```

- add a brand new property, choosing whether to overwrite an existing entry or not

```dart
bool added = p.add('test.key.3', 'value 3', true);
```

and then listen to "property added" or "property updated" events

```dart
p.onAdd.listen((AddEvent e) {
        eventType = e.type;
        key = e.key;
        value = e.value;
});
```

- export the content as a JSON sting, optionally choosing to export key having a
given prefix and/or suffix

```dart
String jsonexport = p.toJSON([prefix, suffix]);
```

- filter and extract property entries that matches custom conditions

```dart
Map<String,String> filtered = p.every((s) => s.startsWith('test'));
```
If you need some more details you may want to have a look to the [Properties Dartdoc here][dartdoc].

Running Tests
-------------
To run the tests just run the test/properties_test.dart file.

Some Limits
-------------
Output on file is not supported (yet!).

Any comment?
-------------
You're welcome! Just visit the [Google Code page][gcp] and open a new issue or mail me.

[changelog]: http://code.google.com/p/dart-properties/source/browse/tags/0.5.0/CHANGELOG
[gcp]: http://code.google.com/p/dart-properties/
[dartdoc]: http://code.google.com/p/dart-properties/source/browse/tags/0.5.0/#0.5.0%2Fdoc