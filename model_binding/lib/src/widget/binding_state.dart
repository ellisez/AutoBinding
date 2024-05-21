import 'package:flutter/cupertino.dart';
import 'package:model_binding/model_binding.dart';

abstract class BindingState<M extends ViewModel, T extends StatefulWidget> extends State<T> {
  M get data;

  @override
  void didUpdateWidget(T oldWidget) {
    data.didUpdateWidget(oldWidget, widget);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    data.dispose(this);
    super.dispose();
  }
}
