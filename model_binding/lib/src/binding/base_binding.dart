part of binding;

typedef Convert = dynamic Function(dynamic);
typedef TextFieldConvert = String Function(dynamic);

/// base ModelBinding class
class ModelBinding {
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
  void $bindTo(ModelBinding other) {
    other.$data = $data;
    other.$validate();
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
  void dispose() => $data.dispose();

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
