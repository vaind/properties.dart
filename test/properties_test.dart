import '../lib/properties.dart';
import '../packages/unittest/unittest.dart';

void main(){
  
  // ATTENTION: change paths
  String path = '/Users/kevin/Documents/workspace/properties/resources/sample.properties';
  String path2 = '/Users/kevin/Documents/workspace/properties/resources/sample-conversion.properties';
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
    test('Get keys', (){
      Iterable<String> i = p.keys;
      expect(i.length, 3);
    });
  });
  
  group('Getters - with default', () {
    Properties p;
    setUp(() {p = new Properties.fromFile(path);});
    
    test('Not existing key - default value', () => expect(p.get('test.key.X', defval:'value X'), isNotNull));
    test('Not existing key - default value', () => expect(p.get('test.key.X', defval:'value X'), equals('value X')));
    
    test('Not existing key - default key', () => expect(p.get('test.key.X', defkey:'test.key.1'), isNotNull));
    test('Not existing key - default key', () => expect(p.get('test.key.X', defkey:'test.key.1'), equals('value 1')));
    test('Not existing key - default key, not existing', () => expect(p.get('test.key.X', defkey:'test.key.Y'), isNull));
    
    test('Not existing key - default value & key', () => expect(p.get('test.key.X', defval:'value X', defkey:'test.key.1'), equals('value X')));
  });
  
  group('Getters - from JSON source', () {
    Properties p;
    setUp(() {p = new Properties.fromJSON(jsonSource);});
    test('Existing key - not null', () => expect(p.get('key.1'), isNotNull));
    test('Existing key - equals', () => expect(p.get('key.1'), equals('value 1')));
    test('Existing key - equals', () => expect(p.get('another.key'), equals('another value')));
    test('Not existing key', () => expect(p.get('not.existing'), isNull));
    test('Get keys', (){
      Iterable<String> i = p.keys;
      expect(i.length, 3);
    });
  });
  
  group('Getters - conversion', () {
    Properties p;
    setUp(() {p = new Properties.fromFile(path2);});
    test('Existing key - not null', () => expect(p.get('test.key.integer'), isNotNull));
    test('Existing key - not null', () => expect(p.getInt('test.key.integer'), isNotNull));
    test('Existing key - not null', () => expect(p.getInt('test.key.integer'), equals(1)));
    
    test('Existing key - not integer', () => expect(p.getInt('test.key.notinteger'), isNull));
    
    test('Existing key - not null - default value', () => expect(p.getInt('test.key.integer.X', defval:1), equals(1)));
    test('Existing key - not null - default key', () => expect(p.getInt('test.key.integer.X', defkey:'test.key.integer'), equals(1)));
    
    test('Existing key - list', () => expect(p.getList('test.key.list'), isNotNull));
    test('Existing key - list', () => expect(p.getList('test.key.list').length, equals(4)));
  });
  
  group('Adding properties', () {
    Properties p;
    setUp(() {p = new Properties.fromFile(path);});
    
    test('Add a property - not valid', (){
      var singleAdd = p.add(null, 'value 3');
      expect(singleAdd, isFalse);
    });
    
    test('Add a property - valid, not existing', (){
      var singleAdd = p.add('test.key.3', 'value 3');
      expect(singleAdd, isTrue);
      expect(p.get('test.key.3'), equals('value 3'));
      expect(p.get('test.key.1'), equals('value 1'));
    });
    
    test('Add a property - valid, existing, overwrite', (){
      
      expect(p.get('test.key.1'), equals('value 1'));
      
      var singleAdd = p.add('test.key.1', 'value 1 new');
      
      expect(singleAdd, isTrue);
      expect(p.get('test.key.1'), equals('value 1 new'));
    });
    
    test('Add a property - valid, existing, do not overwrite', (){
      
      expect(p.get('test.key.1'), equals('value 1'));
      
      var singleAdd = p.add('test.key.1', 'value 1 new', false);
      
      expect(singleAdd, isFalse);
      expect(p.get('test.key.1'), equals('value 1'));
    });
    
    test('Add a property from Map', () {
      var map = {
        'first'  : 'partridge',
        'second' : 'turtledoves',
        'fifth'  : 'golden rings'
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
    
    Properties p;
    setUp(() {p = new Properties.fromFile(path);});
    
    test('Add a property and listen to the event', () {
      
      String eventType = "";
      String key = "";
      String value = "";
      
      p.onAdd.listen((AddEvent e) {
        eventType = e.type;
        key = e.key;
        value = e.value;
      });
      
      var singleAdd = p.add('test.key.3', 'value 3');
      
      expect(singleAdd, isTrue);
      expect(p.get('test.key.3'), equals('value 3'));
      expect(eventType, equals(Properties.ADD_PROPERTY_EVENTNAME));
      expect(key, equals("test.key.3"));
      expect(value, equals("value 3"));
    });
    
    test('Update a property and listen to the event', () {
      
      String eventType = "";
      String key = "";
      String oldvalue = "";
      String newvalue = "";
      
      p.onUpdate.listen((UpdateEvent e) {
        eventType = e.type;
        key = e.key;
        oldvalue = e.oldValue;
        newvalue = e.newValue;
      });
      
      var singleUpdate = p.add('test.key.1', 'value new 1');
      
      expect(singleUpdate, isTrue);
      expect(p.get('test.key.1'), equals('value new 1'));
      expect(eventType, equals(Properties.UPDATE_PROPERTY_EVENTNAME));
      expect(key, equals("test.key.1"));
      expect(oldvalue, equals("value 1"));
      expect(newvalue, equals("value new 1"));
    });
    
    test('Events disabled', () {
      
      p.enableEvents = false;
      
      String eventType;
      String key;
      String value;
      
      p.onAdd.listen((AddEvent e) {
        eventType = e.type;
        key = e.key;
        value = e.value;
      });
      
      var singleAdd = p.add('test.key.3', 'value 3');
      
      expect(singleAdd, isTrue);
      expect(p.get('test.key.3'), equals('value 3'));
      expect(eventType, isNull);
      expect(key, isNull);
      expect(value, isNull);
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
    test('Every key - matching', () => expect(p.every((s) => s.startsWith('test')), isNotNull));
    test('Every key - matching', () => expect(p.every((s) => s.startsWith('test')), isNot(isEmpty)));
    test('Every key - not matching', () {
      Properties result = p.every((s) => s.startsWith('toast'));
      expect(result, isNull);
    });
    test('Every key & value - matching', () { 
      
     Properties m = p.every((s) => s.startsWith('test'), (v) => v == "value 1");
      
      expect(m, isNot(isEmpty));
      expect(m.size, equals(1));
    });
  });
}