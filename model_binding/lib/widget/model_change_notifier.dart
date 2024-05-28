import 'package:flutter/widgets.dart';

import 'model_inject.dart';

abstract class ShouldNotifyDependents {
  void notifyDependents();
}

class DependentIsChange<P extends ShouldNotifyDependents,T> {
  Ref<P, T> binder;
  T value;

  bool isChange(Element element) {
    var provider = binder.findProvider(element);
    var oldValue = value;
    value = binder.getter(provider);
    return value != oldValue;
  }

  DependentIsChange({required this.binder, required this.value});
}
