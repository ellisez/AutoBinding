import 'package:flutter/cupertino.dart';

import 'model_provider.dart';

class DependRelationship<P extends ShouldNotifyDependents,T> {
  Binder<P, T> binder;
  T value;

  bool isChange(Element element) {
    var provider = binder.findProvider(element);
    var oldValue = value;
    value = binder.getter(provider);
    return value != oldValue;
  }

  DependRelationship({required this.binder, required this.value});
}

class Binding<P extends ShouldNotifyDependents, T> extends ChangeNotifier {
  final BuildContext _context;
  final Binder<P, T> _binder;

  late final P _provider;

  Binding(this._context, this._binder) {
    assert(_context.debugDoingBuild,
        'new Binding can only run during the method of build() calls.');
    _provider = _binder.findProvider(_context);
  }

  T bindTo() {
    var newValue = value;
    if (_context.debugDoingBuild) {
      _context.dependOnInheritedWidgetOfExactType<ModelDependentManager>(
        aspect: DependRelationship<P, T>(binder: _binder, value: newValue),
      );
    }
    return newValue;
  }

  T get value => _binder.getter(_provider);

  set value(T value) {
    var old = _binder.getter(_provider);
    if (old != value) {
      _binder.setter(_provider, value);
      notifyListeners();
      _provider.notifyDependents();
    }
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
    var provider = ModelProviderWidget.of<P>(context);
    assert(provider != null, 'can not found $P dependOn.');
    return provider!;
  }
}
