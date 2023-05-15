library model_binding_builder;


import 'package:build/build.dart';
import 'package:map_model_builder/generator/map_model.dart';
import 'package:source_gen/source_gen.dart';

import 'model_binding.dart';

Builder modelBindingBuilder(BuilderOptions options) =>
    SharedPartBuilder([ModelBindingGenerator(), /*MapModelGenerator()*/], 'model_binding');

