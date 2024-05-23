import 'package:flutter/cupertino.dart';

import 'model_provider.dart';

typedef TypeCast<T, N> = N Function(T value);

abstract class ValueObserver {
  bool isChanged();
}

abstract class ModelBinder<T> extends ValueObserver {
  T value;
  ValueGetter<T> getter;

  ModelBinder(this.getter):
    this.value = getter();

  bool isChanged() => value != getter();
}

class ValueBinder<T> extends ModelBinder<T> {
  ValueBinder(super.getter);
}

class ConnectedValueNotifier<N, T, W extends ModelProvider> {
  ValueNotifier<N> valueNotifier;
  TypeCast<T, N> converter;

  ConnectedValueNotifier(this.valueNotifier, this.converter);
}

class NotifierBinder<T> extends ModelBinder<T> {
  final connectedValueNotifierList = <ConnectedValueNotifier>[];
  ValueSetter<T> setter;

  NotifierBinder(super.getter, this.setter);

  ValueNotifier<N> bindToNotifier<N>(
    ValueNotifier<N> valueNotifier, {
    TypeCast<T, N>? getterConverter,
    TypeCast<N, T>? setterConverter,
  }) {
    if (T is N) {
      if (getterConverter == null) {
        getterConverter = (T t) => t as N;
      }
      if (setterConverter == null) {
        setterConverter = (N n) => n as T;
      }
    } else {
      if (getterConverter == null) {
        throw AssertionError(
            'No getterConverter function provided for $T to $N');
      }
      if (setterConverter == null) {
        throw AssertionError(
            'No setterConverter function provided for $N to $T');
      }
    }

    valueNotifier.value = getterConverter(value);
    valueNotifier.addListener(
        () => setter(setterConverter!(valueNotifier.value)));

    var connectedValueNotifier =
        ConnectedValueNotifier(valueNotifier, getterConverter);
    connectedValueNotifierList.add(connectedValueNotifier);
    return valueNotifier;
  }

  TextEditingController bindToTextEditingController(
    TextEditingController controller, {
    TypeCast<T, String>? getterConverter,
    TypeCast<String, T>? setterConverter,
  }) {
    if (T is String) {
      if (getterConverter == null) {
        getterConverter = (T t) => t as String;
      }
      if (setterConverter == null) {
        setterConverter = (String n) => n as T;
      }
    } else {
      if (getterConverter == null) {
        throw AssertionError(
            'No getterConverter function provided for $T to String');
      }
      if (setterConverter == null) {
        throw AssertionError(
            'No setterConverter function provided for String to $T');
      }
    }
    return bindToNotifier<TextEditingValue>(
      controller,
      getterConverter: (value) {
        controller.text = getterConverter!(value);
        return controller.value;
      },
      setterConverter: (value) => setterConverter!(value.text),
    ) as TextEditingController;
  }

  bool isChanged() {
    var oldValue = value;
    var newValue = getter();
    if (newValue != oldValue) {
      value = newValue;
      for (var item in connectedValueNotifierList) {
        item.valueNotifier.value = item.converter(newValue);
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        item.valueNotifier.notifyListeners();
      }
    }
    return false;
  }
}
