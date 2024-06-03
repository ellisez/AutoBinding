import 'dart:collection';

import 'package:auto_binding/auto_binding.dart';
import 'package:flutter/widgets.dart';

import 'data_provider.dart';
import 'dependent_manager.dart';

class TypeOf<T> {
  TypeOf._();

  static bool instanceOf<S, T>() => TypeOf<S>._() is TypeOf<T>;
}

class BindingNotifier {
  VoidCallback setToNotifier;
  VoidCallback getFromNotifier;

  BindingNotifier({required this.setToNotifier, required this.getFromNotifier});
}

P? findProvider<P extends ShouldNotifyDependents>(BuildContext context) {
  P? Function(Element element) tryProvider;

  if (TypeOf.instanceOf<P, DataState>()) {
    tryProvider = (ancestor) =>
        ancestor is StatefulElement && ancestor.state is P
            ? ancestor.state as P
            : null;
  } else if (TypeOf.instanceOf<P, DataStatelessWidget>()) {
    tryProvider = (ancestor) =>
        ancestor.widget.runtimeType == P ? ancestor.widget as P : null;
  } else {
    throw AssertionError('$P is not a data provider.');
  }

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

class BindingBuilder {
  final BuildContext _context;

  BindingBuilder(this._context) {
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
      throw AssertionError('No data provider installed, please check the location of the context.');
    }
    var dependencies = dependentManagerElement.getDependencies(element);
    if (dependencies == null) {
      return;
    }
    for (var dependentIsChange in dependencies) {
      dependentIsChange.reset();
    }
    dependentManagerElement.updateDependencies(element, null);

  }

  Binding<P, T> bind<P extends ShouldNotifyDependents, T>({
    required T Function(P) getter,
    required void Function(P, T) setter,
  }) =>
      Binding._(this, getter: getter, setter: setter);

  Binding<P, T> bindRef<P extends ShouldNotifyDependents, T>(Ref<P, T> ref) =>
      Binding._ref(this, ref);
}

class Ref<P extends ShouldNotifyDependents, T> {
  T Function(P) getter;
  void Function(P, T) setter;

  Ref({required this.getter, required this.setter});
}

class Binding<P extends ShouldNotifyDependents, T> extends Listenable {
  List<VoidCallback> _listeners = List<VoidCallback>.empty(growable: true);

  Ref<P, T> ref;

  BindingBuilder builder;

  Map<Listenable, BindingNotifier> _bindingListenable = {};
  late P _provider;

  Binding._(
    BindingBuilder binding, {
    required T Function(P) getter,
    required void Function(P, T) setter,
  }) : this._ref(binding, Ref<P, T>(getter: getter, setter: setter));

  Binding._ref(this.builder, this.ref) {
    assert(
        builder._context.owner?.debugBuilding ??
            builder._context.debugDoingBuild,
        'new Ref can only run during the method of build() calls.');
    var provider = findProvider<P>(builder._context);
    assert(provider != null, '$P cannot be found in the widget tree.');
    _provider = provider!;
  }

  T get value {
    var newValue = raw;
    if (builder._context.owner?.debugBuilding ??
        builder._context.debugDoingBuild) {
      builder._context.dependOnInheritedWidgetOfExactType<DependentManager>(
        aspect: DependentIsChange<P, T>(binding: this, value: newValue),
      );
    }
    return newValue;
  }

  T get raw => ref.getter(_provider);

  set value(T value) {
    var old = ref.getter(_provider);
    if (old != value) {
      ref.setter(_provider, value);
      notifyListeners();
      _provider.notifyDependents();
    }
  }

  void bindNotifier(ChangeNotifier notifier,
      {required VoidCallback setToNotifier,
      required VoidCallback getFromNotifier}) {
    // if (!ChangeNotifier.debugAssertNotDisposed(notifier)) {
    //   unbindNotifier(notifier);
    //   return;
    // }
    _bindingListenable[notifier] = BindingNotifier(
        setToNotifier: setToNotifier, getFromNotifier: getFromNotifier);
  }

  void bindValueNotifier<V>(ValueNotifier<V> valueNotifier,
      {V Function(T)? covertToValue, T Function(V)? valueCovertTo}) {
    // if (!ChangeNotifier.debugAssertNotDisposed(valueNotifier)) {
    //   unbindNotifier(valueNotifier);
    //   return;
    // }

    if (covertToValue == null) {
      covertToValue = (T t) => t as V;
    }
    VoidCallback setToNotifier = () {
      valueNotifier.value = covertToValue!(raw);
    };
    addListener(setToNotifier);
    if (valueCovertTo == null) {
      valueCovertTo = (V v) => v as T;
    }
    VoidCallback getFromNotifier = () {
      value = valueCovertTo!(valueNotifier.value);
    };
    valueNotifier.addListener(getFromNotifier);

    _bindingListenable[valueNotifier] = BindingNotifier(
        setToNotifier: setToNotifier, getFromNotifier: getFromNotifier);
  }

  void unbindNotifier(ChangeNotifier notifier) {
    var bindingNotifier = _bindingListenable[notifier];
    if (bindingNotifier == null) {
      return;
    }
    removeListener(bindingNotifier.setToNotifier);
    notifier.removeListener(bindingNotifier.getFromNotifier);
    _bindingListenable.remove(notifier);
  }

  void reset() {
    _bindingListenable.forEach((notifier, bindingNotifier) {
      notifier.removeListener(bindingNotifier.getFromNotifier);
    });
    _bindingListenable.clear();
    _listeners.clear();
  }

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }
}
