part of binding;

class MapBinding<T> with MapMixin<String, T> {
  late Map<String, Ref> _data;

  MapBinding([Map<String, dynamic>? data]) {
    _data = {};
    if (data != null) {
      data.forEach((key, value) {
        _data[key] = Ref(value);
      });
    }
  }

  @override
  operator [](Object? key) {
    var ref = _data[key];
    if (ref != null) {
      return ref.data;
    }
    return null;
  }

  @override
  void operator []=(String key, value) {
    var ref = _data[key];
    if (ref == null) {
      ref = Ref(value);
      _data[key] = ref;
      return;
    }

    var notifier = ref.notifier;
    if (notifier != null) {
      var val = value;
      var getter = ref.convert;
      if (getter != null) {
        val = getter(value);
      }
      if (notifier is TextEditingController && val is String?) {
        var selection = notifier.selection;
        if (val != null && selection.end >= val.length) {
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

  @override
  void clear() {
    _data.forEach((key, value) {
      if (value.notifier != null) {
        value.notifier!.dispose();
      }
    });
    _data.clear();
  }

  @override
  Iterable<String> get keys => _data.keys;

  @override
  remove(Object? key) {
    var item = _data.remove(key);
    if (item != null && item.notifier != null) {
      item.notifier!.dispose();
    }
    return item?.data;
  }

  TextEditingController textField(
      String field, {
        dynamic value,
        bool retainSelection = true,
        String Function(dynamic)? convert,
      }) {
    var ref = _data[field];
    if (value == null && ref != null) {
      value = ref.data;
    }
    var convertValue = value;
    if (convert != null) {
      convertValue = convert(value);
    }
    convertValue ??= '';

    if (ref == null) {
      var notifier = TextEditingController(text: convertValue);
      ref = Ref(value, notifier: notifier, convert: convert);
      _data[field] = ref;
      return notifier;
    }
    var notifier = ref.notifier;
    if (notifier == null) {
      notifier = TextEditingController(text: convertValue);
      ref.notifier = notifier;
    } else {
      if (notifier is TextEditingController) {
        if (convertValue != notifier.text) {
          var selection = notifier.selection;
          notifier.text = convertValue ?? '';
          if (retainSelection) {
            if (convertValue != null && selection.end >= convertValue.length) {
              selection = TextSelection.collapsed(offset: convertValue.length);
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

  void addListener(String key, VoidCallback listener) {
    _data[key]?.notifier?.addListener(listener);
  }

  void dispose() {
    clear();
  }

  Map<String, T> export({Set<String>? includes, Set<String>? excludes}) {
    var newMap = <String, T>{};
    for (var entry in _data.entries) {
      var key = entry.key;
      var ref = entry.value;
      if (includes != null && !includes.contains(key)) {
        continue;
      }
      if (excludes != null && excludes.contains(key)) {
        continue;
      }
      var data = ref.data;
      if (data is ListBinding) data=data.export();
      if (data is MapBinding) data=data.export();
      newMap[key] = data;
    }
    return newMap;
  }
}

String modelStringify(dynamic object) =>
    jsonEncode(object, toEncodable: (dynamic item) {
      if (item is MapBinding) return item.export();
      return item;
    });

dynamic modelExport(dynamic object) {
  if (object is List) {
    for (var i = 0; i < object.length; i++) {
      var item = object[i];
      object[i] = modelExport(item);
    }
  } else if (object is Map) {
    for (var entity in object.entries) {
      object[entity.key] = modelExport(entity.value);
    }
  } else if (object is MapBinding) {
    return object.export();
  }
  return object;
}
