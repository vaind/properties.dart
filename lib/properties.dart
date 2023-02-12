/// A simple properties file management library.
library properties;

import 'dart:convert';
import 'dart:io';
import 'dart:async';

part 'src/properties_events.dart';
part 'src/properties_parser.dart';
part 'src/properties_layout_management.dart';

/// The Properties class implementing all tools to load key-values from file both by name and
/// path. Input files are supposed to be in UTF-8 format.
class Properties {
  static final int BACKSLASH = r'\'.codeUnits[0];
  static final int SLASH = '/'.codeUnits[0];
  static final int SPACE = ' '.codeUnits[0];
  static final int NEWLINE = '\n'.codeUnits[0];
  static final int CR = '\r'.codeUnits[0];
  static final int EQUAL = '='.codeUnits[0];

  /// The content of the properties file in terms of key - value couples
  late Map<String, String?> _content;

  /// Layout manager
  PropertiesLayout? _layout;

  /// An internal reference to the source file.
  String? _sourceFile;

  /// An internal reference to the String value.
  String? _stringValue;

  /// Events are enabled by default
  bool _enableEvents = true;

  /// Default bool evaluator instance
  BoolEvaluator _be = BoolEvaluator();

  /// The property added event name
  static const String ADD_PROPERTY_EVENTNAME = 'add';

  /// The property updated event name
  static const String UPDATE_PROPERTY_EVENTNAME = 'update';

  /// Controller for Add events
  late final _addEventController = StreamController<AddEvent>.broadcast();

  /// Controller for Update events
  late final _updateEventController = StreamController<UpdateEvent>.broadcast();

  /// Create a new properties instance by naming the source file using [name].
  Properties(String name) {
    this._sourceFile = name;

    _initFromFile();
  }

  /// Create a new properties instance from file [path].
  Properties.fromFile(String path) {
    this._sourceFile = path;

    _initFromFile();
  }

  /// Create a new properties instance from String.
  Properties.fromString(String value) {
    this._stringValue = value;
    _initFromString();
  }

  /// Create a new properties instance from the input [map].
  Properties.fromMap(Map<String, String?> map) {
    this._content = map;
  }

  /// Create a new properties instance using the input [jsonMap]
  /// to load the data from.
  Properties.fromJSON(String jsonMap) {
    _content = Map.from(json.decode(jsonMap));
  }

  /// Read from file and load the content.
  void _initFromFile() {
    final parser = PropertiesFileParser(_getFile(_sourceFile!));
    _content = parser.parse();

    // init layout
    _layout = PropertiesLayout(parser.lines);
    onAdd.listen(_layout!.append);
    onUpdate.listen(_layout!.update);
  }

  /// Load the contents from string.
  void _initFromString() {
    final parser = PropertiesStringParser(_stringValue!);
    _content = parser.parse();

    // init layout
    _layout = PropertiesLayout(parser.lines);
    onAdd.listen(_layout!.append);
    onUpdate.listen(_layout!.update);
  }

  /// Get a file instance from the input string [file].
  File _getFile(String file) {
    final result = File(file);

    if (result.existsSync()) {
      return result;
    }

    if (result.existsSync()) {
      return result;
    }

    throw Exception(
        'It\'s impossible to load properties from input file ${file}. File does not exist.');
  }

  /// Loads the value of a property given its [key].
  /// Use [defval] to set a default value in case of missing property.
  /// Use [defkey] to set a default key in case of missing property.
  String? get(String key, {Object? defval, String? defkey}) {
    if (defval == null && defkey == null) {
      return _content[key];
    }

    if (_content[key] == null) {
      if (defval != null) {
        return defval.toString();
      }

      if (defkey != null) {
        return _content[defkey];
      }
    }

    return _content[key];
  }

  /// Returns the value for the given [key] or null if [key] is not
  /// in the map. No default will be applied.
  String? operator [](String key) {
    return get(key);
  }

  /// Associates the [key] with the given [value]. This method
  /// adds a new property if the input one does not exists or
  /// updates the existing one.
  ///
  /// Events are triggered as for the add method.
  void operator []=(String key, String value) {
    add(key, value);
  }

