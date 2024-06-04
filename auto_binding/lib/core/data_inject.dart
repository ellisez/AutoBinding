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
      throw AssertionError(
          'No data provider installed, please check the location of the context.');
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

  BuildBinding<P, T> createBuildBinding<P extends ShouldNotifyDependents, T>(
          Ref<P, T> ref) =>
      BuildBinding._(this, ref);

  NotifierBinding<P, T>
      createNotifierBinding<P extends ShouldNotifyDependents, T>(
              Ref<P, T> ref) =>
          NotifierBinding._(this, ref);

  void watch<P extends ShouldNotifyDependents, T>(Ref<P, T> ref) => BuildBinding._(this, ref).value;
}

class Ref<P extends ShouldNotifyDependents, T> {
  T Function(P) getter;
  void Function(P, T) setter;

  Ref({required this.getter, required this.setter});
}

abstract class Binding<P extends ShouldNotifyDependents, T> {
  Ref<P, T> ref;

  BindingBuilder builder;

  P? _provider;

  P get provider {
    if (_provider == null) {
      var provider = findProvider<P>(builder._context);
      assert(provider != null, '$P cannot be found in the widget tree.');
      _provider = provider!;
    }
    return _provider!;
  }

  Binding(this.builder, this.ref) {
    assert(
        builder._context.owner?.debugBuilding ??
            builder._context.debugDoingBuild,
        'new Ref can only run during the method of build() calls.');
  }

  T get value;

  T get raw => ref.getter(provider);

  set value(T value) {
    var old = ref.getter(provider);
    if (old != value) {
      ref.setter(provider, value);
      provider.notifyDependents();
    }
  }

  void dispose();
}

class BuildBinding<P extends ShouldNotifyDependents, T> extends Binding<P, T> {
  BuildBinding._(super.builder, super.ref);

  T get value {
    if (builder._context.owner?.debugBuilding ??
        builder._context.debugDoingBuild) {
      builder._context.dependOnInheritedWidgetOfExactType<DependentManager>(
        aspect: BuildDependentExecutor<P, T>(this),
      );
    }
    return raw;
  }

  @override
  void dispose() {}
}

class NotifierBinding<P extends ShouldNotifyDependents, T> extends Binding<P, T>
    implements Listenable {
  NotifierBinding._(super.builder, super.ref);

  List<VoidCallback> _listeners = List<VoidCallback>.empty(growable: true);
  Map<Listenable, BindingNotifier> _bindingListenable = {};

  @override
  T get value {
    if (builder._context.owner?.debugBuilding ??
        builder._context.debugDoingBuild) {
      builder._context.dependOnInheritedWidgetOfExactType<DependentManager>(
        aspect: NotifierDependentExecutor<P, T>(this),
      );
    }
    return raw;
  }

  @override
  set value(T value) {
    super.value = value;
    notifyListeners();
  }

  void bindNotifier(
    ChangeNotifier notifier, {
    required VoidCallback setToNotifier,
    required VoidCallback getFromNotifier,
  }) {
    _bindingListenable[notifier] = BindingNotifier(
        setToNotifier: setToNotifier, getFromNotifier: getFromNotifier);

    if (builder._context.owner?.debugBuilding ??
        builder._context.debugDoingBuild) {
      builder._context.dependOnInheritedWidgetOfExactType<DependentManager>(
        aspect: NotifierDependentExecutor<P, T>(this),
      );
    }
  }

  void bindValueNotifier<V>(
    ValueNotifier<V> valueNotifier, {
    V Function(T)? covertToValue,
    T Function(V)? valueCovertTo,
  }) {
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

    setToNotifier();

    if (builder._context.owner?.debugBuilding ??
        builder._context.debugDoingBuild) {
      builder._context.dependOnInheritedWidgetOfExactType<DependentManager>(
        aspect: NotifierDependentExecutor<P, T>(this),
      );
    }
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

  @override
  void dispose() {
    _bindingListenable.forEach((notifier, bindingNotifier) {
      notifier.removeListener(bindingNotifier.getFromNotifier);
    });
    _bindingListenable.clear();
    _listeners.clear();
  }
}
