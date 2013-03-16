/**
 * A simple properties file management library.
 */
library properties;

import 'dart:io';
import 'dart:json' as JSON;
import 'dart:async';

/**
 * The Properties class implementing all tools to load key-values from file both by name and
 * path.
 */
class Properties {
  
  static final int SLASH = '\\'.charCodes[0];
  static final int SPACE = ' '.charCodes[0];
  static final int NEWLINE = '\n'.charCodes[0];
  static final int EQUAL = '='.charCodes[0];
  static final int HASH = '#'.charCodes[0];
  static final int ESCLMARK = '!'.charCodes[0];
  
  /// The content of the properties file in terms of key - value couples
  Map<String,String> _content;
  
  /// An internal reference to the source file.
  String _sourceFile;
  
  /// Events are enabled by default
  bool _enableEvents = true;
  
  /// Default bool evaluator instance
  BoolEvaluator _be = new BoolEvaluator();
  
  /// The property added event name
  static const String ADD_PROPERTY_EVENTNAME = 'add';
  static const String UPDATE_PROPERTY_EVENTNAME = 'update';
  
  StreamController eventController;
  
  /**
   * Create a new properties instance by naming the source file using [name].
   */
  Properties(String name){
    
    this._sourceFile = name;
    
    _init();
    
    _initFromFile();
    
  }
  
  /**
   * Create a new properties instance from file [path].
   */
  Properties.fromFile(String path){
    
    this._sourceFile = path;
    
    _init();
    
    _initFromFile();
    
  }
  
  /**
   * Create a new properties instance from the input [map].
   */
  Properties.fromMap(Map<String,String> map){
    
    this._content = map;
    
  }
  
  /**
   * Create a new properties instance using the input [jsonMap]
   * to load the data from.
   */
  Properties.fromJSON(String jsonMap){
    
    _init();
    
    _content = JSON.parse(jsonMap) as Map<String,String>;
  }

  /**
   * Initialize common internal tools such as event controllers.
   */
  _init() {
    eventController = new StreamController<PropertiesEvent>.broadcast();
  }
  
  void _initFromFile() => _load(_read(_sourceFile));

  /**
   * Create the file object and read its content in lines.
   */
  List<List<int>> _read(String path) {
    
    var f = _getFile(path);
    
    if(f == null || !f.existsSync())
      return null;
    
    // read file as bytes
    List<int> bytes = f.readAsBytesSync();
    
    // get line of bytes, managing multi-line properties
    return _manageMultiLine(_getLines(bytes));
  }
  
  /**
   * Get an array of lines of bytes out of the plain bytes.
   */
  List<List<int>> _getLines(List<int> bytes){
    List<List<int>> result = [];
    List<int> line = [];
    
    for(var i = 0; i < bytes.length; i++){
      
      if(bytes[i] != Properties.NEWLINE){
        line.add(bytes[i]);
      } else {
        result.add(line);
        line = [];
      }
      
      if(i == bytes.length -1)
        result.add(line);
      
    }
    
    return result;
  }

  /**
   * Merge multi-line values into a single line value.
   */
  List<List<int>> _manageMultiLine(List<List<int>> lines) {
    var result = [];
    var app = [];
    bool isMultiLine = false;
    bool added = false;
    
    for(List<int> l in lines){
      
      if(isMultiLine){
        app.addAll(_replaceLastOccurrence(l, Properties.SLASH, Properties.SPACE));
        added = true;
      }
      
      if(_endsWith(l, Properties.SLASH))
        isMultiLine = true;
      else {
        isMultiLine = false;
      }
      
      
      if(!isMultiLine){
        if(!app.isEmpty){
          result.add(app);
          app = [];
        } else {
          result.add(l);
        }
      }
      
      if(isMultiLine && !added){
        app.addAll(_replaceLastOccurrence(l, Properties.SLASH, Properties.SPACE));
      }
      
      added = false;
      
    }
    
    return result;
  }
  
  /**
   * Test if a [line] of bytes ends with the input [char] or not.
   */
  bool _endsWith(List<int> line, int char){
    return line.lastIndexOf(char) == (line.length -1);
  }

