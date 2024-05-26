import 'package:flutter/cupertino.dart';

import 'model_provider.dart';

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

class Binding<P extends ShouldNotifyDependents, T> {
  final BuildContext _context;
  final Binder<P, T> _binder;

  late final P _provider;

  Binding(this._context, this._binder) {
    assert(_context.debugDoingBuild,
        'new Binding can only run during the method of build() calls.');
    _provider = _binder.findProvider(_context);
  }

  T get value {
    if (_context.debugDoingBuild) {
      _context.dependOnInheritedWidgetOfExactType<ModelDependentManager>(
        aspect: StrongDependRelationship<T>(() => _binder.getter(_provider)),
      );
    }
    return _binder.getter(_provider);
  }

  set value(T value) {
    var old = _binder.getter(_provider);
    if (old != value) {
      _binder.setter(_provider, value);
      _provider.notifyDependents();
    }
  }

  addListener(OnChange<T> onChange) {
    _context.dependOnInheritedWidgetOfExactType<ModelDependentManager>(
      aspect: WeakDependRelationship<T>(() => _binder.getter(_provider),
          onChange: onChange),
    );
  }
}

abstract class Binder<P extends ShouldNotifyDependents, T> {
  T Function(P) getter;
  void Function(P, T) setter;

  Binder({required this.getter, required this.setter});

  Binding<P, T> connect(BuildContext context) {
    assert(context.debugDoingBuild,
        'connect() can only run during the method of build() calls.');
    return Binding(context, this);
  }

  P findProvider(BuildContext context);
}

class StateBinder<P extends ModelProviderState, T> extends Binder<P, T> {
  StateBinder({required super.getter, required super.setter});

  @override
  P findProvider(BuildContext context) {
    var provider = ModelProviderState.of<P>(context);
    assert(provider != null, 'can not found $P dependOn.');
    return provider!;
  }
}

class WidgetBinder<P extends ModelProviderWidget, T> extends Binder<P, T> {
  WidgetBinder({required super.getter, required super.setter});

  @override
  P findProvider(BuildContext context) {
    assert(context.debugDoingBuild, 'binding only run in build() method.');
    var provider = ModelProviderWidget.of<P>(context);
    assert(provider != null, 'can not found $P dependOn.');
    return provider!;
  }
}
