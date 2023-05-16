part of binding;

class RefreshableBuilder extends StatefulWidget {
  final WidgetBuilder builder;

  RefreshableBuilder({required this.builder});

  static T? of<T extends RefreshableBuilderState>(BuildContext context) {
    return context.findAncestorStateOfType<T>();
  }

  static bool rebuild<T extends RefreshableBuilderState>(BuildContext context) {
    var state = of(context);
    if (state == null) return false;
    state._rebuild();
    return true;
  }

  @override
  State<StatefulWidget> createState() => RefreshableBuilderState();
}

class RefreshableBuilderState extends State<RefreshableBuilder> {

  @override
  Widget build(BuildContext context) => widget.builder(context);

  _rebuild() => this.setState(() {});
}

mixin BindingSupport<W extends StatefulWidget, T extends Binding> on State<W> {
  T get binding;

  @override
  void dispose() {
    binding.dispose();
    super.dispose();
  }
}