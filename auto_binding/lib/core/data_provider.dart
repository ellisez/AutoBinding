import 'package:flutter/widgets.dart';

import 'dependent_manager.dart';

abstract class DataStatefulWidget extends StatefulWidget {
  DataStatefulWidget({super.key});

  @override
  DataState<DataStatefulWidget> createState();
}

class ModelStatefulWidget<T> extends DataStatefulWidget {
  final Widget child;
  final T model;

  ModelStatefulWidget({super.key, required this.child, required this.model});

  @override
  ModelState<T> createState() => ModelState<T>();
}

abstract class DataState<T extends StatefulWidget> extends State<T>
    implements ShouldNotifyDependents {
  Widget? _child;

  static T? of<T extends DataState>(BuildContext context) {
    return context.findAncestorStateOfType<T>();
  }

  void notifyDependents() {
    setState(() {});
  }

  Widget builder(BuildContext context);

  Widget _build(BuildContext context) {
    if (_child == null) {
      _child = builder(context);
    }
    return _child!;
  }

  @override
  Widget build(BuildContext context) {
    return DependentManager(
      child: _build(context),
      notifyDependents: notifyDependents,
    );
  }
}

class ModelState<T> extends DataState<ModelStatefulWidget<T>> {
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

abstract class DataStatelessWidget extends StatelessWidget
    implements ShouldNotifyDependents {
  final Widget child;

  DataStatelessWidget({required this.child}) : super(key: GlobalKey());

  static T? of<T extends DataStatelessWidget>(BuildContext context) {
    return context.findAncestorWidgetOfExactType<T>();
  }

  void notifyDependents() {
    var globalKey = this.key as GlobalKey;
    (globalKey.currentContext as StatelessElement).markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) {
    return DependentManager(
      child: this.child,
      notifyDependents: notifyDependents,
    );
  }
}

class ModelStatelessWidget<T> extends DataStatelessWidget {
  final T model;

  static T? of<T extends ModelStatelessWidget>(BuildContext context) {
    return context.findAncestorWidgetOfExactType<T>();
  }

  ModelStatelessWidget({required this.model, required super.child});
}
