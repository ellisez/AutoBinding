import 'dart:collection';

import 'model_inject.dart';
import 'package:flutter/widgets.dart';

class ModelInheritedWidget extends InheritedModel<DependRelationship> {
  ModelInheritedWidget({super.key, required super.child});

  static W? of<W extends ModelInheritedWidget>(BuildContext context) {
    return context.getInheritedWidgetOfExactType<W>();
  }

  @override
  bool updateShouldNotify(covariant ModelInheritedWidget oldWidget) => true;

  @override
  bool updateShouldNotifyDependent(
      covariant InheritedModel<DependRelationship> oldWidget,
      Set<DependRelationship> dependencies) {
    for (var dependRelationship in dependencies) {
      if (dependRelationship.updateShouldNotifyDependent()) {
        return true;
      }
    }
    return false;
  }
}

class ModelProvider<T> extends StatefulWidget {
  final Widget child;
  final T model;

  ModelProvider({required this.child, required this.model});

  static ModelState<T>? of<T>(BuildContext context) {
    var state = context.findAncestorStateOfType<ModelState<T>>();
    if (state == null) {
      return null;
    }
    return state;
  }

  @override
  ModelState<T> createState() => ModelState<T>();
}

class ModelState<T> extends State<ModelProvider<T>> {
  T get model => widget.model;

  @override
  void initState() {
    super.initState();
  }

  void dependOnInheritedWidgetOfExactType(BuildContext context,
      {required DependRelationship aspect}) {
    context.dependOnInheritedWidgetOfExactType<ModelInheritedWidget>(aspect:  aspect);
  }

  ////
  @override
  Widget build(BuildContext context) {
    return ModelInheritedWidget(
      child: this.widget.child,
    );
  }
}
