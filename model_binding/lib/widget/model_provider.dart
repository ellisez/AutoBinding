import 'model_inject.dart';
import 'package:flutter/widgets.dart';

class ModelDependentManager extends InheritedModel<DependRelationship> {
  ModelDependentManager({super.key, required super.child});

  static W? of<W extends ModelDependentManager>(BuildContext context) {
    return context.getInheritedWidgetOfExactType<W>();
  }

  @override
  bool updateShouldNotify(covariant ModelDependentManager oldWidget) => true;

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

abstract class ShouldNotifyDependents {
  void notifyDependents();
}

abstract class ModelProviderStatefulWidget extends StatefulWidget {
  final WidgetBuilder builder;

  ModelProviderStatefulWidget({required this.builder});
}

class ModelStatefulWidget<T> extends ModelProviderStatefulWidget {
  final T model;

  ModelStatefulWidget({required super.builder, required this.model});

  @override
  ModelState<T> createState() => ModelState<T>();
}

abstract class ModelProviderState<T extends ModelProviderStatefulWidget>
    extends State<T> implements ShouldNotifyDependents {
  static T? of<T extends ModelProviderState>(BuildContext context) {
    return context.findAncestorStateOfType<T>();
  }

  void notifyDependents() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ModelDependentManager(
      child: widget.builder(context),
    );
  }
}

class ModelState<T> extends ModelProviderState<ModelStatefulWidget<T>> {
  late T model;

  @override
  void initState() {
    model = widget.model;
    super.initState();
  }
}

abstract class ModelProviderWidget extends StatelessWidget
    implements ShouldNotifyDependents {
  final WidgetBuilder builder;

  ModelProviderWidget({required this.builder}) : super(key: GlobalKey());

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
      child: this.builder(context),
    );
  }
}

class ModelStatelessWidget<T> extends ModelProviderWidget {
  final T model;

  ModelStatelessWidget({required this.model, required super.builder});
}
