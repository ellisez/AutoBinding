part of binding;

typedef Convert = dynamic Function(dynamic);
typedef TextFieldConvert = String Function(dynamic);

abstract class Binding {
  late MapBinding _data;

  Binding(this._data);

  TextEditingController textField(
    String field, {
    dynamic value,
    bool retainSelection = true,
    String Function(dynamic)? convert,
  }) =>
      _data.textField(field,
          value: value, retainSelection: retainSelection, convert: convert);

  void addListener(String field, VoidCallback listener) {
    _data.addListener(field, listener);
  }

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
