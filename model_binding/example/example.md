
# ModelBinding

[`en`](https://github.com/ellisez/ModelBinding/blob/master/README.md) [`cn`](https://github.com/ellisez/ModelBinding/blob/master/README-ZH_CN.md)

ModelBinding是一个使用MapModel实现的Widget数据绑定框架，其最大的优点是修改数据可以自动刷新相应的Widget。

与传统的mvvm框架不同，它不需要建立和维护额外的绑定关系。它的核心思想是“获取即捆绑”，这更符合数据使用习惯。

[MapModel](https://pub.flutter-io.cn/packages/map_model) 是目前最高效的模型实现框架，它使用Map来实现模型。

Map实例只需要确定获取字段的方法并控制其可见性，即可获得不同的模型，如Entity、VO、DTO等，而无需不断打开新的内存空间来移动数据，减少不必要的损失。

## Setup

```shell
flutter pub add model_binding
flutter pub add build_runner --dev
flutter pub add model_binding_builder --dev
```

or

```yaml
dependencies:
  model_binding: any
  ...

dev_dependencies:
  build_runner: any
  model_binding_builder: any
  ...
```

## Lints

### analysis_options.yaml
```yaml
include: package:model_binding/lints.yaml

```

## Example

### model

provided `@Model` `@ModelBinding` annotation

[@Model]() can use for Map as Model, like Entity, Vo, Dto. see [MapModel](https://pub.flutter-io.cn/packages/map_model)

[@ModelBinding]() can use for Map to Binding flutter Widget, Implementing bidirectional binding.

也就是说，修改值的界面将被部分刷新，在参考点显示值，控制输入也将更改新值并被通知。

```dart
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


```

- `@Model.converts` 定义类型的转换器, 参见默认支持类型: List<String>, int, double, DateTime
- 使用类继承的方式: _${yourClassName}Impl, 因为单继承的要求，占用的话可以考虑用mixin。
- 使用mixin混入方式: _${yourClassName}Mixin; 必须要继承ModelBinding和它的子类。


### Model transformation

```dart
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

```

- `$types` 显示所有字段类型.
- `export()`: 只会输出被注解定义过的数据项。 并且输出结果脱离模型同步。
- `dataRebind()`: 重新绑定数据便于整块替换. 如HTTP返回数据。
- `bindTo()`: 用于绑定另一个Model使之数据得以同步. 通常用于类型完全不同的模型间转换，如ViewModel转Http Param.
- 你有两种机会让与产生同步，第一种是构造实例时传入的数据项，第二种就是调用dataRebind()或BindTo()方法.

框架会保证外部对共享数据可见性, 避免直接对物理数据进行操作. 但在子类中, 物理数据是可以被直接访问的.

一般而言，我们允许整块数据替换，禁止非声明的数据项访问。整块替换可类比为传统的new一个模型类，禁止访问未被声明的字段类比为模型里没有定义字段。


### use ModelBinding

<img src="https://raw.githubusercontent.com/ellisez/ModelBinding/master/resources/data_binding.gif">

example provide 3 widget binding methods:
- `Raw Widget`: use flutter raw widget add parameter
```dart
/// controller and onChanged must be provided
TextField(
controller: dataBinding.textField('nullableString'),// must be
onChanged: (value) {// must be
dataBinding.nullableString = value;
setState(() {});
},
);
```
- `Minimum Binding`: use Binding class, only refresh controller
```dart
/// use default context, that Binding class self context
TextFieldBinding(
binding: dataBinding,
property: 'nullableString',
);
```
- `Custom Binding`: use Binding class, specify context

```dart
/// use special context control refresh range
TextFieldBinding(
binding: dataBinding,
property: 'nullableString',
context: context,
);
```

context in Binding class, can be partially refreshed.


### Cross level call

<img src="https://raw.githubusercontent.com/ellisez/ModelBinding/master/resources/sync_binding.gif">

```dart

class SyncWidgetBinding extends StatefulWidget {
  const SyncWidgetBinding({super.key});

  @override
  State<StatefulWidget> createState() => SyncWidgetBindingState();
}

class SyncWidgetBindingState
    extends BindingState<SyncWidgetBinding, SuperBinding> {
  /// BindingState Can be found by subWidget
  @override
  SuperBinding binding = SuperBinding();

  @override
  void initState() {
    super.initState();

    /// binding super widget
    binding.$sync(
      fields: ['nullableString'],
      callback: () {
        setState(() {});
      },
      notifierType: NotifierType.textField,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Cross level call',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text('sync in SupperWidget:'),
            SizedBox(
              width: 150,
              child: TextFieldBinding(
                binding: binding,
                property: 'nullableString',
                //context: context, // base on from
              ),
            ),
            const Divider(),
            const SubWidget(),
          ],
        ),
      ),
    );
  }
}

class SubWidget extends StatefulWidget {
  const SubWidget({super.key});

  @override
  State<StatefulWidget> createState() => SubWidgetState();
}

class SubWidgetState extends State<SubWidget> {
  SubBinding subBinding = SubBinding();

  @override
  void initState() {
    super.initState();

    /// binding sub widget
    ModelBinding.of<SyncWidgetBindingState, SuperBinding>(context)?.$bindSync(
      subBinding,
      context: context,
      fields: ['nullableString'],
      notifierType: NotifierType.textField,

      /// support TextField
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('sync in SubWidget:'),
        SizedBox(
          width: 100,
          child: TextFieldBinding(
            binding: subBinding,
            property: 'nullableString',
            //context: context, // base on from
          ),
        ),
      ],
    );
  }
}
```

- `$bindTo()` 仅同步数据.
- `$sync()` 可以同步数据改变的事件.
- `$sync(context)` 可以刷新context所在的Widget.
- `$sync(callback)` 自定义数据改变事件, 需要自行调用setState().
- `$sync(fields)` 罗列需同步的字段.
- `$sync(notifierType)` `NotifierType.textField` 可以支持TextField控件.

### use WidgetBinding

<img src="https://raw.githubusercontent.com/ellisez/ModelBinding/master/resources/widget_binding.gif">

```dart
@override
Widget build(BuildContext context) => Scaffold(
  appBar: AppBar(
    automaticallyImplyLeading: true,
    title: const Text('Widget src.binding'),
  ),
  body: Center(
    child: Column(
      children: [
        RefreshableBuilder(
          builder: (context) => Column(
            children: [
              RadioListTile<RefreshMode>(
                  title: const Text('self: only control rebuild'),
                  value: RefreshMode.self,
                  groupValue: mode,
                  onChanged: (value) {
                    mode = value!;
                    setState(() {});
                  }),
              RadioListTile<RefreshMode>(
                  title: const Text('partially: find RefreshableBuilder to rebuild'),
                  value: RefreshMode.partially,
                  groupValue: mode,
                  onChanged: (value) {
                    mode = value!;
                    setState(() {});
                  }),
              const Text(
                'Both self and partially based on context arguments',
                style: TextStyle(),
              ),
              const Divider(),
              Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                child: TextFieldBinding(
                  binding: binding,
                  property: 'nullableString',
                  mode: mode,
                  //context: context, // base on from
                ),
              ),
              Text('partially refresh point：${binding.nullableString ?? ''}'),
            ],
          ),
        ),
        ElevatedButton(
            onPressed: () {
              setState(() {});
            },
            child: const Text('refresh outside')),
        Text('outside refresh point：${ModelBinding.of<WidgetBindingState, SuperBinding>(context)?.nullableString ?? ''}'),
      ],
    ),
  ),
);
```

- `RefreshableBuilder`类似InheritedWidget, 主要用于提供局部刷新点.
- `TextFieldBinding.mode`  `RefreshMode.self` only refresh control self; `RefreshMode.partially` base on context find RefreshableBuilder.
- `TextFieldBinding.context` ==如果刷新的范围太小, 可以考虑把context放到更高层级==



### Advanced
- `addListener` be called when value has Changed. need `dispose()` release. but not recommended.
- `RefreshableBuilder.of(context)` 可以获得RefreshableBuilder实例.
- `RefreshableBuilder.rebuild(context)` 可以局部刷新ui.
- `BindingSupport` 可以mixin快速建立绑定模型. `mixin`
- `BindingState` 可以刷新并且绑定数据 `class`
- `BindingSupport.of(context)` 获得被混入BindingSupport的State实例.
- `ModelBinding.of(context)` 获得绑定的model实例. 等同于`BindingSupport.of(context).bind`

Widget Tree跨层时使用ModelBinding.of(context)能够快速的获取模型数据。
## Generate

```shell
flutter pub run build_runner build
```
or

```shell
dart run build_runner build
```

## ModelBinding vs Provider vs Get_it

Provider框架提供了优秀的Consumer实用程序类，但不幸的是，数据绑定需要创建大量的Provider子类，如ChangeNotificationerProvider、ListenableProvider、ValueListenableProvider和StreamProvider等。这种机制被称为状态管理，尽管Vue和React中有类似的概念，Flutter完全没有必要建立这样的机制，因为Flutter有一个非常完整的上下文。

我认为Provider框架之所以这么设计，主要原因是缺乏数据绑定层，所以你会发现在使用Provider时，页面写得很快，但你需要写如何同步页面外的数据字段，就是非常复杂和痛苦。

ModelBinding认为，在编写Widget Tree时，应该清楚地知道页面的结构、局部刷新的范围以及它们绑定到的数据。这就像是一种穷举所有结果的声明式编码，而不是隐晦的调用addListener（尽管ModelBinding也提供了一种添加监听器的方法，但不推荐使用）；声明式编程也符合大多数人的写作习惯；

此外，ModelBinding认为，在多个数据项之间建立同步远不如一同份数据在多处引用。要做到这一点，就要归功于ModelBinding对MapModel框架的使用，其特点是将Map用作模型。转换模型只意味着同一个Map的可见性不同（简单理解为一推getter/setter不同），本质仍然是同一个实例。

此外，ModelBinding绑定层还提供了一个更用户友好的工具箱，例如TextFieldBinding，它可以用作控件输入和输出，以双向绑定数据项。

与GetIT框架相比，首先，GetIT是一个数据的包装类。在使用它时，原始数据需要封装在GetIT中，这与vue3的ref类似，但不能像vue3那样用作递归代理，这会让开发人员封装子项。它也可以打包一些Widget，但这也是开发人员不断打包和解包工作负载增加的结果。

ModelBinding认为，将细节和工作负载交给开发人员并不是一个非常明智的选择。也许它可以在底层细节中实现，但没有必要暴露出来。这并不优雅，也不符合大多数人的写作习惯。这就像1+1。尽可能地，它不应该是a.add(b)。它应该考虑加号的运算符重载，并保持1+1的写入方法；

事实上，底层ModelBinding的许多细节也参考了GetIT实现，但我们提供的API更加用户友好。此外，GetIT还需要像Provider一样建立额外的绑定关系。

还是那句话，无论同步数据的机制多健全，永远没有只维护一份共用的数据来的好；


[MapModel](https://pub.flutter-io.cn/packages/map_model)
[ModelBinding](https://pub.flutter-io.cn/packages/model_binding)