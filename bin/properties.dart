/**
 * A simple properties file management library.
 */
library properties;

import 'dart:io';
import 'dart:json' as JSON;

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
  
  /**
   * Create a new properties instance by naming the source file using [name]
   * and, optionally, setting the desired [encoding].
   */
  Properties(String name, [Encoding encoding = Encoding.UTF_8]){
    
    this._sourceFile = name;
    this._encoding = encoding;
    
    _initFromFile();
    
  }
  
  /**
   * Create a new properties instance from file [path]
   * and, optionally, setting the desired [encoding].
   */
  Properties.fromFile(String path, [Encoding encoding = Encoding.UTF_8]){
    
    this._sourceFile = path;
    this._encoding = encoding;
    
    _initFromFile();
    
  }
  
  /**
   * Create a new properties instance using the input [jsonMap]
   * to load the data from.
   */
  Properties.fromJSON(String jsonMap){
    _content = JSON.parse(jsonMap) as Map<String,String>;
  }
  
  void _initFromFile() => _load(_read(_sourceFile, _encoding));

  /**
   * Create the file object and read its content in lines.
   */
  List<String> _read(String path, Encoding encoding) {
    
    File f = _getFile(path);
    
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
    
    File result;
    
    result = new File(file);
    
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
   */
  bool add(String key, String value){
    if(key != null && value != null){
      _content[key] = value;
      return true;
    }
    
    return false;
  }
  
  /**
   * Add properties from the input Properties instance to the current instance's properties.
   * If some properties already exist, its value will be replaced.
   */
  void addFromProperties(Properties p){
    for(String key in p.keys)
      _content[key] = p.get(key);
  }
  
  /**
   * Add properties from the input [map] object to the current instance's properties.
   * If some properties already exist, its value will be replaced.
   */
  void addFromMap(Map<String,String> map){
    for(String key in map.keys)
      _content[key] = map[key];
  }
  
  /**
   * Add properties from the input JSON map to the current instance's properties.
   * If some properties already exist, its value will be replaced.
   */
  void addFromJSON(String jsonMap){
    Map parsed = JSON.parse(jsonMap) as Map<String,String>;
    for(String key in parsed.keys)
      _content[key] = parsed[key];
  }
  
  /**
   * Returns a map containg every property whos key satisify the predicate f. Returns an empty map otherwise.
   */
  Map<String,String> everyKey(bool f(String s)) {
    Map result = new Map<String,String>();
    for (String key in _content.keys)
      if (f(key)) result[key] = get(key);
      
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
    
    Map toExport = _content;
    
    if(?prefix && ?suffix)
      toExport = everyKey((key) => key.startsWith(prefix) && key.endsWith(suffix));
    else if(?prefix)
      toExport = everyKey((key) => key.startsWith(prefix));
    else if(?suffix)
      toExport = everyKey((key) => key.endsWith(suffix));
    
    return JSON.stringify(toExport);
  }
  
  /**
   * Returns the whole content as a String.
   */
  String toString() => _content.toString();
}