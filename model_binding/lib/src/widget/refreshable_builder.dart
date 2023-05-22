part of binding;

class RefreshableBuilder extends StatefulWidget {
  final WidgetBuilder builder;

  RefreshableBuilder({required this.builder});

  static T? of<T extends RefreshableBuilderState>(BuildContext context) {
    if (context is StatefulElement) {
      var state = context.state;
      if (state is T) {
        return state;
      }
    }
    return context.findAncestorStateOfType<T>();
  }

  static bool rebuild<T extends RefreshableBuilderState>(BuildContext context) {
    State? state;
    for (;;) {
      state = context.findAncestorStateOfType();
      if (state == null) {
        return false;
      }
      if (state is RefreshableBuilderState) {
        state._rebuild();
        return true;
      } else if (state is BindingState) {
        state._rebuild();
        return true;
      }
      context = state.context;
    }
  }

  @override
  State<StatefulWidget> createState() => RefreshableBuilderState();
}

class RefreshableBuilderState extends State<RefreshableBuilder> {
  @override
  Widget build(BuildContext context) => widget.builder(context);

  _rebuild() => this.setState(() {});
}

mixin BindingSupport<W extends StatefulWidget, T extends ModelBinding>
    on State<W> {
  T get binding;

  static T? of<T extends BindingSupport>(BuildContext context) {
    if (context is StatefulElement) {
      var state = context.state;
      if (state is T) {
        return state;
      }
    }
    return context.findAncestorStateOfType<T>();
  }

  @override
  void dispose() {
    binding.dispose();
    super.dispose();
  }
}

abstract class BindingState<W extends StatefulWidget, T extends ModelBinding>
    extends State<W> with BindingSupport<W, T> {
  _rebuild() => this.setState(() {});
}
