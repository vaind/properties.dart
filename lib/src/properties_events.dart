part of properties;

/// All property related event types.
enum EventType {
  /// Property added event.
  add,

  /// Property updated event.
  update,

  /// Property deleted event.
  delete,
}

/// A factory to create simple Properties' related events.
class ChangeEvent {
  final EventType _eventType;

  /// Create a new event instance by name the [eventType] only.
  const ChangeEvent(this._eventType);

  /// Getter fro the [eventType] of this event.
  EventType get type => _eventType;
}

/// A factory to create simple property added event.
class AddEvent extends ChangeEvent {
  final String _key;
  final String _value;

  /// Create a new property added event instance by name the [eventType] and the property's [key] and [value].
  const AddEvent(this._key, this._value) : super(EventType.add);

  /// Getter for the added [key].
  String get key => _key;

  /// Getter for the added [value].
  String get value => _value;

  String toString() {
    return "${EventType.add} on ${this._key}: ${this._value}";
  }
}

/// A factory to create simple property added event.
class UpdateEvent extends ChangeEvent {
  final String _key;
  final String? _oldValue;
  final String? _newValue;

  /// Create a new property updated event instance by name the [eventType] and the property's [key] and [value].
  const UpdateEvent(this._key, this._newValue, this._oldValue)
      : super(EventType.update);

  /// Getter for the updated [key].
  String get key => _key;

  /// Getter for the updated [oldValue].
  String? get oldValue => _oldValue;

  /// Getter for the updated [newValue].
  String? get newValue => _newValue;

  String toString() {
    return "${EventType.update} on ${this._key}";
  }
}

/// A factory to create simple property deleted event.
class DeleteEvent extends ChangeEvent {
  final String _key;

  /// Creates a new property deleted event instance by name the [eventType] and the property's [key].
  const DeleteEvent(this._key) : super(EventType.delete);

  /// Getter for the added [key].
  String get key => _key;

  String toString() {
    return "${EventType.delete} on ${this._key}";
  }
}