  /**
   * Replace the last occurrence of the input char [toReplace] into the input [line] of bytes
   * with the input char [replacer].
   */
  List<int> _replaceLastOccurrence(List<int> line, int toReplace, int replacer){
    List<int> result = [];
    bool replace = false;
    int limit = line.length;
    
    if(line.lastIndexOf(toReplace) == (line.length -1)){
      replace = true;
    }
    
    for(int i = 0; i < limit; i++){
      if(replace && (i == limit-1)){
        result.add(replacer);  
      } else {
        result.add(line[i]);
      }
    }
    
    return result;
  }
  

  /**
   * Load properties from lines.
   */
  _load(List<List<int>> lines) {
    if(lines == null || lines.isEmpty)
      return null;
    
    _content = new Map<String,String>();
    
    for(List<int> l in lines){
      if(_isProperty(l)){
        List<List<int>> splitted = _splitKeyValue(l);
        _content[new String.fromCharCodes(splitted[0]).trim()] = new String.fromCharCodes(splitted[1]).trim();
      }
    }
  }
  
  /**
   * Given a [line] of bytes split it into key and value.
   */
  List<List<int>> _splitKeyValue(List<int> line){
    
    List<List<int>> result = [];
    List<int> key = [];
    List<int> value = [];
    
    bool isKey = true;
    
    for(var i = 0; i < line.length; i++){
      
      if(line[i] == Properties.EQUAL && isKey){
        isKey = false;
      } else {
        if(isKey){
          key.add(line[i]);
        } else {
          value.add(line[i]);
        }
      }
    }
    
    result.add(key);
    result.add(value);
    
    return result;
  }

  /**
   * Determine if input line is a property or not.
   */
  _isProperty(List<int> line) {
    
    if(line.isEmpty || line == null)
      return false;
    
    if(_isComment(line))
      return false;
    
    // contains a non escaped =
    for(var i = 0; i < line.length; i++){
      if(line[i] == Properties.EQUAL && line[i-1] != Properties.SLASH){
        return true;
      }
    }
      
    return false;
  }
  
  /**
   * Determine if input line is a comment line.
   */
  _isComment(List<int> line){
    
    String lineStr = new String.fromCharCodes(line);
    
    // comment
    if(lineStr.startsWith('#'))
      return true;
    
    // comment
    if(lineStr.startsWith('!'))
      return true;
    
    return false;
  }
  
  /**
   * Get a file instance from the input string [file].
   */
  File _getFile(String file){
    
    var result = new File(file);
    
    if(result.existsSync())
      return result;
    
    result = new File.fromPath(new Path(file));
    
    if(result.existsSync())
      return result;
    
    throw new FileIOException('It\'s impossible to load properties from input file ${file}. File does not exist.');
  }
  
  /** 
   * Loads the value of a property given its [key].
   * Use [defval] to set a default value in case of missing property.
   * Use [defkey] to set a default key in case of missing property.
   */
  String get(String key, {Object defval, String defkey}) {
    if(!?key)
      return null;
    
    if(_content == null)
      return null;
    
    if(defval == null && defkey == null)
      return _content[key];
    
    if(_content[key] == null){
      if(defval != null)
        return defval.toString();
      
      if(defkey != null)
        return _content[defkey];
    }
    
    return _content[key];
  }
  
  /** 
   * Loads the value of a property as a bool given its [key].
   * Boolean value evaluation can be customized using by setting 
   * a new BoolEvaluator instance.
   * Use [defval] to set a default value in case of missing property.
   * Use [defkey] to set a default key in case of missing property.
   */
  bool getBool(String key, {bool throwException:false, int defval, String defkey}) {
    var value = get(key, defval:defval, defkey:defkey);
    if(value == null)
      return null;
    
    try {
      return _be.evaluate(value);
    } on FormatException catch (e) {
      if(throwException)
        throw e;
      return null;
    }
  }
  
  /** 
   * Loads the value of a property as an integer given its [key].
   * Use [defval] to set a default value in case of missing property.
   * Use [defkey] to set a default key in case of missing property.
   */
  int getInt(String key, {bool throwException:false, int defval, String defkey}) {
    
    var value = get(key, defval:defval, defkey:defkey);
    if(value == null)
      return null;
    
    try {
      return int.parse(value);
    } on FormatException catch (e) {
      if(throwException)
        throw e;
      return null;
    }
  }
  
