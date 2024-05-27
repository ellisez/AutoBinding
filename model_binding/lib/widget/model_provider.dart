import 'dart:collection';

import 'model_inject.dart';
import 'package:flutter/widgets.dart';

class ModelDependentManager extends InheritedWidget {
  final VoidCallback notifyDependents;

  ModelDependentManager(
      {super.key, required super.child, required this.notifyDependents});

  static W? of<W extends ModelDependentManager>(BuildContext context) {
    return context.getInheritedWidgetOfExactType<W>();
  }

  @override
  bool updateShouldNotify(covariant ModelDependentManager oldWidget) => true;

  @override
  InheritedElement createElement() => ModelDependentManagerElement(this);
}

class ModelDependentManagerElement extends InheritedElement {
  ModelDependentManagerElement(super.widget);

  @override
  void updateDependencies(Element dependent, Object? aspect) {
    final Set<DependRelationship>? dependencies = getDependencies(dependent) as Set<DependRelationship>?;

    if (aspect == null) {
      setDependencies(dependent, HashSet<DependRelationship>());
    } else {
      assert(aspect is DependRelationship);
      setDependencies(dependent, (dependencies ?? HashSet<DependRelationship>())..add(aspect as DependRelationship));
    }
  }

  @protected
  void notifyDependent(covariant InheritedWidget oldWidget, Element dependent) {
    final Set<DependRelationship>? dependencies =
        getDependencies(dependent) as Set<DependRelationship>?;
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

abstract class ShouldNotifyDependents {
  void notifyDependents();
}

abstract class ModelProviderStatefulWidget extends StatefulWidget {
  final Widget child;

  ModelProviderStatefulWidget({required this.child});
}

class ModelStatefulWidget<T> extends ModelProviderStatefulWidget {
  final T model;

  ModelStatefulWidget({required super.child, required this.model});

  @override
  ModelState<T> createState() => ModelState<T>();
}

abstract class ModelProviderState<T extends StatefulWidget> extends State<T>
    implements ShouldNotifyDependents {
  static T? of<T extends ModelProviderState>(BuildContext context) {
    return context.findAncestorStateOfType<T>();
  }

  void notifyDependents() {
    setState(() {});
  }

  Widget builder(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return ModelDependentManager(
      child: builder(context),
      notifyDependents: notifyDependents,
    );
  }
}

class ModelState<T> extends ModelProviderState<ModelStatefulWidget<T>> {
  late T model;

  static T? of<T extends ModelState>(BuildContext context) {
    return context.findAncestorStateOfType<T>();
  }

  @override
  void initState() {
    model = widget.model;
    super.initState();
  }

  @override
  Widget builder(BuildContext context) => widget.child;
}

abstract class ModelProviderWidget extends StatelessWidget
    implements ShouldNotifyDependents {
  final Widget child;

  ModelProviderWidget({required this.child}) : super(key: GlobalKey());

  static T? of<T extends ModelProviderWidget>(BuildContext context) {
    return context.findAncestorWidgetOfExactType<T>();
  }

  void notifyDependents() {
    var globalKey = this.key as GlobalKey;
    (globalKey.currentContext as StatelessElement).markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) {
    return ModelDependentManager(
      child: this.child,
      notifyDependents: notifyDependents,
    );
  }
}

class ModelStatelessWidget<T> extends ModelProviderWidget {
  final T model;

  ModelStatelessWidget({required this.model, required super.child});
}
