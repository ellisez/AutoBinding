part of binding;

/// ListBinding
class ListBinding<T> with ListMixin<T> {
  /// raw list
  late List<dynamic> _list;

  /// notifiers
  List<ValueNotifier?> _notifiers = [];

  /// convert of notifier
  List<Convert?> _converts = [];

  /// ListBinding
  ListBinding([List? list]) : _list = list ?? [];

  void setData(List<dynamic> list, {bool? isClear}) {
    if (true == isClear) {
      _notifiers.forEach((item) => item?.dispose());
      _notifiers.clear();
      _converts.clear();
    }
    _list = list;
  }

  setNotifier(int index, ValueNotifier notifier) =>
      _notifiers[index] = notifier;

  bool? removeNotifier(int index) => _notifiers.remove(index);

  setConvert(int index, Convert convert) => _converts[index] = convert;

  bool? removeConvert(int index) => _converts.remove(index);

  @override
  int get length => _list.length;

  @override
  set length(int newLength) {
    _list.length = newLength;
  }

  @override
  operator [](int index) {
    return _list[index].$data;
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

  /// binding for TextField
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

  /// add change listener
  void addListener(int index, VoidCallback listener) {
    _list[index].notifier?.addListener(listener);
  }

  /// export data
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
      if (data is ModelBinding) data = data.$export();
      if (data is ListBinding || data is MapBinding) data = data.export();
      newList.add(data);
    }
    return newList;
  }

  /// dispose binding
  void dispose() {
    clear();
    _notifiers.forEach((item) => item?.dispose());
    _notifiers.clear();
    _converts.clear();
  }
}
