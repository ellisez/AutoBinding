# ModelBinding

ModelBinding is a Widget data binding framework implemented using MapModel, and its biggest advantage is that modifying data can automatically refresh corresponding Widgets.

Unlike traditional mvvm frameworks, it does not require the establishment and maintenance of additional bundling relationships. Its core idea is "get and bundle" - which is more in line with data usage habits.

MapModel is currently the most efficient model implementation framework, it uses Map to implement a model.

Map instances only need to determine the method of obtaining fields and control their visibility to obtain different models, such as Entity, VO, DTO, etc., instead of constantly opening up new memory space to move data, reducing unnecessary losses.

## Setup

```yaml
dependencies:
  model_binding: any
  ...

dev_dependencies:
  build_runner: any
  model_binding_builder: any
  ...
```

## Example

```dart
import 'package:map_model/annotation.dart';

part 'your_model.g.dart';

@Model([
  Property<String?>('nullableString', value: '"123"'),
  Property<int>('fixInt'),
  Property('withValueConvert', value: '12', convert: 'convert'),
  Property<List<String?>?>('listWithType'),
  Property<List?>('listNoType'),
  Property<Map<String?, dynamic>?>('mapWithType'),
  Property<Map?>('mapNoType'),
])
class YourModel extends _YourModelImpl {

}

/// custom convert
convert(data) => data.toString();

```
