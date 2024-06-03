
import 'package:flutter/widgets.dart';

import 'data_provider.dart';
import 'dependent_manager.dart';

class Binding<P extends ShouldNotifyDependents, T> extends ChangeNotifier {
  final BuildContext _context;
  final Ref<P, T> _ref;

  late final P _provider;

  Binding(this._context, this._ref) {
    assert(_context.owner?.debugBuilding ?? _context.debugDoingBuild,
        'new Binding can only run during the method of build() calls.');
    _provider = _ref.findProvider(_context);
    _context.dependOnInheritedWidgetOfExactType<DependentManager>();
  }

  T bindTo() {
    var newValue = value;
    if (_context.owner?.debugBuilding ?? _context.debugDoingBuild) {
      _context.dependOnInheritedWidgetOfExactType<DependentManager>(
        aspect: DependentIsChange<P, T>(binder: _ref, value: newValue),
      );
    }
    return newValue;
  }

  T get value => _ref.getter(_provider);

  set value(T value) {
    var old = _ref.getter(_provider);
    if (old != value) {
      _ref.setter(_provider, value);
      notifyListeners();
      _provider.notifyDependents();
    }
  }
}

abstract class Ref<P extends ShouldNotifyDependents, T> {
  T Function(P) getter;
  void Function(P, T) setter;

  Ref({required this.getter, required this.setter});

  Binding<P, T> connect(BuildContext context) {
    assert(context.owner?.debugBuilding ?? context.debugDoingBuild,
        'connect() can only run during the method of build() calls.');
    return Binding(context, this);
  }

  P findProvider(BuildContext context);
}

class StateRef<P extends DataState, T> extends Ref<P, T> {
  StateRef({required super.getter, required super.setter});

  @override
  P findProvider(BuildContext context) {
    var provider = DataState.of<P>(context);
    assert(provider != null, 'can not found $P dependOn.');
    return provider!;
  }
}

class WidgetRef<P extends DataStatelessWidget, T> extends Ref<P, T> {
  WidgetRef({required super.getter, required super.setter});

  @override
  P findProvider(BuildContext context) {
    var provider = DataStatelessWidget.of<P>(context);
    assert(provider != null, 'can not found $P dependOn.');
    return provider!;
  }
}