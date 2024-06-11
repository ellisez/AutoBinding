import 'dart:collection';

import 'package:auto_binding/auto_binding.dart';
import 'package:flutter/widgets.dart';
import 'inject.dart';

abstract class DataProvider {
  void notifyDependents();
}

abstract class DependentExecutor<T> {
  Binding<T> binding;
  T value;

  bool isChange() {
    var oldValue = value;
    value = binding.value;
    return value != oldValue;
  }

  dispose() {}

  DependentExecutor(this.binding): value = binding.value;
}

class BuildDependentExecutor<T> extends DependentExecutor<T> {

  BuildDependentExecutor(super.binding);
}

class NotifierDependentExecutor<T> extends DependentExecutor<T> {
  NotifierBinding<T> notifierBinding;
  NotifierDependentExecutor(this.notifierBinding): super(notifierBinding.binding);

  @override
  bool isChange() {
    if (super.isChange()) {
      notifierBinding.onChange();
    }
    return false;
  }

  @override
  dispose() => notifierBinding.dispose();
}

class DependentManager extends InheritedWidget {
  final VoidCallback notifyDependents;

  DependentManager(
      {super.key, required super.child, required this.notifyDependents});

  static W? of<W extends DependentManager>(BuildContext context) {
    return context.getElementForInheritedWidgetOfExactType<W>()?.widget as W?;
  }

  @override
  bool updateShouldNotify(covariant DependentManager oldWidget) => true;

  @override
  InheritedElement createElement() => DependentManagerElement(this);
}

class DependentManagerElement extends InheritedElement {
  DependentManagerElement(super.widget);

  @override
  Set<DependentExecutor>? getDependencies(Element dependent) =>
      super.getDependencies(dependent) as Set<DependentExecutor>?;

  @override
  void updateDependencies(Element dependent, Object? aspect) {
    final Set<DependentExecutor>? dependencies = getDependencies(dependent);

    if (aspect == null) {
      setDependencies(dependent, HashSet<DependentExecutor>());
    } else {
      assert(aspect is DependentExecutor);
      setDependencies(
          dependent,
          (dependencies ?? HashSet<DependentExecutor>())
            ..add(aspect as DependentExecutor));
    }
  }

  @override
  @protected
  void notifyDependent(covariant InheritedWidget oldWidget, Element dependent) {
    final Set<DependentExecutor>? dependencies = getDependencies(dependent);
    if (dependencies == null || dependencies.isEmpty) {
      return;
    }
    for (var dependentExecutor in dependencies) {
      if (dependentExecutor.isChange()) {
        dependent.didChangeDependencies();
        break;
      }
    }
  }
}
