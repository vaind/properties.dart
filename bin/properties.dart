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
class Properties{
  
  /// The encoding used to read the file
  Encoding _encoding;
  
  /// The content of the properties file in terms of key - value couples
  Map<String,String> _content;
  
  /// An internal reference to the source file.
  String _sourceFile;
  
  static const String ADD_PROPERTY_EVENTNAME = 'add';
  StreamController addEventController;
  
  /**
   * Create a new properties instance by naming the source file using [name]
   * and, optionally, setting the desired [encoding].
   */
  Properties(String name, [Encoding encoding = Encoding.UTF_8]){
    
    this._sourceFile = name;
    this._encoding = encoding;
    
    _init();
    
    _initFromFile();
    
  }
  
  /**
   * Create a new properties instance from file [path]
   * and, optionally, setting the desired [encoding].
   */
  Properties.fromFile(String path, [Encoding encoding = Encoding.UTF_8]){
    
    this._sourceFile = path;
    this._encoding = encoding;
    
    _init();
    
    _initFromFile();
    
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
    addEventController = new StreamController<PropertiesEvent>.broadcast();
  }
  
  void _initFromFile() => _load(_read(_sourceFile, _encoding));

  /**
   * Create the file object and read its content in lines.
   */
  List<String> _read(String path, Encoding encoding) {
    
    var f = _getFile(path);
    
    if(f == null || !f.existsSync())
      return null;
    
    return f.readAsLinesSync(this._encoding);
  }

  /**
   * Load properties from lines.
   */
  _load(List<String> lines) {
    if(lines == null || lines.isEmpty)
      return null;
    
    _content = new Map<String,String>();
    
    for(String line in lines){
      
      line = line.trim();
      
      if(_isProperty(line)){
        List<String> keyvalue = line.split('=');
        
        if(keyvalue.length == 2 && keyvalue[0] != null)
          _content[keyvalue[0].trim()] = keyvalue[1].trim();
      }
    }
  }

  /**
   * Determine if input line is a property or not.
   */
  _isProperty(String line) {
    
    if(line.isEmpty || line == null)
      return false;
    
    if(line.startsWith('#'))
      return false;
    
    if(line.contains('='))
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
  
  /** Loads the value of a property given its [key] */
  String get(String key) => key != null ? _content != null ? _content[key] : null : null;
  
  /** Check whether the properties contains a property given its [key] */
  bool contains(String key) => key != null ? _content != null ? _content.containsKey(key) : null : null;
  
  /** Rerturns the whole set of keys */
  Iterable<String> get keys => _content.keys;
  
  /** Returns the whole set of values */
  Collection<String> get values => _content.values;
  
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
    
    if(overwriteExisting || _content[key] == null){
      _content[key] = value;
      addEventController.add(new AddEvent(key, value));
      return true;
    }
    
    return false;
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
   * Returns a map containg every property whos key satisifies the predicate [k] on the property key, and 
   * optionally the predicate [v] on the corresponding value. Returns an empty map otherwise.
   */
  Map<String,String> every(bool k(String str), [bool v(String val)]) {
    
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
      toExport = every((key) => key.startsWith(prefix) && key.endsWith(suffix));
    else if(?prefix)
      toExport = every((key) => key.startsWith(prefix));
    else if(?suffix)
      toExport = every((key) => key.endsWith(suffix));
    
    return JSON.stringify(toExport);
  }
  
  /**
   * Returns the whole content as a String.
   */
  String toString() => _content.toString();
  
  /**
   * Get the stream instance for the "add property" event.
   */
  Stream get onAdd => addEventController.stream;
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
}