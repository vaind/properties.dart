part of properties;

/**
 * Parser for properties files. Input files are supposed to be UTF-8 encoded.
 */
class PropertiesFileParser {
  
  File _file;
  List<Line> _lines;
  
  PropertiesFileParser(this._file);
  
  Map<String,String> parse(){
    _lines = _getLines(_read(_file));
    return _load(_lines);
  }
  
  List<Line> get lines => _lines;
  
  /**
   * Create the file object and read its content in lines.
   */
  List<List<int>> _read(File f) {

    if(f == null || !f.existsSync()){
      return null;
    }

    // read file as bytes
    List<int> bytes = f.readAsBytesSync();

    // get line of bytes, managing multi-line properties
    return _getByteLines(bytes);
  }

  /**
   * Get an array of lines of bytes out of the plain bytes.
   */
  List<List<int>> _getByteLines(List<int> bytes){
    List<List<int>> result = [];
    List<int> line = [];

    for(var i = 0; i < bytes.length; i++){

      if(bytes[i] != Properties.NEWLINE && bytes[i] != Properties.CR){
        line.add(bytes[i]);
      } else {
        if(!line.isEmpty){
          result.add(line);
          line = [];
        }
      }

      if(i == bytes.length -1){
        result.add(line);
      }

    }

    return result;
  }

  /**
   * Get a list of Line objects out of a List of
   * [byteLines].
   */
  List<Line> _getLines(List<List<int>> byteLines) {

    List<Line> result = [];
    bool multi = false;

    for(List<int> byteLine in byteLines){

      if(!multi){
        result.add(new Line(byteLine));

        // current line is a multiline property
        // having its value split on more than one line
        result.last.isMultiLineProperty() ? multi = true : multi = false;

      } else {

        multi = result.last.addValueLine(byteLine);

      }
    }

    return result;
  }

  /**
   * Load properties from lines.
   */
  Map<String,String> _load(List<Line> lines) {
    if(lines == null || lines.isEmpty){
      return null;
    }

    var content = new Map<String,String>();

    for(Line line in lines){
      if(line.isProperty()){
        content[line.keyString] = line.valueString;
      }
    }
    
    return content;
  }
}


/**
 * This helper class models a line as it has been read from
 * the source file, providing and hiding some useful tools needed
 * to manage properties parsing.
 */
class Line {


  List<int> _key = [], _value = [];
  List<List<int>> _valuelines = [];

  bool _property, _multiline, _comment = false;

  /**
   * Create a new line from an input list of bytes representing
   * a line from the file (without NL).
   */
  Line(List<int> bytes){
    _init(bytes);
  }

  Line.fromString(String line){
    _init(line.codeUnits);
  }

  Line.fromKeyValue(String key, String value){

    this._key = key.codeUnits;
    this._value = value.codeUnits;
    this._valuelines = [[value.codeUnits]];

    this._property = true;
    this._comment = false;
    this._multiline = false;

  }

  void _init(List<int> bytes){

    _property = _isProperty(bytes);
    _comment = _isComment(bytes);
    _multiline = _isMultiLineProperty(bytes);

    if(_property){
        List<List<int>> keyvalue = _splitKeyValue(bytes);

        _key = keyvalue[0];

        if(_multiline){
          _valuelines.add(keyvalue[1]);
          _value.addAll(_removeMultiLine(keyvalue[1]));
        } else {
          _valuelines.add(keyvalue[1]);
          _value = keyvalue[1];
        }

    } else {
      _key = _value = bytes;
    }
  }

  /**
   * This line is a property line?
   */
  bool isProperty() => _property;

  /**
   * This line is a property line having a multi line value?
   */
  bool isMultiLineProperty() => _multiline;

  /**
   * This line is a comment line?
   */
  bool isComment() => _comment;

  /**
   * Getter for the key contained in this property, if any.
   */
  List<int> get key => _key;

  /**
   * Getter for the value contained in this property, if any.
   */
  List<int> get value => _value;
  
  /**
   * Set the value for this property.
   */
  set value(List<int> newValue){
    this._value = newValue;
    this._valuelines = [newValue];
  }

  /**
   * Getter for the lines composing the value of this property, if any.
   */
  List<List<int>> get valueLines => _valuelines;

  /**
   * Get the key as a String.
   */
  String get keyString => new String.fromCharCodes(_key).trim();

  /**
   * Get the value as a String.
   */
  String get valueString => decodeUtf8(_value).trim();

  /**
   * Add a value line to the value of this property.
   */
  bool addValueLine(List<int> valueline){
      _valuelines.add(valueline);
      _value.addAll(this._removeMultiLine(valueline));

      // has next?
      return _endsWith(valueline, Properties.BACKSLASH);
  }

  /**
   * Test if a [line] of bytes ends with the input [char] or not.
   */
  bool _endsWith(List<int> line, int char){
    return line.lastIndexOf(char) == (line.length -1) && (line[line.length-2] != Properties.SLASH);
  }

  /**
   * Given a [line] of bytes split it into key and value.
   */
  List<List<int>> _splitKeyValue(List<int> line){

    var result = new List<List<int>>(2);
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

    result[0] = key;
    result[1] = value;

    return result;
  }

  /**
   * Determine if input line is a property or not.
   */
  _isProperty(List<int> line) {

    if(line.isEmpty || line == null) {
      return false;
    }

    if(_isComment(line)) {
      return false;
    }

    // contains a non escaped =
    for(var i = 0; i < line.length; i++){
      if(line[i] == Properties.EQUAL && line[i-1] != Properties.BACKSLASH){
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
    if(lineStr.startsWith('#')) {
      return true;
    }

    // comment
    if(lineStr.startsWith('!')) {
      return true;
    }

    return false;
  }

  /**
   * Test if this is a multi line property. This means it has to be a property
   * whos value ends with backslash (not escaped).
   */
  bool _isMultiLineProperty(List<int> _bytes) {
    return _isProperty(_bytes) && _endsWith(_bytes, Properties.BACKSLASH);
  }

  /**
   * Replace the last occurrence of the input char [toReplace] into the input [line] of bytes
   * with the input char [replacer].
   */
  List<int> _removeMultiLine(List<int> line){
    List<int> result = [];
    bool replace = false;
    int limit = line.length;

    replace = _endsWith(line, Properties.BACKSLASH);

    for(int i = 0; i < limit; i++){
      if(replace && (i == limit-1)){
        result.add(Properties.SPACE);
      } else {
        result.add(line[i]);
      }
    }

    return result;
  }

  /**
   * The line to string.
   */
  String toString(){
    if(this.isComment()) {
      return "${this.keyString}";
    } else {
      return "${this.keyString} = ${this.valueString}";
    }
  }
}