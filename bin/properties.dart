/**
 * A simple properties file management library.
 */
library properties;

import 'dart:io';

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
  String _source;
  
  /**
   * Create a new properties instance by naming the source file using [name]
   * and, optionally, setting the desired [encoding].
   */
  Properties(String name, [Encoding encoding = Encoding.UTF_8]){
    
    this._source = name;
    this._encoding = encoding;
    
    _init();
    
  }
  
  /**
   * Create a new properties instance from file [path]
   * and, optionally, setting the desired [encoding].
   */
  Properties.fromFile(String path, [Encoding encoding = Encoding.UTF_8]){
    
    this._source = path;
    this._encoding = encoding;
    
    _init();
    
  }
  
  void _init() => _load(_read(_source, _encoding));

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
  
  /** Loads the whole set of keys */
  Iterable<String> keys() => _content.keys;
  
  /** Loads the whole set of values */
  Collection<String> values() => _content.values;
  
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
   * Reloads the properties from file.
   */
  reload(){
    _content.clear();
    _init();
  }
  
  String toString(){
    return _content.toString();
  }
}