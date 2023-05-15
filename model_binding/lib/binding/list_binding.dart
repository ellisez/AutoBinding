part of binding;

class ListBinding<T> with ListMixin<T> {
  late List<Ref> _list;

  ListModel([List? list]) {
    _list = [];
    if (list != null) {
      for (var item in list) {
        _list.add(Ref(item));
      }
    }
  }

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
    var ref = _list[index];

    var notifier = ref.notifier;
    if (notifier != null) {
      var convert = ref.convert;
      var val = value;
      if (convert != null) {
        val = convert(value);
      }

      if (notifier is TextEditingController && val is String?) {
        var selection = notifier.selection;
        if (val != null  && selection.end >= val.length) {
          selection = TextSelection.collapsed(offset: val.length);
        }
        notifier.text = val ?? '';
        notifier.selection = selection;
      } else {
        notifier.value = val;
      }
    }
    ref.data = value;
  }

  TextEditingController textField(
      int index, {
        dynamic value,
        bool retainSelection = true,
        String Function(dynamic)? convert,
      }) {
    var val = value;
    if (convert != null) val = convert(value);

    var ref = _list[index];
    var notifier = ref.notifier;
    if (notifier == null) {
      notifier = TextEditingController(text: val);
    } else if (ref.data != value) {
      if (notifier is TextEditingController) {
        if (val != notifier.text) {
          var selection = notifier.selection;
          notifier.text = val ?? '';
          if (retainSelection) {
            if (val != null && selection.end >= val.length) {
              selection = TextSelection.collapsed(offset: val.length);
            }
            notifier.selection = selection;
          }
        }
      }
    }
    if (ref.convert != convert) {
      ref.convert = convert;
    }
    if (ref.data != value) {
      ref.data = value;
    }
    return notifier as TextEditingController;
  }

  void addListener(int index, VoidCallback listener) {
    _list[index].notifier?.addListener(listener);
  }

  List<T> export({Set<int>? includes, Set<int>? excludes}) {
    var newList = <T>[];
    for (var i = 0; i < _list.length; i++) {
      var item = _list[i];
      if (includes != null && !includes.contains(i)) {
        continue;
      }
      if (excludes != null && excludes.contains(i)) {
        continue;
      }
      var data = item.data;
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