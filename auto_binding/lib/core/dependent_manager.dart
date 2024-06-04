import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'data_inject.dart';

abstract class ShouldNotifyDependents {
  void notifyDependents();
}

abstract class DependentExecutor<P extends ShouldNotifyDependents, T> {
  Binding<P, T> binding;
  T value;

  bool isChange() {
    var oldValue = value;
    value = binding.raw;
    return value != oldValue;
  }

  dispose() {
    binding.dispose();
  }

  DependentExecutor(this.binding): value = binding.raw;
}

class BuildDependentExecutor<P extends ShouldNotifyDependents, T> extends DependentExecutor<P, T> {
  BuildDependentExecutor(BuildBinding<P, T> binding): super(binding);
}

class NotifierDependentExecutor<P extends ShouldNotifyDependents, T> extends DependentExecutor<P, T> {
  NotifierDependentExecutor(NotifierBinding<P, T> binding): super(binding);

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
