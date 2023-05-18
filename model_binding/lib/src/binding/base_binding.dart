part of binding;

typedef Convert = dynamic Function(dynamic);
typedef TextFieldConvert = String Function(dynamic);

abstract class ModelBinding {
  @protected
  // ignore: non_constant_identifier_names
  late MapBinding $_data;

  ModelBinding([MapBinding? data]) : $_data = data ?? MapBinding({}) {
    useDefault();
  }

  void dataRebind(Map<String, dynamic> data, {bool? isClear}) =>
      this.$_data.setData(data, isClear: isClear);

  void bindTo(ModelBinding other) {
    other.$_data = $_data;
  }

  TextEditingController textField(
    String field, {
    dynamic value,
    bool retainSelection = true,
    String Function(dynamic)? convert,
  }) =>
      $_data.textField(field,
          value: value, retainSelection: retainSelection, convert: convert);

  void addListener(String field, VoidCallback listener) {
    $_data.addListener(field, listener);
  }

  void useDefault() {}

  Map<String, dynamic> export() => {};

  void dispose() => $_data.dispose();

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

String Function(dynamic num) intConvert({String nullValue = ''}) {
  return (intValue) => intValue == null ? nullValue : intValue.toString();
}

String Function(dynamic stringList) stringListConvert(
    {String nullValue = '', String sep = ' '}) {
  return (stringList) => stringList == null ? nullValue : stringList.join(sep);
}
