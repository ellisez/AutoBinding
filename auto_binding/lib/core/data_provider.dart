import 'package:flutter/widgets.dart';

import 'data_inject.dart';
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
      _child = Builder(
          builder: builder,
      );
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
  void didUpdateWidget(ModelStatefulWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    model = widget.model;
  }

  @override
  void initState() {
    model = widget.model;
    super.initState();
  }

  @override
  Widget builder(BuildContext context) => widget.child;
}

class _ChildWidget extends StatefulWidget {
  final Widget child;

  _ChildWidget({required this.child});

  @override
  State<StatefulWidget> createState() => _ChildState();
}

class _ChildState extends State<_ChildWidget> {
  Widget? _child;

  Widget _build(BuildContext context) {
    if (_child == null) {
      _child = widget.child;
    }
    return _child!;
  }

  @override
  Widget build(BuildContext context) => _build(context);
}

abstract class DataStatelessWidget extends StatelessWidget
    implements ShouldNotifyDependents {
  DataStatelessWidget() : super(key: GlobalKey());

  static T? of<T extends DataStatelessWidget>(BuildContext context) {
    return context.findAncestorWidgetOfExactType<T>();
  }

  void notifyDependents() {
    var globalKey = this.key as GlobalKey;
    (globalKey.currentContext as StatelessElement).markNeedsBuild();
  }

  Widget builder(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return DependentManager(
      child: _ChildWidget(
        child: Builder(
          builder: builder,
        ),
      ),
      notifyDependents: notifyDependents,
    );
  }
}

class ModelStatelessWidget<T> extends DataStatelessWidget {
  final T model;
  final Widget child;

  static T? of<T extends ModelStatelessWidget>(BuildContext context) {
    return context.findAncestorWidgetOfExactType<T>();
  }

  ModelStatelessWidget({required this.model, required this.child});

  @override
  Widget builder(BuildContext context) => this.child;
}
