import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'data_inject.dart';

abstract class ShouldNotifyDependents {
  void notifyDependents();
}

class DependentIsChange<P extends ShouldNotifyDependents, T> {
  Binding<P, T> binding;
  T value;

  bool isChange() {
    var oldValue = value;
    value = binding.raw;
    return value != oldValue;
  }

  reset() {
    binding.reset();
  }

  DependentIsChange({required this.binding, required this.value});
}

class DependentManager extends InheritedWidget {
  final VoidCallback notifyDependents;

  DependentManager(
      {super.key, required super.child, required this.notifyDependents});

  static W? of<W extends DependentManager>(BuildContext context) {
    return context.getInheritedWidgetOfExactType<W>();
  }

  @override
  bool updateShouldNotify(covariant DependentManager oldWidget) => true;

  @override
  InheritedElement createElement() => DependentManagerElement(this);
}

class DependentManagerElement extends InheritedElement {
  DependentManagerElement(super.widget);

  @override
  Set<DependentIsChange>? getDependencies(Element dependent) =>
      super.getDependencies(dependent) as Set<DependentIsChange>?;

  @override
  void updateDependencies(Element dependent, Object? aspect) {
    final Set<DependentIsChange>? dependencies = getDependencies(dependent);

    if (aspect == null) {
      setDependencies(dependent, HashSet<DependentIsChange>());
    } else {
      assert(aspect is DependentIsChange);
      setDependencies(
          dependent,
          (dependencies ?? HashSet<DependentIsChange>())
            ..add(aspect as DependentIsChange));
    }
  }

  @protected
  void notifyDependent(covariant InheritedWidget oldWidget, Element dependent) {
    final Set<DependentIsChange>? dependencies = getDependencies(dependent);
    if (dependencies == null || dependencies.isEmpty) {
      return;
    }
    for (var dependentIsChange in dependencies) {
      if (dependentIsChange.isChange()) {
        dependent.didChangeDependencies();
        break;
      }
    }
  }
}
