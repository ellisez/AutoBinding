library model_binding_builder;


import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'generator/model_binding.dart';

Builder modelBindingBuilder(BuilderOptions options) =>
    SharedPartBuilder([ModelBindingGenerator()], 'model_binding');

