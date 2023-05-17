part of binding;

class ListBinding<T> with ListMixin<T> {
  late List<dynamic> _list;
  List<ValueNotifier?> _notifiers = [];
  List<Convert?> _converts = [];

  ListBinding([List? list]):
    _list = list ??[];

  @override
  int get length => _list.length;

  @override
  set length(int newLength) {
    _list.length = newLength;
  }

  @override
  operator [](int index) {
    return _list[index].data;
  }

  @override
  void operator []=(int index, value) {
    var oldValue = _list[index];

    if (oldValue == value) return;
    _list[index] = value;

    var notifier = _notifiers[index];
    if (notifier != null) {
      var toNotifyValue = value;
      var convert = _converts[index];
      if (convert != null) {
        toNotifyValue = convert(value);
      }

      if (notifier is TextEditingController && toNotifyValue is String?) {
        var selection = notifier.selection;
        if (toNotifyValue != null && selection.end >= toNotifyValue.length) {
          selection = TextSelection.collapsed(offset: toNotifyValue.length);
        }
        notifier.text = toNotifyValue ?? '';
        notifier.selection = selection;
      } else {
        notifier.value = toNotifyValue;
      }
    }
  }

  TextEditingController textField(
      int index, {
        dynamic value,
        bool retainSelection = true,
        String Function(dynamic)? convert,
      }) {
    if (convert != null) {
      _converts[index] = convert;
    }

    var oldValue = _list[index];
    var newValue = oldValue;
    if (value != null) {
      newValue = value;
      _list[index] = value;
    }

    String getNotifierValue() {
      var toNotifierValue = newValue;
      if (convert != null) {
        toNotifierValue = convert(newValue);
      }
      toNotifierValue ??= '';
      return toNotifierValue;
    }

    var notifier = _notifiers[index];
    if (notifier == null) {
      notifier = TextEditingController(text: getNotifierValue());
      _notifiers[index] = notifier;
    } else {
      if (newValue != oldValue) {
        if (notifier is TextEditingController) {
          var notifierValue = getNotifierValue();
          if (notifierValue != notifier.text) {
            var selection = notifier.selection;
            notifier.text = notifierValue;
            if (retainSelection) {
              if (selection.end >= notifierValue.length) {
                selection =
                    TextSelection.collapsed(offset: notifierValue.length);
              }
              notifier.selection = selection;
            }
          }
        }
      }
    }
    return notifier as TextEditingController;
  }

  void addListener(int index, VoidCallback listener) {
    _list[index].notifier?.addListener(listener);
  }

  List<T> export({Set<int>? includes, Set<int>? excludes}) {
    var newList = <T>[];
    for (var i = 0; i < _list.length; i++) {
      var data = _list[i];
      if (includes != null && !includes.contains(i)) {
        continue;
      }
      if (excludes != null && excludes.contains(i)) {
        continue;
      }
      if (data is ListBinding) data=data.export();
      if (data is MapBinding) data=data.export();
      newList.add(data);
    }
    return newList;
  }

  void dispose() {
    clear();
  }
}