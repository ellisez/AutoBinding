import 'dart:convert';

import 'package:example/your_model.dart';
import 'package:flutter/foundation.dart';
import 'package:model_binding/model_binding.dart';

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
  // console see {"a":12,"d":[90,1],"e":{"f":"23","g":"45"}}
  debugPrint(str);

  // model replace data
  var superModel = SuperBinding(mapBinding);// bring default value: "withValueConvert":12
  superModel.nullableString = 'first value';
  // optional - add notify or convert
  superModel.textField("nullableString", convert: (string) => string + '1');
  debugPrint(const JsonEncoder().convert(superModel.export()));
  // console see {"a":12,"b":"34","c":[56,"78"],"d":[90,1],"e":{"f":"23","g":"45"},"nullableString":"first value","withValueConvert":12}
  superModel.dataRebind({// new data maybe from http response or else
    "nullableString": "second value is call by dataRebind()"
  }, isClear: true);// isClear=true all notifiers and converts

  superModel.useDefault();// optional - bring default value: "withValueConvert":12

  debugPrint(const JsonEncoder().convert(superModel.export()));
  // console see {"nullableString":"second value is call by dataRebind()","withValueConvert":12}

  var otherModel = SubBinding();
  superModel.bindTo(otherModel); // Transform different types of models by binding common data MapModels.
  debugPrint(otherModel.nullableString);
  // console see the same as SuperModel.nullableString "second value"
  superModel.nullableString = 'third value is changed from superModel';// change one of bindings other also changed.
  debugPrint(otherModel.nullableString);
  // console see 'third value is changed from superModel'
}