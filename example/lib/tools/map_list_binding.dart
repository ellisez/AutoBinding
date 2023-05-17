import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:model_binding/binding/binding.dart';

void main() {
  var mapBinding = MapBinding();
  mapBinding['a'] = 12;
  mapBinding['b'] = '34';
  mapBinding['c'] = [56, '78'];

  mapBinding['d'] = ListBinding<int>([90, 01]);// use generic
  mapBinding['e'] = MapBinding<String>({// use generic
    'f' : '23',
    'g' : '45',
  });

  // export offline data
  var export = mapBinding.export(includes: {'a','b', 'd', 'e'}, excludes: {'b'});
  var str = const JsonEncoder().convert(export);
  // console see '{"a":12,"d":[90,1],"e":{"f":"23","g":"45"}}'
  debugPrint(str);

}