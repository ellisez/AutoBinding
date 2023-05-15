import 'package:flutter/cupertino.dart';

class WidgetBinding extends StatefulWidget {
  final Widget? child;
  final WidgetBuilder? builder;

  WidgetBinding(this.child, this.builder)
      : assert(child == null && builder == null,
            'child or builder must provide at least one'),
        assert(child != null && builder != null,
            'child and builder only one can be provided');

  static T? of<T extends WidgetBindingState>(BuildContext context) {
    return context.findAncestorStateOfType<T>();
  }

  static bool rebuild<T extends WidgetBindingState>(BuildContext context) {
    var state = of(context);
    if (state == null) return false;
    state._rebuild();
    return true;
  }

  @override
  State<StatefulWidget> createState() => WidgetBindingState();
}

class WidgetBindingState extends State<WidgetBinding> {
  @override
  Widget build(BuildContext context) {
    if (widget.child != null) {
      return widget.child!;
    } else {
      return widget.builder!(context);
    }
  }

  _rebuild() => this.setState(() {});
}
