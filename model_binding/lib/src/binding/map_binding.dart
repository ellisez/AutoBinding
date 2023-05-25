part of binding;

class MapBinding<T> with MapMixin<String, T> {
  /// raw map
  late Map<String, dynamic> _data;

  /// notifiers
  Map<String, ValueNotifier> _notifiers = {};

  /// convert of notifier
  Map<String, Convert> _converts = {};

  MapBinding([Map<String, dynamic>? data]) : _data = data ?? {};

  void setData(Map<String, dynamic> data, {bool? isClear}) {
    if (true == isClear) {
      _notifiers.forEach((key, value) {
        value.dispose();
      });
      _notifiers.clear();
      _converts.clear();
    }
    _data = data;
  }

  ValueNotifier? getNotifier(String field) => _notifiers[field];

  setNotifier(String field, ValueNotifier notifier) =>
      _notifiers[field] = notifier;

  ValueNotifier? removeNotifier(String field) => _notifiers.remove(field);

  setConvert(String field, Convert convert) => _converts[field] = convert;

  Convert? removeConvert(String field) => _converts.remove(field);

  @override
  operator [](Object? key) {
    return _data[key];
  }

  @override
  void operator []=(String key, value) {
    var oldValue = _data[key];

    if (oldValue == value) return;
    _data[key] = value;

    var notifier = _notifiers[key];
    if (notifier != null) {
      var toNotifyValue = value;
      var convert = _converts[key];
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

  @override
  void clear() {
    _notifiers.forEach((key, value) {
      value.dispose();
    });
    _data.clear();
    _notifiers.clear();
    _converts.clear();
  }

  @override
  Iterable<String> get keys => _data.keys;

  @override
  remove(Object? key) {
    var item = _data.remove(key);
    _notifiers.remove(key);
    _converts.remove(key);
    return item;
  }

  /// binding for TextField
  TextEditingController textField(
    String field, {
    dynamic value,
    bool retainSelection = true,
    String Function(dynamic)? convert,
  }) {
    if (convert != null) {
      _converts[field] = convert;
    }

    var oldValue = _data[field];
    var newValue = oldValue;
    if (value != null) {
      newValue = value;
      _data[field] = value;
    }

    String getNotifierValue() {
      var toNotifierValue = newValue;
      if (convert != null) {
        toNotifierValue = convert(newValue);
      }
      toNotifierValue ??= '';
      return toNotifierValue;
    }

    var notifier = _notifiers[field];
    if (notifier == null) {
      notifier = TextEditingController(text: getNotifierValue());
      _notifiers[field] = notifier;
    } else {
      if (newValue != oldValue) {
        if (notifier is TextEditingController) {
          var notifierValue = getNotifierValue();
          if (notifierValue != notifier.text) {
            notifier.text = notifierValue;
            var selection = notifier.selection;
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
  void addListener(String field, VoidCallback listener) {
    _notifiers[field]?.addListener(listener);
  }

  void removeListener(String field, VoidCallback listener) {
    _notifiers[field]?.removeListener(listener);
  }

  /// dispose binding
  void dispose() {
    clear();
  }

  /// export data
  Map<String, T> export(
      {Set<String>? includes, Set<String>? excludes, Map<String, T>? target}) {
    var newMap = target ?? <String, T>{};
    for (var entry in _data.entries) {
      var key = entry.key;
      var data = entry.value;
      if (includes != null && !includes.contains(key)) {
        continue;
      }
      if (excludes != null && excludes.contains(key)) {
        continue;
      }
      if (data is ModelBinding) data = data.$export();
      if (data is MapBinding || data is ListBinding) data = data.export();
      newMap[key] = data;
    }
    return newMap;
  }
}

/// model to json string
String modelStringify(dynamic object,
        {Object? Function(Object?)? toEncodable}) =>
    jsonEncode(object, toEncodable: (dynamic item) {
      var result;
      if (toEncodable != null) {
        result = toEncodable(item);
      }
      if (result != null) return result;
      if (item is ModelBinding) return item.$export();
      if (item is MapBinding || item is ListBinding) return item.export();
      if (item is DateTime) {
        var dateString = item.toIso8601String();
        if (!dateString.contains('Z')) {
          dateString += 'Z';
        }
        return dateString;
      }
      return item;
    });

/// export model
dynamic modelExport(dynamic object, {dynamic target}) {
  if (object is List) {
    var list = target ?? [];
    for (var i = 0; i < object.length; i++) {
      var item = object[i];
      list[i] = modelExport(item);
    }
    object = list;
  } else if (object is Map) {
    var map = target ?? {};
    for (var entity in object.entries) {
      map[entity.key] = modelExport(entity.value);
    }
    object = map;
  } else if (object is ModelBinding) {
    object = object.$export();
    if (target != null) {
      object = target.addAll(object);
    }
  } else if (object is MapBinding || object is ListBinding) {
    object = object.export(target: target);
  }
  return object;
}
