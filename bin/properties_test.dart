import 'properties.dart';
import 'package:unittest/unittest.dart';

void main(){
  
  String path = '/Users/kevin/dart/properties/resources/sample.properties';
  
  group('Creation', () {
    test('Existing by path', () => expect(new Properties.fromFile(path), isNotNull));
    test('Existing by name', () => expect(new Properties(path), isNotNull));
    //test('Not existing by name', () => expect(new Properties('notexisting'), throwsException));
    //test('Not existing by name', () => expect(new Properties.fromFile('notexisting'), throwsException));
  });
  
  group('Getters', () {
    Properties p;
    setUp(() {p = new Properties.fromFile(path);});
    test('Existing key - not null', () => expect(p.get('test.key.1'), isNotNull));
    test('Existing key - equals', () => expect(p.get('test.key.1'), equals('value 1')));
    test('Not existing key', () => expect(p.get('not.existing'), isNull));
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