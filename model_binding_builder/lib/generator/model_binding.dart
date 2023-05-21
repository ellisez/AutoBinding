import 'package:map_model_builder/src/base_generator.dart';
import 'package:map_model_builder/src/resolve_info.dart';
import 'package:model_binding/annotation/annotation.dart';

/// ModelBindingGenerator
class ModelBindingGenerator extends BaseGenerator<Binding> {
  /// mapClass
  @override
  String get mapClass => 'MapBinding';

  /// superClass
  @override
  String get superClass => 'ModelBinding';

  /// genExport
  @override
  String genExport(String exportString, Set<PropertyInfo> propertySet,
      Set<ConvertInfo> convertSet) {
    String include = '';
    for (var propertyInfo in propertySet) {
      if (include.isNotEmpty) {
        include += ',';
      }
      include += "'${propertyInfo.propertyName}'";
    }

    if (include.isNotEmpty) {
      include = 'includes: {$include},';
    }
    if (exportString.isNotEmpty) {
      return '''
      @override
      Map<String, dynamic> \$export() {
        var map = super.\$export();
        \$data.export($include target: map);
        return map;
      }
      ''';
    }
    return '';
  }
}
