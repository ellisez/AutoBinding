import 'package:map_model_builder/generator/base.dart';
import 'package:model_binding/annotation/annotation.dart';

class ModelBindingGenerator extends BaseGenerator<ModelBinding> {
  @override
  String get mapClass => 'MapBinding';

  @override
  String get superClass => 'extends Binding';

}