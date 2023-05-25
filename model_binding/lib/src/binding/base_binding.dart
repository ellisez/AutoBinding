part of binding;

typedef Convert = dynamic Function(dynamic);
typedef TextFieldConvert = String Function(dynamic);

enum NotifierType { textField, valueNotifier }

/// base ModelBinding class
abstract class ModelBinding {
  Map<String, Set<VoidCallback>> _syncCallback = {};

  /// do not use it out of subclass.
  @protected
  // ignore: non_constant_identifier_names
  late MapBinding $data;

  /// base ModelBinding class
  ModelBinding([Map<String, dynamic>? data]) {
    if (data is MapBinding) {
      $data = data;
    } else {
      $data = MapBinding(data ?? {});
    }
    $default();
    $validate();
  }

  /// rebind data
  void $rebind(Map<String, dynamic> data, {bool? isClear}) {
    this.$data.setData(data, isClear: isClear);
    $validate();
  }

  /// bind to another model
  ModelBinding $bindTo(ModelBinding other) {
    other.$data = $data;
    other.$validate();
    return this;
  }

  /// sync to context
  ModelBinding $sync({
    BuildContext? context,
    required List<String> fields,
    VoidCallback? callback,
    NotifierType notifierType = NotifierType.valueNotifier,
  }) {
    if (context == null && callback == null) {
      throw AssertionError('context and callback have at least one value');
    }
    if (context != null && callback != null) {
      throw AssertionError(
          'context and callback cannot have values at the same time');
    }

    VoidCallback? listener = callback;
    if (context != null) {
      listener = () {
        if (context is StatefulElement) {
          // ignore: invalid_use_of_protected_member
          context.state.setState(() {});
        }
      };
    }

    for (var field in fields) {
      var callbacks = _syncCallback[field];
      if (callbacks == null) {
        callbacks = {};
        _syncCallback[field] = callbacks;
      }
      callbacks.add(listener!);
      var notifier = $data.getNotifier(field);
      if (notifier == null) {
        if (notifierType == NotifierType.textField) {
          notifier = TextEditingController(text: $data[field]);
        } else {
          notifier = ValueNotifier($data[field]);
        }
        $data.setNotifier(field, notifier);
      }
      notifier.addListener(listener);
    }
    return this;
  }

  /// bind + sync
  $bindSync(
    ModelBinding other, {
    BuildContext? context,
    required List<String> fields,
    VoidCallback? callback,
        NotifierType notifierType = NotifierType.valueNotifier,
  }) {
    $bindTo(other);
    $sync(
        fields: fields,
        context: context,
        callback: callback,
        notifierType: notifierType,
    );
    return this;
  }

  /// binding for TextField
  TextEditingController textField(
    String field, {
    dynamic value,
    bool retainSelection = true,
    String Function(dynamic)? convert,
  }) =>
      $data.textField(field,
          value: value, retainSelection: retainSelection, convert: convert);

  /// add change listener
  void addListener(String field, VoidCallback listener) {
    $data.addListener(field, listener);
  }

  /// field types
  Map<String, Type> $types() => {};

  /// field default value
  void $default() {}

  /// validate field value
  void $validate() {}

  /// export data
  Map<String, dynamic> $export() => {};

  /// dispose binding
  void dispose() {
    for (var entry in _syncCallback.entries) {
      var field = entry.key;
      var callbacks = entry.value;

      var notifier = $data.getNotifier(field);
      if (notifier != null) {
        for (var cb in callbacks) {
          $data.removeListener(field, cb);
        }
      }
    }
    _syncCallback.clear();
  }

  /// get BindingSupport
  static B? of<T extends BindingSupport, B extends ModelBinding>(
      BuildContext context) {
    if (context is StatefulElement) {
      var state = context.state;
      if (state is T) {
        return state.binding as B;
      }
    }
    return context.findAncestorStateOfType<T>()?.binding as B?;
  }
}

/// int convert
String Function(dynamic num) intConvert({String nullValue = ''}) {
  return (intValue) => intValue == null ? nullValue : intValue.toString();
}

/// stringList convert
String Function(dynamic stringList) stringListConvert(
    {String nullValue = '', String sep = ' '}) {
  return (stringList) => stringList == null ? nullValue : stringList.join(sep);
}