  /** 
   * Loads the value of a property as a double given its [key].
   * Use [defval] to set a default value in case of missing property.
   * Use [defkey] to set a default key in case of missing property.
   */
  double getDouble(String key, {bool throwException:false, double defval, String defkey}) {
    
    String value = get(key, defval:defval, defkey:defkey);
    if(value == null)
      return null;
    
    try {
      return double.parse(value);
    } on FormatException catch (e) {
      if(throwException)
        throw e;
      return null;
    }
  }
  
  /**
   * Loads a list of strings for the input [key]. List elements must be
   * comma separated.
   */
  List<String> getList(String key){
    String value = get(key);
    if(value == null)
      return null;
    
    return value.split(",");
  }
  
  /** Check whether the properties contains a property given its [key] */
  bool contains(String key) => key != null ? _content != null ? _content.containsKey(key) : null : null;
  
  /** Rerturns the whole set of keys */
  Iterable<String> get keys => _content.keys;
  
  /** Returns the whole set of values */
  Collection<String> get values => _content.values;
  
  /** Returns the current number of properties */
  int get size => _content.length;
  
  /**
   * Add a property to the instance having name [key] and
   * value [value]. If the property already exists its value
   * will be replaced. Returns true if the property was
   * added successfully, false otherwise.
   * 
   * If and only if a new property is added an ADD event is
   * triggered.
   */
  bool add(String key, String value, [bool overwriteExisting = true]){
    if(key == null || value == null)
      return false;
    
    if(contains(key) && overwriteExisting){
      _update(key, value);
      return true;
    }
    
    
    if(!contains(key)){
      _add(key,value);
      return true;
    }
    
    return false;
  }

  /**
   * Internal add implementation, managing property storage and
   * event triggering.
   */
  _add(String key, String value) {
    _content[key] = value;
    
    if(this._enableEvents)
      eventController.add(new AddEvent(key, value));
  }

  /**
   * Internal update implementation, managing property storage and
   * event triggering.
   */
  _update(String key, String newvalue) {
    
    String oldvalue = _content[key];
    
    _content[key] = newvalue;
    
    if(this._enableEvents)
      eventController.add(new UpdateEvent(key, newvalue, oldvalue));
  }
  
  /**
   * Merge input [properties] content with the current instance's properties.
   * By defatult already existing properties will be overwritten. Anyway user
   * may decide how to manage existing thanks to the optional parameter [overwriteExisting].
   */
  void merge(Properties properties, [bool overwriteExisting = true]){
    for(String key in properties.keys){
      if(overwriteExisting || _content[key] == null){
        _content[key] = properties.get(key);
      }
    }
  }
  
  /**
   * Merge properties from the input [map] with the current instance's properties.
   * By defatult already existing properties will be overwritten. Anyway user
   * may decide how to manage existing thanks to the optional parameter [overwriteExisting].
   */
  void mergeMap(Map<String,String> map, [bool overwriteExisting = true]){
    for(String key in map.keys){
      if(overwriteExisting || _content[key] == null){
        _content[key] = map[key];
      }
    }
  }
  
  /**
   * Merge properties from the input [jsonMap] with the current instance's properties.
   * By defatult already existing properties will be overwritten. Anyway user
   * may decide how to manage existing thanks to the optional parameter [overwriteExisting].
   */
  void mergeJSON(String jsonMap, [bool overwriteExisting = true]){
    
    var parsed = JSON.parse(jsonMap) as Map<String,String>;
    
    for(String key in parsed.keys){
      if(overwriteExisting || _content[key] == null){
        _content[key] = parsed[key];
      }
    }
  }
  
  /**
   * Returns a Properties instance containg every property whos key satisifies the predicate [k] on the property key, and 
   * optionally the predicate [v] on the corresponding value. Returns null otherwise.
   */
  Properties every(bool k(String str), [bool v(String val)]) {
    
    Map<String,String> result = _every(k, v);
      
    if(result.isEmpty)
      return null;
    
    return new Properties.fromMap(result);
  }
  
