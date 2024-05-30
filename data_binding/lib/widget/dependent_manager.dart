import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'data_inject.dart';

abstract class ShouldNotifyDependents {
  void notifyDependents();
}

class DependentIsChange<P extends ShouldNotifyDependents,T> {
  Ref<P, T> binder;
  T value;

  bool isChange(Element element) {
    var provider = binder.findProvider(element);
    var oldValue = value;
    value = binder.getter(provider);
    return value != oldValue;
  }

  DependentIsChange({required this.binder, required this.value});
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
  void updateDependencies(Element dependent, Object? aspect) {
    final Set<DependentIsChange>? dependencies = getDependencies(dependent) as Set<DependentIsChange>?;

    if (aspect == null) {
      setDependencies(dependent, HashSet<DependentIsChange>());
    } else {
      assert(aspect is DependentIsChange);
      setDependencies(dependent, (dependencies ?? HashSet<DependentIsChange>())..add(aspect as DependentIsChange));
    }
  }

  @protected
  void notifyDependent(covariant InheritedWidget oldWidget, Element dependent) {
    final Set<DependentIsChange>? dependencies =
    getDependencies(dependent) as Set<DependentIsChange>?;
    if (dependencies == null || dependencies.isEmpty) {
      return;
    }
    for (var dependRelationship in dependencies) {
      if (dependRelationship.isChange(dependent)) {
        dependent.didChangeDependencies();
        break;
      }
    }
  }
}
