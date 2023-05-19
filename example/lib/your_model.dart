import 'package:model_binding/model_binding.dart';

part 'your_model.g.dart';

@Model([
  Property<String?>('nullableString', value: '"123"'),
  Property<int>('fixInt'),
  Property('withValueConvert', value: '12'),
  Property<List<String>?>('listWithType'),
  Property<List?>('listNoType'),
  Property<Map<String?, dynamic>?>('mapWithType'),
  Property<Map?>('mapNoType'),
  Property<DateTime>('dateTime'),
])
class YourModel extends _YourModelImpl {
  YourModel([super.data]);
}

@Binding([
  Property<String?>('nullableString', value: '"123"'),
  Property<int>('fixInt'),
  Property('withValueConvert', value: '12'),
  Property<List<String>?>('listWithType'),
  Property<List?>('listNoType'),
  Property<Map<String?, dynamic>?>('mapWithType'),
  Property<Map?>('mapNoType'),
  Property<DateTime>('dateTime'),
], converts: {
  Map<String?, dynamic>: 'castMap',
})
class SuperBinding extends _SuperBindingImpl {
  SuperBinding([super.data]);
}

@Binding([
  Property<String>('subProperty', value: '"default subProperty"'),
])
class SubBinding extends SuperBinding with _SubBindingMixin {
  SubBinding([super.data]);
}

Map<String?, dynamic> castMap(String property, dynamic value) {
  if (property == 'mapWithType') {
    // hit Field
  }
  return value;
}