  /// Loads the value of a property as a bool given its [key].
  /// Boolean value evaluation can be customized using by setting
  /// a new BoolEvaluator instance.
  /// Use [defval] to set a default value in case of missing property.
  /// Use [defkey] to set a default key in case of missing property.
  bool? getBool(
    String key, {
    bool throwException = false,
    int? defval,
    String? defkey,
  }) {
    var value = get(key, defval: defval, defkey: defkey);
    if (value == null) {
      return null;
    }

    try {
      return _be.evaluate(value);
    } on FormatException catch (e) {
      if (throwException) {
        throw e;
      }
      return null;
    }
  }

  /// Loads the value of a property as an integer given its [key].
  /// Use [defval] to set a default value in case of missing property.
  /// Use [defkey] to set a default key in case of missing property.
  int? getInt(
    String key, {
    bool throwException = false,
    int? defval,
    String? defkey,
  }) {
    var value = get(key, defval: defval, defkey: defkey);
    if (value == null) {
      return null;
    }

    try {
      return int.parse(value);
    } on FormatException catch (e) {
      if (throwException) {
        throw e;
      }
      return null;
    }
  }

  /// Loads the value of a property as a double given its [key].
  /// Use [defval] to set a default value in case of missing property.
  /// Use [defkey] to set a default key in case of missing property.
  double? getDouble(
    String key, {
    bool throwException = false,
    double? defval,
    String? defkey,
  }) {
    final value = get(key, defval: defval, defkey: defkey);
    if (value == null) {
      return null;
    }

    try {
      return double.parse(value);
    } on FormatException catch (e) {
      if (throwException) {
        throw e;
      }
      return null;
    }
  }

  /// Loads a list of strings for the input [key]. List elements must be
  /// comma separated.
  List<String> getList(String key) {
    final value = get(key);
    if (value == null) {
      return [];
    }

    return value.split(",");
  }

  /// Check whether the properties contains a property given its [key]
  bool contains(String key) {
    return _content.containsKey(key);
  }

  /// Rerturns the whole set of keys
  List<String> get keys => _content.keys.toList();

  /// Returns the whole set of values
  List<String?> get values => _content.values.toList();

  /// Returns the current number of properties
  int get size => _content.length;

  /// Add a property to the instance having name [key] and
  /// value [value]. If the property already exists its value
  /// will be replaced. Returns true if the property was
  /// added successfully, false otherwise.
  ///
  /// If and only if a new property is added an ADD event is
  /// triggered.
  ///
  /// If and only if an existing property is overwritten an UPDATE
  /// event is triggered.
  bool add(String key, String value, [bool overwriteExisting = true]) {
    if (contains(key) && overwriteExisting) {
      _update(key, value);
      return true;
    }

    if (!contains(key)) {
      _add(key, value);
      return true;
    }

    return false;
  }

  /// Internal add implementation, managing property storage and
  /// event triggering.
  _add(String key, String value) {
    _content[key] = value;

    if (this._enableEvents) {
      _addEventController.add(AddEvent(key, value));
    }
  }

  /// Internal update implementation, managing property storage and
  /// event triggering.
  _update(String key, String? newvalue) {
    String? oldvalue = _content[key];

    _content[key] = newvalue;

    if (this._enableEvents) {
      _updateEventController.add(UpdateEvent(key, newvalue, oldvalue));
    }
  }

  /// Merge input [properties] content with the current instance's properties.
  /// By defatult already existing properties will be overwritten. Anyway user
  /// may decide how to manage existing thanks to the optional parameter [overwriteExisting].
  void merge(Properties properties, [bool overwriteExisting = true]) {
    for (String key in properties.keys) {
      final value = properties.get(key);
      if (overwriteExisting) {
        _content[key] = value;
      } else {
        _content.putIfAbsent(key, () => value);
      }
    }
  }

  /// Merge properties from the input [map] with the current instance's properties.
  /// By defatult already existing properties will be overwritten. Anyway user
  /// may decide how to manage existing thanks to the optional parameter [overwriteExisting].
  void mergeMap(Map<String, String?> map, [bool overwriteExisting = true]) {
    _merge(map, overwriteExisting);
  }

