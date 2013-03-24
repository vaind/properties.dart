part of properties;

/**
 * Layout manager for properties files.
 */
class PropertiesLayout {

  List<Line> _lines;

  PropertiesLayout(this._lines);

  /**
   * Append a new property. Event based.
   */
  void append(AddEvent event){

    _lines.add(new Line.fromKeyValue(event.key, event.value));

  }

  /**
   * Update an existing property. Event based.
   */
  void update(UpdateEvent event){
    
    for(Line l in _lines){
      if(l.keyString == event.key){
        l.value = event.newValue.codeUnits;
      }
    }
    
  }

  /**
   * Get a layout as a List of chars ready to be written to a file.
   */
  List<int> get layoutAsBytes {
    List<int> result = [];
    for(Line l in _lines){

      if(l.isMultiLineProperty()){

        result.addAll(l.key);
        result.add(Properties.SPACE);
        result.add(Properties.EQUAL);
        result.add(Properties.SPACE);

        for(List<int> ml in l.valueLines){
          result.addAll(ml);
          result.add(Properties.NEWLINE);
        }

      } else if(l.isProperty()) {

        result.addAll(l.key);
        result.add(Properties.SPACE);
        result.add(Properties.EQUAL);
        result.add(Properties.SPACE);
        result.addAll(l.value);
        result.add(Properties.NEWLINE);

      } else {
        result.addAll(l.key);
        result.add(Properties.NEWLINE);
      }
    }

    result.add(Properties.NEWLINE);

    return result;
  }
}