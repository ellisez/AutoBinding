import 'dart:convert';

import 'package:example/your_model.dart';
import 'package:flutter/foundation.dart';
import 'package:model_binding/model_binding.dart';

void main() {
  var mapBinding = MapBinding();
  mapBinding['a'] = 12;
  mapBinding['b'] = '34';
  mapBinding['c'] = [56, '78'];

  mapBinding['d'] = ListBinding<int>([90, 01]); // use generic
  mapBinding['e'] = MapBinding<String>({
    // use generic
    'f': '23',
    'g': '45',
  });

  // export offline data
  var export =
      mapBinding.export(includes: {'a', 'b', 'd', 'e'}, excludes: {'b'});
  var str = const JsonEncoder().convert(export);
  // console see {"a":12,"d":[90,1],"e":{"f":"23","g":"45"}}
  debugPrint(str);

  // default convert type
  mapBinding['listWithType'] =
      'a b c'; // auto convert, List<String> default sep is ' '
  mapBinding['dateTime'] =
      '2023-05-19'; // auto convert, DateTime accept String & int
  // model replace data
  var superModel =
      SuperBinding(mapBinding); // bring default value: "withValueConvert":12
  superModel.nullableString = 'first value';
  // optional - add notify or convert
  superModel.textField("nullableString", convert: (string) => string + '1');
  debugPrint(modelStringify(superModel.$export()));
  // console see {"nullableString":"first value","fixInt":null,"withValueConvert":12,"listWithType":["a","b","c"],"listNoType":null,"mapWithType":null,"mapNoType":null,"dateTime":"2023-05-19T00:00:00.000"}
  superModel.$rebind({
    // new data maybe from http response or else
    "nullableString": "second value is call by dataRebind()"
  }, isClear: true); // isClear=true all notifiers and converts

  superModel
      .$default(); // optional - bring default value: "withValueConvert":12

  debugPrint(modelStringify(superModel));
  // console see {"nullableString":"second value is call by dataRebind()","fixInt":null,"withValueConvert":12,"listWithType":null,"listNoType":null,"mapWithType":null,"mapNoType":null,"dateTime":null}

  var otherModel = SubBinding();
  superModel.$bindTo(
      otherModel); // Transform different types of models by binding common data MapModels.
  debugPrint(otherModel.nullableString);
  // console see the same as SuperModel.nullableString "second value"
  superModel.nullableString =
      'third value is changed from superModel'; // change one of bindings other also changed.
  debugPrint(otherModel.nullableString);
  // console see 'third value is changed from superModel'
}
