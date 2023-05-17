import 'dart:convert';

import 'package:example/your_model.dart';
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
  // console see {"a":12,"d":[90,1],"e":{"f":"23","g":"45"}}
  debugPrint(str);

  // model replace data
  var yourModel = YourBinding(mapBinding);// bring default value: "withValueConvert":12
  yourModel.nullableString = 'first value';
  // optional - add notify or convert
  yourModel.textField("nullableString", convert: (string) => string + '1');
  debugPrint(const JsonEncoder().convert(yourModel.export()));
  // console see {"a":12,"b":"34","c":[56,"78"],"d":[90,1],"e":{"f":"23","g":"45"},"nullableString":"first value","withValueConvert":12}
  yourModel.rebind({// new data maybe from http response or else
    "nullableString": "second value"
  }, isClear: true);// isClear=true all notifiers and converts

  yourModel.useDefault();// optional - bring default value: "withValueConvert":12

  debugPrint(const JsonEncoder().convert(yourModel.export()));
  // console see {"nullableString":"second value","withValueConvert":12}
}