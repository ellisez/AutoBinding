import 'dart:collection';

import 'model_inject.dart';
import 'package:flutter/widgets.dart';

class ModelProvider extends InheritedWidget {
  ModelProvider({super.key, required super.child});

  static W? of<W extends ModelProvider>(BuildContext context) {
    return context.getInheritedWidgetOfExactType<W>();
  }

  @override
  bool updateShouldNotify(covariant ModelProvider oldWidget) => true;

  @override
  InheritedElement createElement() => ModelBindingElement(this);
}

class ModelBindingElement extends InheritedElement {
  ModelBindingElement(super.widget);

  @override
  void updateDependencies(Element dependent, Object? aspect) {
    final Set<ValueObserver>? dependencies = getDependencies(dependent) as Set<ValueObserver>?;
    if (dependencies != null && dependencies.isEmpty) {
      return;
    }

    if (aspect == null) {
      setDependencies(dependent, HashSet<ValueObserver>());
    } else {
      assert(aspect is ValueObserver);
      setDependencies(
          dependent, (dependencies ?? HashSet<ValueObserver>())..add(aspect as ValueObserver));
    }
  }

  @override
  void notifyDependent(ModelProvider oldWidget, Element dependent) {
    final Set<ValueObserver>? dependencies = getDependencies(dependent) as Set<ValueObserver>?;
    if (dependencies == null) {
      return;
    }
    if (dependencies.isEmpty) {
      dependent.didChangeDependencies();
    } else {
      for (var valueObserver in dependencies) {
        if (valueObserver.isChanged()) {
          dependent.didChangeDependencies();
          break;
        }
      }
    }
  }
}

