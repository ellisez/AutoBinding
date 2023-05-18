import 'package:map_model_builder/src/base_generator.dart';
import 'package:model_binding/annotation/annotation.dart';

class ModelBindingGenerator extends BaseGenerator<Binding> {
  @override
  String get mapClass => 'MapBinding';

  @override
  String get superClass => 'ModelBinding';

}