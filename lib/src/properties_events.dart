part of properties;

/**
 * A factory to create simple Properties' related events.
 */
class PropertiesEvent {
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