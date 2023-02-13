import 'dart:io';

import 'package:test/test.dart';

import '../lib/properties.dart';

void main() {
  // in order for tests to run on your machine you may have to add ../ before file paths
  String baseFile = 'resources/sample.properties';
  String advancedFile = 'resources/sample-adv.properties';
  String jsonSource =
      '{"key.1" : "value 1", "key.2" : "value 2", "another.key" : "another value"}';

  group('Creation - from properties file', () {
    test('Existing by path',
        () => expect(Properties.fromFile(baseFile), isNotNull));
    test('Existing by name', () => expect(Properties(baseFile), isNotNull));
  });

  group('Creation - from JSON string', () {
    test('JSON map input',
        () => expect(Properties.fromJSON(jsonSource), isNotNull));
  });

  group('Getters - from file source', () {
    late Properties p;
    setUp(() {
      p = Properties.fromFile(baseFile);
    });
    test('Existing key - not null',
        () => expect(p.get('test.key.1'), isNotNull));
    test('Existing key - equals',
        () => expect(p.get('test.key.1'), equals('value 1')));
    test('Not existing key', () => expect(p.get('not.existing'), isNull));

    test('Existing key using []',
        () => expect(p['test.key.1'], equals('value 1')));
    test('Not existing key using []', () => expect(p['not.existing'], isNull));

    test('Get keys', () {
      Iterable<String> i = p.keys;
      expect(i.length, 3);
    });
  });

  group('Getters with default', () {
    late Properties p;
    setUp(() {
      p = Properties.fromFile(baseFile);
    });

    test('Not existing key - default value',
        () => expect(p.get('test.key.X', defval: 'value X'), isNotNull));
    test(
        'Not existing key - default value',
        () =>
            expect(p.get('test.key.X', defval: 'value X'), equals('value X')));

    test('Not existing key - default key',
        () => expect(p.get('test.key.X', defkey: 'test.key.1'), isNotNull));
    test(
        'Not existing key - default key',
        () => expect(
            p.get('test.key.X', defkey: 'test.key.1'), equals('value 1')));
    test('Not existing key - default key, not existing',
        () => expect(p.get('test.key.X', defkey: 'test.key.Y'), isNull));

    test(
        'Not existing key - default value & key',
        () => expect(
            p.get('test.key.X', defval: 'value X', defkey: 'test.key.1'),
            equals('value X')));
  });

  group('Getters - from JSON source', () {
    late Properties p;
    setUp(() {
      p = Properties.fromJSON(jsonSource);
    });
    test('Existing key - not null', () => expect(p.get('key.1'), isNotNull));
    test('Existing key - equals',
        () => expect(p.get('key.1'), equals('value 1')));
    test('Existing key - equals',
        () => expect(p.get('another.key'), equals('another value')));
    test('Not existing key', () => expect(p.get('not.existing'), isNull));
    test('Get keys', () {
      Iterable<String> i = p.keys;
      expect(i.length, 3);
    });
  });

  group('Getters - from String source', () {
    late Properties p;
    setUp(() {
      p = Properties.fromString(File(baseFile).readAsStringSync());
    });
    test('Existing key - not null',
        () => expect(p.get('test.key.1'), isNotNull));
    test('Existing key - equals',
        () => expect(p.get('test.key.1'), equals('value 1')));
    test('Not existing key', () => expect(p.get('not.existing'), isNull));

    test('Existing key using []',
        () => expect(p['test.key.1'], equals('value 1')));
    test('Not existing key using []', () => expect(p['not.existing'], isNull));

    test('Get keys', () {
      Iterable<String> i = p.keys;
      expect(i.length, 3);
    });
  });

  group('Advanced features', () {
    late Properties p;
    setUp(() {
      p = Properties.fromFile(advancedFile);
    });

    test('Load value with escaped backslash',
        () => expect(p.get('test.key.slash'), equals(r"C:\\test\\slash")));

    test('Property with int value existing',
        () => expect(p.get('test.key.integer'), isNotNull));
    test('Load int value',
        () => expect(p.getInt('test.key.integer'), isNotNull));
    test('Loaded int value parsed successfully',
        () => expect(p.getInt('test.key.integer'), equals(1)));

    test('Property with double value existing',
        () => expect(p.get('test.key.double'), isNotNull));
    test('Load double value',
        () => expect(p.getDouble('test.key.double'), isNotNull));
    test('Loaded double value parsed successfully',
        () => expect(p.getDouble('test.key.double'), equals(2.1)));

    test('Load a non int value as an int',
        () => expect(p.getInt('test.key.notinteger'), isNull));

    test('Load an int with default value',
        () => expect(p.getInt('test.key.integer.X', defval: 1), equals(1)));
    test(
        'Load an int with default key',
        () => expect(p.getInt('test.key.integer.X', defkey: 'test.key.integer'),
            equals(1)));

    test('Load a list', () => expect(p.getList('test.key.list'), isNotNull));
    test('Load a list',
        () => expect(p.getList('test.key.list').length, equals(4)));

    test(
        'Load a multiline property value',
        () => expect(p.get('test.key.multiline'),
            equals("this is a multi line property value")));

    test('Load true bool from true',
        () => expect(p.getBool('test.key.boolean.true'), equals(true)));
    test('Load false bool from false',
        () => expect(p.getBool('test.key.boolean.false'), equals(false)));

    test('Load true bool from TRUE',
        () => expect(p.getBool('test.key.boolean.TRUE'), equals(true)));
    test('Load false bool from FALSE',
        () => expect(p.getBool('test.key.boolean.FALSE'), equals(false)));

    test('Load true bool from 1',
        () => expect(p.getBool('test.key.boolean.1'), equals(true)));
    test('Load false bool from 0',
        () => expect(p.getBool('test.key.boolean.0'), equals(false)));

    test('Custom bool evaluator', () {
      BoolEvaluator myBE = MyBoolEvaluator();
      p.boolEvaluator = myBE;

      expect(p.get('test.key.boolean.yes'), equals("yes"));
      expect(p.get('test.key.boolean.no'), equals("no"));

      expect(p.getBool('test.key.boolean.yes'), equals(true));
      expect(p.getBool('test.key.boolean.no'), equals(false));
    });
  });

  group('Adding properties', () {
    late Properties p;
    setUp(() {
      p = Properties.fromFile(baseFile);
    });

    test('Add a property - valid, not existing', () {
      var singleAdd = p.add('test.key.3', 'value 3');
      expect(singleAdd, isTrue);
      expect(p.get('test.key.3'), equals('value 3'));
      expect(p.get('test.key.1'), equals('value 1'));
    });

    test('Add a property - valid, existing, overwrite', () {
      expect(p.get('test.key.1'), equals('value 1'));

      var singleAdd = p.add('test.key.1', 'value 1 new');

      expect(singleAdd, isTrue);
      expect(p.get('test.key.1'), equals('value 1 new'));
    });

    test('Add a property - valid, existing, do not overwrite', () {
      expect(p.get('test.key.1'), equals('value 1'));

      var singleAdd = p.add('test.key.1', 'value 1 new', false);

      expect(singleAdd, isFalse);
      expect(p.get('test.key.1'), equals('value 1'));
    });

    test('Add a property from Map', () {
      var map = {
        'first': 'partridge',
        'second': 'turtledoves',
        'fifth': 'golden rings'
      };
      p.mergeMap(map);
      expect(p.get('second'), equals('turtledoves'));
      expect(p.get('test.key.1'), equals('value 1'));
    });

    test('Add a property from JSON', () {
      p.mergeJSON('{"test.key.3":"value 3","test.key.4":"value 4"}');
      expect(p.get('test.key.4'), equals('value 4'));
      expect(p.get('test.key.1'), equals('value 1'));
    });
  });

  group('Events', () {
    late Properties p;
    setUp(() {
      p = Properties.fromFile(baseFile);
    });

    test('Add a property and listen to the event', () async {
      p.onAdd.listen(
        expectAsync1((AddEvent e) {
          expect(e.type, equals(Properties.ADD_PROPERTY_EVENTNAME));
          expect(e.key, equals("test.key.3"));
          expect(e.value, equals("value 3"));
        }),
      );

      final singleAdd = p.add('test.key.3', 'value 3');

      expect(singleAdd, isTrue);
      expect(p.get('test.key.3'), equals('value 3'));
    });

    test('Update a property and listen to the event', () {
      p.onUpdate.listen(expectAsync1((e) {
        expect(e.type, equals(Properties.UPDATE_PROPERTY_EVENTNAME));
        expect(e.key, equals("test.key.1"));
        expect(e.oldValue, equals("value 1"));
        expect(e.newValue, equals("value new 1"));
      }));

      var singleUpdate = p.add('test.key.1', 'value new 1');

      expect(singleUpdate, isTrue);
      expect(p.get('test.key.1'), equals('value new 1'));
    });

    test('Events disabled', () {
      // ignore: deprecated_member_use_from_same_package
      p.enableEvents = false;

      String eventType = '';
      String key = '';
      String value = '';

      p.onAdd.listen((AddEvent e) {
        eventType = e.type;
        key = e.key;
        value = e.value;
      });

      final singleAdd = p.add('test.key.3', 'value 3');

      expect(singleAdd, isTrue);
      expect(p.get('test.key.3'), equals('value 3'));
      expect(eventType, '');
      expect(key, '');
      expect(value, '');
    });
  });

  group('Export', () {
    late Properties p;
    setUp(() {
      p = Properties.fromFile(baseFile);
    });
    test(
        'To JSON',
        () => expect(p.toJSON(),
            '{"test.key.1":"value 1","test.key.2":"value 2","another.key":"another value"}'));
    test(
        'To JSON - prefix',
        () => expect(p.toJSON(prefix: "test"),
            '{"test.key.1":"value 1","test.key.2":"value 2"}'));
    test('To JSON - suffix',
        () => expect(p.toJSON(suffix: "1"), '{"test.key.1":"value 1"}'));
    test(
        'To JSON - prefix & suffix',
        () => expect(
            p.toJSON(prefix: "test", suffix: "2"), '{"test.key.2":"value 2"}'));
  });

  group('Merge', () {
    late Properties p;
    setUp(() {
      p = Properties.fromFile(baseFile);
    });
    test('Add brand new keys from map', () {
      p.mergeMap({
        "test.key.merge1": "merge value 1",
        "test.key.merge2": "merge value 2"
      });

      expect(p.size, equals(5));
      expect(p.get("test.key.merge1"), isNotNull);
      expect(p.get("test.key.merge1"), equals("merge value 1"));
      expect(p.get("test.key.merge2"), isNotNull);
      expect(p.get("test.key.merge2"), equals("merge value 2"));
    });

    test('Add an existing key from map', () {
      p.mergeMap({"test.key.1": "a new value for 1"});

      expect(p.get("test.key.1"), isNotNull);
      expect(p.get("test.key.1"), equals("a new value for 1"));
    });

    test('Add an existing key from map, do not overwrite', () {
      p.mergeMap({"test.key.1": "a new value for 1"}, false);

      expect(p.get("test.key.1"), isNotNull);
      expect(p.get("test.key.1"), equals("value 1"));
    });
  });

  group('Other', () {
    late Properties p;
    setUp(() {
      p = Properties.fromFile(baseFile);
    });
    test('Contains - matching', () => expect(p.contains('test.key.2'), isTrue));
    test('Contains - not matching',
        () => expect(p.contains('test.key.3'), isFalse));
    test('Every key - matching',
        () => expect(p.every((s) => s.startsWith('test')), isNotNull));
    test('Every key - matching',
        () => expect(p.every((s) => s.startsWith('test')), isNotEmpty));
    test('Every key - not matching', () {
      Properties? result = p.every((s) => s.startsWith('toast'));
      expect(result, isNull);
    });
    test('Every key & value - matching', () {
      Properties? m =
          p.every((s) => s.startsWith('test'), (v) => v == "value 1");

      expect(m, isNot(isEmpty));
      expect(m!.size, equals(1));
    });
  });
}

class MyBoolEvaluator extends BoolEvaluator {
  MyBoolEvaluator() {
    super.trues.add("yes");
    super.falses.add("no");
  }

  bool evaluate(String value) {
    return super.evaluate(value);
  }
}
