import 'package:map_model_builder/src/base_generator.dart';
import 'package:model_binding/annotation/annotation.dart';

class ModelBindingGenerator extends BaseGenerator<Binding> {
  @override
  String get mapClass => 'MapBinding';

  @override
  String get superClass => 'ModelBinding';

  @override
  String genExport(String exportString) {
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