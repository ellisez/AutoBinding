part of binding;

/// Binder class
class Binder<T> {
  T Function() _getter;
  void Function(T t) _setter;

  Binder(this._getter, this._setter);

  final _notifier = ChangeNotifier();
  final _notifierList = List<ChangeNotifier>.empty(growable: true);

  ChangeNotifier toChangeNotifier() {
    return _notifier;
  }

  VoidCallback bindToListener(VoidCallback listener) {
    _notifier.addListener(listener);
    return listener;
  }

  T bindTo(BuildContext context) {
    _notifier.addListener(() {
      if (context is StatefulElement) {
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        context.state.setState(() {});
      } else {
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        context.findAncestorStateOfType()?.setState(() {});
      }
    });
    return _getter();
  }

  TextEditingController bindToTextEditingController(TextEditingController? controller) {
    // debugPrint(T.name);
    if (controller == null) {
      controller = TextEditingController(text: _getter().toString());
      controller.addListener(() {
        _setter(controller!.text as T);
      });
    } else {
      controller.text = _getter().toString();
    }
    _notifierList.add(controller);

    _notifier.addListener(() {
      var text = _getter().toString();
      if (controller!.text != text) {
        controller.text = text;
      }
    });
    return controller;
  }

  void notifyListeners() {
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    _notifier.notifyListeners();
  }

  void dispose() {
    _notifier.dispose();
    for (var item in _notifierList) {
      item.dispose();
    }
    _notifierList.clear();
  }

}
