import 'package:flutter/cupertino.dart';

class DependRelationship<T> {
  T value;
  ValueGetter<T> getter;

  bool updateShouldNotifyDependent() {
    var oldValue = this.value;
    var newValue = getter();
    this.value = newValue;
    if (newValue != oldValue) {
      if (handler != null) {
        return handler!(oldValue, newValue);
      }
      return true;
    }
    return false;
  }

  bool Function(T oldValue, T newValue)? handler;

  DependRelationship(this.getter, {this.handler}) : this.value = getter();

  bool isValueChanged() => value != getter();
}

typedef OnChange<T> = void Function(T oldValue, T newValue);

class StrongDependRelationship<T> extends DependRelationship<T> {
  StrongDependRelationship(ValueGetter<T> getter, {OnChange<T>? onChange})
      : super(
          getter,
          handler: (oldValue, newValue) {
            if (onChange != null) onChange(oldValue, newValue);
            return true;
          },
        );
}

class WeakDependRelationship<T> extends DependRelationship<T> {
  WeakDependRelationship(ValueGetter<T> getter, {OnChange<T>? onChange})
      : super(
          getter,
          handler: (oldValue, newValue) {
            if (onChange != null) onChange(oldValue, newValue);
            return false;
          },
        );
}
