import 'properties.dart';
import 'package:unittest/unittest.dart';

void main(){
  
  String path = '/Users/kevin/dart/properties/resources/sample.properties';
  String jsonSource = '{"key.1" : "value 1", "key.2" : "value 2", "another.key" : "another value"}';
  
  group('Creation - from properties file', () {
    test('Existing by path', () => expect(new Properties.fromFile(path), isNotNull));
    test('Existing by name', () => expect(new Properties(path), isNotNull));
    //test('Not existing by name', () => expect(new Properties('notexisting'), throwsException));
    //test('Not existing by name', () => expect(new Properties.fromFile('notexisting'), throwsException));
  });
  
  group('Creation - from JSON string', () {
    test('JSON map input', () => expect(new Properties.fromJSON(jsonSource), isNotNull));
  });
  
  group('Getters - from file source', () {
    Properties p;
    setUp(() {p = new Properties.fromFile(path);});
    test('Existing key - not null', () => expect(p.get('test.key.1'), isNotNull));
    test('Existing key - equals', () => expect(p.get('test.key.1'), equals('value 1')));
    test('Not existing key', () => expect(p.get('not.existing'), isNull));
  });
  
  group('Getters - from JSON source', () {
    Properties p;
    setUp(() {p = new Properties.fromJSON(jsonSource);});
    test('Existing key - not null', () => expect(p.get('key.1'), isNotNull));
    test('Existing key - equals', () => expect(p.get('key.1'), equals('value 1')));
    test('Existing key - equals', () => expect(p.get('another.key'), equals('another value')));
    test('Not existing key', () => expect(p.get('not.existing'), isNull));
  });
  
  group('Adding properties', () {
    Properties p;
    setUp(() {p = new Properties.fromFile(path);});
    
    test('Add a property - valid', (){
      var singleAdd = p.add('test.key.3', 'value 3');
      expect(singleAdd, isTrue);
      expect(p.get('test.key.3'), equals('value 3'));
      expect(p.get('test.key.1'), equals('value 1'));
    });
    
    test('Add a property from Map', () {
      var map = {
        'first'  : 'partridge',
        'second' : 'turtledoves',
        'fifth'  : 'golden rings'
      };
      p.addFromMap(map);
      expect(p.get('second'), equals('turtledoves'));
      expect(p.get('test.key.1'), equals('value 1'));
    });
    
    test('Add a property from JSON', () {
      p.addFromJSON('{"test.key.3":"value 3","test.key.4":"value 4"}');
      expect(p.get('test.key.4'), equals('value 4'));
      expect(p.get('test.key.1'), equals('value 1'));
    });
  });
  
  group('Export', () {
    Properties p;
    setUp(() {p = new Properties.fromFile(path);});
    test('To JSON', () => expect(p.toJSON(), '{"test.key.1":"value 1","test.key.2":"value 2","another.key":"another value"}'));
    test('To JSON - prefix', () => expect(p.toJSON(prefix:"test"), '{"test.key.1":"value 1","test.key.2":"value 2"}'));
    test('To JSON - suffix', () => expect(p.toJSON(suffix:"1"), '{"test.key.1":"value 1"}'));
    test('To JSON - prefix & suffix', () => expect(p.toJSON(prefix:"test", suffix:"2"), '{"test.key.2":"value 2"}'));
  });
  
  group('Other', () {
    Properties p;
    setUp(() {p = new Properties.fromFile(path);});
    test('Contains - matching', () => expect(p.contains('test.key.2'), isTrue));
    test('Contains - not matching', () => expect(p.contains('test.key.3'), isFalse));
    test('Every key - matching', () => expect(p.everyKey((s) => s.startsWith('test')), isNotNull));
    test('Every key - matching', () => expect(p.everyKey((s) => s.startsWith('test')), isNot(isEmpty)));
    test('Every key - not matching', () => expect(p.everyKey((s) => s.startsWith('toast')), isEmpty));
  });
}