  Map<String,String> _every(bool k(String str), [bool v(String val)]) {
    
    if(v == null) v = (String s) => true;
    
    var result = new Map<String,String>();
    for (String key in _content.keys)
      if (k(key) && v(get(key))) result[key] = get(key);
      
    return result;
  }

  
  /**
   * Reloads the properties from file. Works for file sources only.
   */
  reload(){
    if(_sourceFile == null)
      return;
    
    _content.clear();
    _initFromFile();
  }
  
  /**
   * Export the content as a JSON map. If no input parameter is set, then the whole set of
   * properties will be exporte as a JSON map. If the [prefix] parameter is set,
   * then only the keys starting with [prefix] will be exported. If the [suffix] parameter is set,
   * then only the keys starting with [suffix] will be exported. If both are set, then only the
   * keys matching both will be exported.
   */
  String toJSON({String prefix, String suffix}){
    
    var toExport = _content;
    
    if(?prefix && ?suffix)
      toExport = _every((key) => key.startsWith(prefix) && key.endsWith(suffix));
    else if(?prefix)
      toExport = _every((key) => key.startsWith(prefix));
    else if(?suffix)
      toExport = _every((key) => key.endsWith(suffix));
    
    return JSON.stringify(toExport);
  }
  
  /**
   * Returns the whole content as a String.
   */
  String toString() => _content.toString();
  
  /**
   * Getter for [enableEvents] flag.
   */
  bool get enableEvents => this._enableEvents;
  
  /**
   * Enable / disable events triggering on this instance.
   */
  set enableEvents(bool enable) => this._enableEvents = enable;
  
  /**
   * Get the stream instance for the "property added" event.
   */
  Stream get onAdd => eventController.stream;
  
  /**
   * Get the stream instance for the "property updated" event.
   */
  Stream get onUpdate => eventController.stream;
  
  /**
   * Getter for [boolEvaluator] instance.
   */
  BoolEvaluator get boolEvaluator => this._be;
  
  /**
   * Set an [evaluator] instance.
   */
  set boolEvaluator(BoolEvaluator evaluator) => this._be = evaluator;
}

/**
 * A factory to create simple Properties' related events.
 */
class PropertiesEvent<T extends Event> {
  final String _eventType;

  /**
   * Create a new event instance by name the [eventType] only.
   */
  const PropertiesEvent(this._eventType);
  
  /**
   * Getter fro the [eventType] of this event.
   */
  String get type => _eventType;
}

/**
 * A factory to create simple property added event.
 */
class AddEvent extends PropertiesEvent {

  final String _key;
  final String _value;
  
  /**
   * Create a new property added event instance by name the [eventType] and the property's [key] and [value].
   */
  const AddEvent(this._key, this._value):super(Properties.ADD_PROPERTY_EVENTNAME);
  
  /**
   * Getter for the added [key].
   */
  String get key => _key;
  
  /**
   * Getter for the added [value].
   */
  String get value => _value;
  

  String toString(){
    return "${Properties.ADD_PROPERTY_EVENTNAME} on ${this._key}: ${this._value}";
  }
}

/**
 * A factory to create simple property added event.
 */
class UpdateEvent extends PropertiesEvent {

  final String _key;
  final String _oldvalue;
  final String _newvalue;
  
  /**
   * Create a new property updated event instance by name the [eventType] and the property's [key] and [value].
   */
  const UpdateEvent(this._key, this._newvalue, this._oldvalue):super(Properties.UPDATE_PROPERTY_EVENTNAME);
  
  /**
   * Getter for the updated [key].
   */
  String get key => _key;
  
  /**
   * Getter for the updated [oldValue].
   */
  String get oldValue => _oldvalue;
  
  /**
   * Getter for the updated [newValue].
   */
  String get newValue => _newvalue;
  
  String toString(){
    return "${Properties.UPDATE_PROPERTY_EVENTNAME} on ${this._key}";
  }
}

/**
 * A default evaluator for bool values. Use evaluate method
 * to determine if the input value is true or false according to
 * the provided values.
 */
class BoolEvaluator {
  
  List<String> trues = ['true', 'TRUE', 'True', "1"];
  List<String> falses = ['false', 'FALSE', 'False', "0"];
  
  bool evaluate(String value){
    if(trues.contains(value)){
      return true;
    }
    
    if(falses.contains(value)){
      return false;
    }
    
    throw new FormatException("Input value is not a bool value.");
  }
  
}