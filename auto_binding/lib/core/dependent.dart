import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'inject.dart';

abstract class DataProvider {
  void notifyDependents();
}

abstract class DependentExecutor<T> {
  Ref<T> ref;
  T value;

  bool isChange() {
    var oldValue = value;
    value = ref();
    return value != oldValue;
  }

  dispose() {}

  DependentExecutor(this.ref): value = ref();
}

class BuildDependentExecutor<T> extends DependentExecutor<T> {
  ContextBinding<T> binding;
  BuildDependentExecutor(this.binding): super(binding.ref);
}

class NotifierDependentExecutor<T> extends DependentExecutor<T> {
  NotifierBinding<T> binding;
  NotifierDependentExecutor(this.binding): super(binding.ref);

  @override
  bool isChange() {
    if (super.isChange()) {
      binding.onChange(binding);
    }
    return false;
  }

  @override
  dispose() => binding.dispose();
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
