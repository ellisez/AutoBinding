import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dependent.dart';

/**
 * v3.x
 * var loginFormRef = loginForm.toRef(); // Map
 * var ref = loginFormRef.info.nickName;
 *
 * var node = Binding.node(context); // old dependentExecutor dispose
 *
 * // nodeBinding can add dependencies, set value for update pages
 * var ref = dataRef.toRef(context: context) // dataRef to ref
 * var nodeBinding = dataRef.$nodeOf(node) // dataRef to nodeBinding
 * var nodeBinding = loginFormRef.info.nickName.$nodeOf(node) // ref to nodeBinding
 *
 * // contextBinding unable to bind page, only set value for update pages
 * var contextBinding = providerRef.$contextOf(context) // providerRef to nodeLessBinding
 * var contextBinding = loginFormRef.info.nickName.$contextOf(context) // nodeLessBinding unable to bind page
 *
 * var nickName = loginFormRef.info.nickName() // get value
 * loginFormRef.info.nickName(value: '123') // set value
 * loginFormRef.info.nickName(empty: true) // set null
 *
 * loginFormRef.info.nickName.$nodeOf(node).value // get value and add dependentExecutor
 * loginFormRef.info.nickName.$nodeOf(node).raw // get value but no bind
 * loginFormRef.info.nickName.$nodeOf(node).value = '123'; // set value and update page
 * loginFormRef.info.nickName.$nodeOf(node).raw = '123'; // set value but do not update page
 *
 * loginFormRef.info.nickName.$contextOf(context).raw // get value but no bind
 * loginFormRef.info.nickName.$contextOf(context).value = '123'; // set value and update page
 * loginFormRef.info.nickName.$contextOf(context).raw = '123'; // set value but do not update page
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

abstract class Binding<T> {
  static BindingNode node(BuildContext context) => BindingNode._(context);

  Ref<T> ref;

  Binding._(this.ref);

  set value(T value) => raw = value;

  T get raw => ref();

  set raw(T value) => ref(value: value, empty: value == null);
}

class ContextBinding<T> extends Binding<T> {
  @protected
  BuildContext context;

  ContextBinding._(Ref<T> ref, this.context) : super._(ref) {
    var provider = findProvider(context);
    assert(provider != null,
        'No data provider found, please make sure there is a `DataState` or `DataStatelessWidget` on the WidgetTree.');
    this.provider = provider!;
  }

  @protected
  late DataProvider provider;

  set value(T value) {
    if (raw != value) {
      raw = value;
      provider.notifyDependents();
    }
  }
}

class NodeBinding<T> extends ContextBinding<T> {
  NodeBinding._(Ref<T> ref, BindingNode node) : super._(ref, node._context);

  T get value {
    if (context.owner?.debugBuilding ?? context.debugDoingBuild) {
      context.dependOnInheritedWidgetOfExactType<DependentManager>(
        aspect: BuildDependentExecutor<T>(this),
      );
    }
    return raw;
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

  T call(T? value, {required BuildContext context, bool empty = false}) =>
      toRef(context).call(value: value, empty: empty);

  NodeBinding<T> $nodeOf(BindingNode node) =>
      NodeBinding<T>._(toRef(node._context), node);

  ContextBinding<T> $contextOf(BuildContext context) =>
      ContextBinding<T>._(toRef(context), context);
}

class Ref<T> {
  late final ValueGetter<T> _getter;
  late final ValueSetter<T> _setter;

  static DataRef<P, T> fromData<P extends DataProvider, T>({
    required T Function(P) getter,
    required void Function(P, T) setter,
  }) =>
      DataRef._(getter: getter, setter: setter);

  T call({T? value, bool empty = false}) {
    if (value != null && empty) {
      throw AssertionError(
          'The parameters `value` and `empty` must provide one of them');
    }

    var currentValue = _getter();
    if (value != null || empty) {
      if (value != currentValue) {
        _setter(value as dynamic);
      }
      return value as dynamic;
    }
    return currentValue;
  }

  NodeBinding<T> $nodeOf(BindingNode node) => NodeBinding<T>._(this, node);

  ContextBinding<T> $contextOf(BuildContext context) =>
      ContextBinding<T>._(this, context);

  Ref({required ValueGetter<T> getter, required ValueSetter<T> setter})
      : _getter = getter,
        _setter = setter;

  Ref.of(T raw) {
    this._getter = () => raw;
    this._setter =
        (T value) => throw UnsupportedError('unsupported setter call');
  }
}

class NotifierBinding<T> extends ContextBinding<T> {
  ChangeNotifier notifier;
  ValueSetter<NotifierBinding<T>> notifyListener;
  ValueSetter<NotifierBinding<T>> onChange;

  NotifierBinding({
    required BindingNode node,
    required Ref<T> ref,
    required this.notifier,
    required this.notifyListener,
    required this.onChange,
  }) : super._(ref, node._context){
    notifier.addListener(_notifyListener);
  }

  void _notifyListener() {
    notifyListener(this);
  }

  void dispose() {
    notifier.removeListener(_notifyListener);
  }
}

NotifierBinding<T> bindChangeNotifier<T>({
  required BindingNode node,
  required Ref<T> ref,
  required ChangeNotifier changeNotifier,
  required ValueSetter<NotifierBinding<T>> notifyListener,
  required ValueSetter<NotifierBinding<T>> onChange,
}) {
  var notifierBinding = NotifierBinding<T>(
    node: node,
    ref: ref,
    notifier: changeNotifier,
    notifyListener: notifyListener,
    onChange: onChange,
  );
  node._context.dependOnInheritedWidgetOfExactType<DependentManager>(
    aspect: NotifierDependentExecutor<T>(notifierBinding),
  );
  return notifierBinding;
}

NotifierBinding<T> bindValueNotifier<T, V>({
  required BindingNode node,
  required Ref<T> ref,
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
    node: node,
    ref: ref,
    changeNotifier: valueNotifier,
    notifyListener: (binding) {
      var newValue = valueCovertTo!(valueNotifier.value);
      if (binding.raw != newValue) {
        binding.value = newValue;
      }
    },
    onChange: (binding) {
      valueNotifier.value = covertToValue!(binding.raw);
    },
  );
}
