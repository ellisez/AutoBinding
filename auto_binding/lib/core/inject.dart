import 'dart:ui';

import 'package:auto_binding/auto_binding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dependent.dart';

/**
 * v3.x
 * var loginFormRef = loginForm.toRef(); // Map
 * var ref = loginFormRef.info.nickName;
 *
 * var nickName = loginFormRef.info.nickName.$value // get value
 * loginFormRef.info.nickName.$value = '123' // set value
 *
 * var node = Binding.mount(context); // old dependentExecutor dispose
 *
 * var binding = dataRef(node) // dataRef to binding
 * var binding = loginFormRef.info.nickName(node) // ref to binding
 *
 * var nickName = binding.value // get value but no bind
 * binding.value = '123' // set value but do not update page
 *
 * binding.bindChange() // get value and add dependentExecutor
 * binding.notifyChange('123'); // set value and update page
 *
 * loginFormRef.info.nickName(node).bindChange() // get value and add dependentExecutor
 * loginFormRef.info.nickName(node).notifyChange('123'); // set value and update page
 * loginFormRef.info.nickName(node).value // get value but no bind
 * loginFormRef.info.nickName(node).value = '123'; // set value but do not update page
 *
 * ///
 * var nickName = loginFormRef.info.nickName.$bindChange(node: node) // get value and add dependentExecutor
 * loginFormRef.info.nickName.$notifyChange(node: node, value: '123'); // set value and update page
 *
 * bindChangeNotifier(node: node, ref: loginFormRef.info.nickName, changeNotifier: changeNotifier, notifyListener: notifyListener, onChange: onChange);
 * bindValueNotifier(node: node, ref: loginFormRef.info.nickName, valueNotifier: valueNotifier);
 */
P? findProvider<P extends DataProvider>(BuildContext context) {
  var tryProvider = (element) {
    if (element is ComponentElement) {
      if (element is StatefulElement && element.state is P) {
        return element.state as P;
      } else if (element is StatelessElement && element.widget is P) {
        return element.widget as P;
      }
    }
    return null;
  };

  P? provider;
  context.visitAncestorElements((ancestor) {
    provider = tryProvider(ancestor);
    if (provider != null) {
      return false;
    }
    return true;
  });
  return provider;
}

class BindingNode {
  final BuildContext _context;

  BindingNode._(this._context) {
    assert(_context.owner?.debugBuilding ?? _context.debugDoingBuild,
        'new Binding can only run during the method of build() calls.');
    reset();
  }

  void reset() {
    var element = _context as Element;
    var dependentManagerElement =
        _context.getElementForInheritedWidgetOfExactType<DependentManager>()
            as DependentManagerElement?;
    if (dependentManagerElement == null) {
      throw AssertionError(
          'No data provider found, please make sure there is a `DataState` or `DataStatelessWidget` on the WidgetTree.');
    }
    var dependencies = dependentManagerElement.getDependencies(element);
    if (dependencies == null) {
      return;
    }
    for (var dependentIsChange in dependencies) {
      dependentIsChange.dispose();
    }
    dependentManagerElement.updateDependencies(element, null);
  }
}

class DataRef<P extends DataProvider, T> {
  T Function(P) _getter;
  void Function(P, T) _setter;

  DataRef._(
      {required T Function(P) getter, required void Function(P, T) setter})
      : _getter = getter,
        _setter = setter;

  Ref<T> toRef(BuildContext context) {
    var provider = findProvider<P>(context);
    assert(provider != null,
        'No data provider found, please make sure there is a `DataState` or `DataStatelessWidget` on the WidgetTree.');
    return Ref(
      getter: () => _getter(provider!),
      setter: (T t) => _setter(provider!, t),
    );
  }

  T $bindChange({required BindingNode node}) => call(node).bindChange();

  void $notifyChange({required BindingNode node, required T value}) =>
      call(node).notifyChange(value);

  Binding<T> call(BindingNode node) =>
      Binding<T>._(toRef(node._context), node._context);
}

class Ref<T> {
  late final ValueGetter<T> _getter;
  late final ValueSetter<T> _setter;

  static DataRef<P, T> fromData<P extends DataProvider, T>({
    required T Function(P) getter,
    required void Function(P, T) setter,
  }) =>
      DataRef._(getter: getter, setter: setter);

  T $bindChange(BindingNode node) => call(node).bindChange();

  void $notifyChange(BindingNode node, T value) =>
      call(node).notifyChange(value);

  T get $value => _getter();

  set $value(T value) => _setter(value);

  Binding<T> call(BindingNode node) => Binding<T>._(this, node._context);

  Ref({required ValueGetter<T> getter, required ValueSetter<T> setter})
      : _getter = getter,
        _setter = setter;

  Ref.of(T raw) {
    this._getter = () => raw;
    this._setter =
        (T value) => throw UnsupportedError('unsupported setter call');
  }
}

class Binding<T> {
  static BindingNode mount(BuildContext context) => BindingNode._(context);

  BuildContext context;
  Ref<T> ref;

  Binding._(this.ref, this.context) {
    var provider = findProvider(context);
    assert(provider != null,
        'No data provider found, please make sure there is a `DataState` or `DataStatelessWidget` on the WidgetTree.');
    this.provider = provider!;
  }

  @protected
  late DataProvider provider;

  T bindChange() {
    if (context.owner?.debugBuilding ?? context.debugDoingBuild) {
      context.dependOnInheritedWidgetOfExactType<DependentManager>(
        aspect: BuildDependentExecutor<T>(this),
      );
    }
    return value;
  }

  void notifyChange(T value) {
    if (this.value != value) {
      this.value = value;
      provider.notifyDependents();
    }
  }

  T get value => ref.$value;

  set value(T value) => ref.$value = value;
}

class NotifierBinding<T> {
  Binding<T> binding;
  ChangeNotifier notifier;
  VoidCallback notifyListener;
  VoidCallback onChange;

  NotifierBinding({
    required this.binding,
    required this.notifier,
    required this.notifyListener,
    required this.onChange,
  }) {
    notifier.addListener(notifyListener);
  }

  void dispose() {
    notifier.removeListener(notifyListener);
  }
}

NotifierBinding<T> bindChangeNotifier<T>({
  required Binding<T> binding,
  required ChangeNotifier changeNotifier,
  required VoidCallback notifyListener,
  required VoidCallback onChange,
}) {
  var notifierBinding = NotifierBinding<T>(
    binding: binding,
    notifier: changeNotifier,
    notifyListener: notifyListener,
    onChange: onChange,
  );
  binding.context.dependOnInheritedWidgetOfExactType<DependentManager>(
    aspect: NotifierDependentExecutor<T>(notifierBinding),
  );
  return notifierBinding;
}

NotifierBinding<T> bindValueNotifier<T, V>({
  required Binding<T> binding,
  required ValueNotifier<V> valueNotifier,
  V Function(T)? covertToValue,
  T Function(V)? valueCovertTo,
}) {
  if (covertToValue == null) {
    covertToValue = (T t) => t as V;
  }
  if (valueCovertTo == null) {
    valueCovertTo = (V v) => v as T;
  }

  return bindChangeNotifier<T>(
    binding: binding,
    changeNotifier: valueNotifier,
    notifyListener: () {
      var newValue = valueCovertTo!(valueNotifier.value);
      if (binding.value != newValue) {
        binding.notifyChange(newValue);
      }
    },
    onChange: () {
      valueNotifier.value = covertToValue!(binding.value);
    },
  );
}