  /// Merge properties from the input [jsonMap] with the current instance's properties.
  /// By defatult already existing properties will be overwritten. Anyway user
  /// may decide how to manage existing thanks to the optional parameter [overwriteExisting].
  void mergeJSON(String jsonMap, [bool overwriteExisting = true]) {
    final parsed = Map<String, String>.from(json.decode(jsonMap));

    _merge(parsed, overwriteExisting);
  }

  /// Internal merge implementation.
  void _merge(Map<String, String?> map, [bool overwriteExisting = true]) {
    for (String key in map.keys) {
      if (overwriteExisting) {
        _content[key] = map[key];
      } else {
        _content.putIfAbsent(key, () => map[key] ?? '');
      }
    }
  }

  /// Returns a Properties instance containg every property whose key satisifies the predicate [k] on the property key, and
  /// optionally the predicate [v] on the corresponding value. Returns null otherwise.
  Properties? every(bool k(String str), [bool v(String? val)?]) {
    Map<String, String?> result = _every(k, v);

    if (result.isEmpty) {
      return null;
    }

    return Properties.fromMap(result);
  }

  /// Internal every implementation.
  Map<String, String?> _every(bool k(String str), [bool v(String? val)?]) {
    if (v == null) v = (String? s) => true;

    final result = Map<String, String?>();

    for (String key in _content.keys)
      if (k(key) && v(get(key))) result[key] = get(key);

    return result;
  }

  /// Reloads the properties from file. Works for file sources only.
  reload() {
    if (_sourceFile == null) {
      return;
    }

    _content.clear();
    _initFromFile();
  }

  /// Export the content as a JSON map. If no input parameter is set, then the whole set of
  /// properties will be exporte as a JSON map. If the [prefix] parameter is set,
  /// then only the keys starting with [prefix] will be exported. If the [suffix] parameter is set,
  /// then only the keys starting with [suffix] will be exported. If both are set, then only the
  /// keys matching both will be exported.
  String toJSON({String? prefix, String? suffix}) {
    var toExport = _content;

    if (prefix != null && suffix != null) {
      toExport =
          _every((key) => key.startsWith(prefix) && key.endsWith(suffix));
    } else if (prefix != null) {
      toExport = _every((key) => key.startsWith(prefix));
    } else if (suffix != null) {
      toExport = _every((key) => key.endsWith(suffix));
    }

    return json.encode(toExport);
  }

  /// Write the content to the input file.
  void toFile(String path) {
    final result = File(path);

    if (!result.existsSync()) result.createSync();

    // It may throw error since _layout can be null if file is not used.
    result.openWrite().writeAll(this._layout!.layoutAsBytes);
  }

  /// Returns the whole content as a String.
  String toString() => _content.toString();

  /// Getter for [enableEvents] flag.
  @deprecated
  bool get enableEvents => this._enableEvents;

  /// Enable / disable events triggering on this instance.
  @deprecated
  set enableEvents(bool enable) => this._enableEvents = enable;

  /// Get the stream instance for the "property added" event.
  Stream<AddEvent> get onAdd => _addEventController.stream;

  /// Get the stream instance for the "property updated" event.
  Stream<UpdateEvent> get onUpdate => _updateEventController.stream;

  /// Getter for [boolEvaluator] instance.
  BoolEvaluator get boolEvaluator => this._be;

  /// Set an [evaluator] instance.
  set boolEvaluator(BoolEvaluator evaluator) => this._be = evaluator;

  /// Whether there is no key/value pair in the map.
  bool get isEmpty => _content.isEmpty;

  /// Whether there is at least one key/value pair in the map.
  bool get isNotEmpty => _content.isNotEmpty;
}

/// A default evaluator for bool values. Use evaluate method
/// to determine if the input value is true or false according to
/// the provided values.
class BoolEvaluator {
  List<String> trues = ['true', 'TRUE', 'True', "1"];
  List<String> falses = ['false', 'FALSE', 'False', "0"];

  /// Evaluate the input [value] String trying to determine
  /// whether it is true or false. Throws an exception otherwise.
  bool evaluate(String value) {
    if (trues.contains(value)) {
      return true;
    }

    if (falses.contains(value)) {
      return false;
    }

    throw FormatException("Input value is not a bool value.");
  }
}
