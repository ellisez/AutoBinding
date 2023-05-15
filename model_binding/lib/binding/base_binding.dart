part of binding;

typedef TextFieldConvert = String Function(dynamic);

abstract class Binding {
  final MapBinding _data;

  Binding(this._data);

  TextEditingController textField(
    String field, {
    dynamic value,
    bool retainSelection = true,
    String Function(dynamic)? convert,
  }) =>
      _data.textField(field,
          value: value, retainSelection: retainSelection, convert: convert);

  Map<String, dynamic> export() => _data.export();

  void dispose() => _data.dispose();
}

String Function(dynamic num) intConvert({String nullValue = ''}) {
  return (intValue) => intValue == null ? nullValue : intValue.toString();
}

String Function(dynamic stringList) stringListConvert(
    {String nullValue = '', String sep = ' '}) {
  return (stringList) => stringList == null ? nullValue : stringList.join(sep);
}

class Ref {
  dynamic data;
  ValueNotifier? notifier;
  dynamic Function(dynamic)? convert;

  Ref(this.data, {this.notifier, this.convert});
}
