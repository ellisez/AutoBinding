
# AutoBinding v2

[`en`](https://github.com/ellisez/AutoBinding/blob/master/README.md) [`cn`](https://github.com/ellisez/AutoBinding/blob/master/README-ZH_CN.md)

AutoBinding是一个轻便的MVVM双向绑定的状态管理框架, 以达到数据共享与同步。

AutoBinding v2采用了全新的响应式编程方式，受到vue与react的启发，v2新版本允许利用原本已有的widget和build()扩展即可，也就是一个原本非双向绑定的普通Widget和build(), 无需重构大量WidgetTree层级关系，很丝滑的建立绑定关系。

与v1旧版本相比，数据提供方不再需要强制建立模型类用于绑定，数据调用方也无需强制继承特定的State和StatelessWidget，动态绑定也无手动进行释放；

v2版本总体设计原则是将数据提供方的数据结构最大程度的留给开发者，将数据调用方捆绑方式自由度最大程度的留给开发者。

## Setup

```shell
flutter pub add auto_binding
```

## 数据提供

系统提供了常见的四种数据提供方式:  `ModelStatefulWidget`, `ModelStatelessWidget`, `DataStatefulWidget`, `DataStatelessWidget`

### ModelStatefulWidget
`ModelStatefulWidget` 提供一个`model`参数并给与泛型, 可直接在build()作为WidgetTree使用, 便于使用已有的数据类型;

```dart
/// 组织WidgetTree
  @override
  Widget build(BuildContext context) {
    return ModelStatefulWidget<LoginForm>(
      model: LoginForm("", ""),
      child: CallModelState(),
    );
  }
```
> 范例中ModelStatefulWidget的模型数据类型为LoginForm, 由LoginForm提供;
> child是调用的Widget;

### ModelStatelessWidget

`ModelStatelessWidget`与`ModelStatefulWidget`相似也提供的`model`参数, 直接作为WidgetTree使用.

```dart
  @override
  Widget build(BuildContext context) {
    return ModelStatelessWidget<LoginForm>(
      model: LoginForm("", ""),
      child: CallModelStatelessWidget(),
    );
  }
```
> 范例与`ModelStatefulWidget`的范例很相似, 但两者在面对祖先节点刷新时有所不同.
> ModelStatelessWidget是无状态所以model会被重新new出来;
> 而ModelStatefulWidget刷新后仍能保留数据;

### DataStatefulWidget

`DataStatefulWidget`提供了StatefulWidget的抽象类, 开发者需要编写子类来继承它. 自定义的子类中可以自由的添加共享的数据作为成员变量.

```dart
/// ExampleForDataStatefulWidget是DataStatefulWidget的子类
class ExampleForDataStatefulWidget extends DataStatefulWidget {
  ExampleForDataStatefulWidget({super.key});

  @override
  ExampleForDataState createState() => ExampleForDataState();
}
/// ExampleForDataState是DataState的子类;
class ExampleForDataState
    extends DataState<ExampleForDataStatefulWidget> {
  
  //// 定义共享数据
  String username = '';
  String password = '';
  ////
  
  
  /// CallCallDataStatefulWidget调用方函数
  @override
  Widget builder(BuildContext context) => const CallDataStatefulWidget();
}
```

> `DataState`与`ModelStatefulWidget`和`ModelStatelessWidget`相比提供了自由定义共享数据的代码区域.

### DataStatelessWidget

`DataStatelessWidget`是无状态的抽象类, 开发者需要编写其继承类, 扩展共享数据项;

```dart
/// ModelProviderWidget的继承类
class ExampleForDataStatelessWidget extends DataStatelessWidget {
  
  /// 定义共享数据
  final loginForm = LoginForm('', '');
  ///
  
  /// CallModelProviderWidget是数据调用方
  ExampleForDataStatelessWidget()
      : super(child: CallDataStatelessWidget());
}
```
> 用法与`DataState`相似, 也可以自由的定义共享数据.

## 数据调用

数据调用分为三个步骤: 创建构造器, 绑定引用, 捆绑视图;

### 创建构造器

通过context来创建构造器

```dart
  @override
  Widget build(BuildContext context) {
    var node = Binding.mount(context);
  }
```

> 绑定的context应当遵守范围越小越好, context即发生变化是刷新的范围.
>
> <font color=yellow>注意: 构造器必须在build()函数之内创建;</font>

### 绑定引用

两种绑定方式: 直接绑定, 引用绑定
```dart
  final usernameRef = Ref.fromData(
    getter: (ModelStatelessWidget<LoginForm> widget) => widget.model.username,
    setter: (ModelStatelessWidget<LoginForm> widget, String username) =>
      widget.model.username = username,
  );

  @override
  Widget build(BuildContext context) {
    var node = Binding.mount(context);
    /// 引用绑定: 使用已定义的Ref变量
    var username = usernameRef(node);

    /// 直接绑定: 提供getter/setter
    var password = Ref.fromData(
        getter: (ModelStatelessWidget<LoginForm> widget) => widget.model.password,
        setter: (ModelStatelessWidget<LoginForm> widget, String password) =>
        widget.model.password = password,
      ).call(node);
    ...
  }
```

> 多个上下文使用时, 应考虑引用绑定的方式, 这样Ref变量可以复用

### 捆绑视图

使用binding填充到某个WidgetTree上
```dart
class ExampleForModelStatelessWidget extends StatelessWidget {
  
  final usernameRef = Ref.fromData(
    getter: (ModelStatelessWidget<LoginForm> widget) => widget.model.username,
    setter: (ModelStatelessWidget<LoginForm> widget, String username) =>
    widget.model.username = username,
  );

  Widget build(BuildContext context) {
    /// connecting context
    var node = Binding.mount(context);

    var username = usernameRef(node);

    /// no bind
    username.raw;

    var password = Ref.fromData(
        getter: (ModelStatelessWidget<LoginForm> widget) => widget.model.password,
        setter: (ModelStatelessWidget<LoginForm> widget, String password) =>
        widget.model.password = password,
      ).call(node);
    return Column(
      children: [
        const Text('AutoBinding example for ModelStatelessWidget.',
            style: TextStyle(
                fontSize: 36,
                color: Colors.deepOrange,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        const Text('轻便的MVVM双向绑定的框架',
            style: TextStyle(fontSize: 16, color: Colors.black38)),
        const SizedBox(height: 30),

        /// binding TextField
        BindingTextField(
          usernameRef.ref,

          /// 传入binding
          decoration: const InputDecoration(
            labelText: '用户名',
            hintText: '请输入用户名',
          ),
          style: const TextStyle(
              color: Colors.indigo, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        /// binding TextField
        BindingTextField(
          Ref.fromData(
            getter: (ModelStatelessWidget<LoginForm> widget) => widget.model.password,
            setter: (ModelStatelessWidget<LoginForm> widget, String password) =>
            widget.model.password = password,
          ).ref,

          /// 传入binding
          decoration: const InputDecoration(
            labelText: '密码',
            hintText: '请输入密码',
          ),
          style: const TextStyle(
              color: Colors.indigo, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
      ],
      const SizedBox(height: 30),
      ElevatedButton(
        onPressed: () async {
          /// write data, to refresh view
          username.notifyChange('来自指定值的修改');
          password.notifyChange('来自指定值的修改');
        },
        style: const ButtonStyle(
          backgroundColor:
          MaterialStatePropertyAll<Color>(Colors.lightBlue),
          foregroundColor:
          MaterialStatePropertyAll<Color>(Colors.white),
        ),
        child: const Text('更改当前值'),
      ),
      const SizedBox(height: 30),
      Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              vertical: 4, horizontal: 10),
          color: Colors.blueGrey,

          /// binding value
          child: Text(
            'username = ${username.bindChange()}\npassword = ${password.bindChange()}',
          )),
    );
  }
}
```
> 范例中通过`BindingTextField`绑定到TextField输入框, 通过bindChange()绑定值到Text视图, value不会产生绑定;
>
> 通过`username.notifyChange('来自指定值的修改');`赋值立刻产生页面的刷新;
>
> `BindingTextField`还提供了`valueToString`与`stringToValue`用于更多的格式化输入输出, 更多捆绑方式请参见[绑定控件篇]()

## 使用macros生成Ref

### 开启macros模式
参见[https://dart.dev/language/macros](https://dart.dev/language/macros)

#### 1. 配置sdk版本, 3.5.0-152以上
```yaml
# pubspec.yaml
environment:
  sdk: '>=3.5.0-152 <4.0.0'
```

#### 2. 启动参数`--enable-experiment=macros`
```shell
flutter run --enable-experiment=macros
dart run --enable-experiment=macros
```

#### 3. 编写本地宏

由于`macros`仍处于实验阶段，暂时无法支持跨包的`Dart Analysis Server`语法解析。

这会导致macro新加入的库、类型、属性和方法均不能被静态分析所识别，会造成缺少定义错误。但运行时是正确的。

因此需要将外部包的宏，从新在本包内再次声明一次，具体如下：
```dart
// lib/macros/auto_binding.dart
import 'package:auto_binding/auto_binding.dart' as auto_binding;

macro class RefCodable extends auto_binding.RefCodable {
  const RefCodable();
}

macro class IgnoreRefCodable extends auto_binding.IgnoreRefCodable {
  const IgnoreRefCodable();
}
```

不能跨包的大致原因是`Dart Analysis Server`静态分析并不能只是对着源码分析，而是需要根据`analysis_options.yaml`规则得出`info/warning/error`，跨包就需要对每个包都进行重新分析，
而`Dart Analysis Server`目前仅仅是单一规则的，每个包都各自开启一个分析服务性能损失太大，通信的延时也会加重，
所以dart官方还需要从性能和功能上重新进行设计。

这是官方相关讨论[https://github.com/dart-lang/sdk/issues/55688](https://github.com/dart-lang/sdk/issues/55688)


### 使用RefCodable注解
```dart
/// define annotation
@RefCodable()
class LoginForm {
  var username = '123';
  String password;

  Info info = Info(nickName: '', gender: 'man');

  LoginForm(this.username, this.password);
  
}

@RefCodable()
class Info {
  String nickName;
  String gender;

  Info({required this.nickName, required this.gender});

  Map<String, dynamic> toJson() => {
    'nickName': nickName,
    'gender': gender,
  };

}

/// call ref
var loginForm = LoginForm('username', 'man');
var ref = loginForm.info.nickNameRef;

var nickName = ref.value; // get value
ref.value = '123'; // set value

var node = Binding.mount(context); // old dependentExecutor dispose

var binding = dataRef(node); // dataRef to binding
var binding = loginForm.info.nickNameRef(node); // ref to binding

var nickName = binding.value; // get value but no bind
binding.value = '123'; // set value but do not update page
binding.bindChange(); // get value and add dependentExecutor
binding.notifyChange('123'); // set value and update page

loginForm.info.nickNameRef(node).bindChange(); // get value and add dependentExecutor
loginForm.info.nickNameRef(node).notifyChange('123'); // set value and update page
loginForm.info.nickNameRef(node).value // get value but no bind
loginForm.info.nickNameRef(node).value = '123'; // set value but do not update page

var nickName = loginForm.info.nickNameRef.bindChange(node: node) // get value and add dependentExecutor
loginForm.Info.nickNameRef.notifyChange(node: node, value: '123'); // set value and update page

bindChangeNotifier(node: node, ref: loginForm.info.nickName, changeNotifier: changeNotifier, notifyListener: notifyListener, onChange: onChange);
bindValueNotifier(node: node, ref: loginForm.info.nickName, valueNotifier: valueNotifier);
```
> `@RefCodable()`可定义在`class`或`field`, 被标注的类或属性会自动生成对应的引用属性.
>
> 引用属性名, 为字段名加后缀`Ref`, 如`nickName`的引用属性是`nickNameRef`.

## AutoBinding优势

* 字段级的比较：触发更精准，视图刷新范围更小，同时性能也更高。

> 传统的比较方式为对象级比较，一般的做法是在ChangeNotifier.addListener()或didChangeDependencies()函数里，对整个对象进行比较，发生改变才会触发相应的视图刷新；
>
> 但复杂的对象比较无法做到递归多级属性，导致比较的结果不够准确。
>
> 另一种做法是重载等号运算符，或者改写hashCode，这样虽然减少了比较复杂度，但在实际业务中，有时我们希望它的比较规则在不同情况下有多种，这时你只能再编写一个结构几乎一样的类为的是有不一样的比较规则。
>
> 而且重载运算符，很难引入除类成员之外的其他变量参与比较。所以当对象自身不足以完成比较时，就会产生许多臃肿的代码在调用处。
>
> 更致命的是，如果有两个不同类，但实际确实同一份数据，就要额外建立两份数据的修改同步机制。


> 字段级比较的特点是只比较那些会产生触发事件的字段，而跳过那些即使发生改变了也没有触发事件的数据。
>
> 而且字段级别的比较, 不依赖于字段所属的对象是否相等，甚至类型不同也可以进行比较。
>
> 字段比较也可以很轻松的引入外部变量参与计算规则，原则上字段取值的规则就是字段比较的规则；

* 字段级的绑定：会为每个字段建立独立依赖关系，以实现字段与视图的双向同步。
> 传统的事件触发，因为无法得知本次改变的数据到底影响多少视图，所以通常都是大范围的重复刷新页面。
>
> 字段级的绑定，会为每一个字段收集有依赖关系的视图，当所有的比较结束后，系统会将发生改变的字段按照依赖关系去刷新视图。
>
> 原则上，哪些视图引用了字段，就能知道哪些视图依赖此字段的更新。
>
> 当然视图发生修改，也会通过依赖关系从页面回写到字段上来。
>
> 由于系统内部会分析值变化以及依赖关系，所以令人厌烦的setState()不再需要使用，实际上数据发生改变的可能影响多个视图，单个视图的setState()的价值并不高，也不建议使用。

* 渐进式开发，减少重构
> 我们一直在思考一个问题, 一个flutter项目是否能够创建项目的一开始就能完整的规划出，哪些数据是共享的，哪些函数会被调用。
>
> 我们相信绝大多数项目都应该是从简单的逐步演化复杂的过程，即使已经建立了状态管理，后续也随时可能有新的数据合并进来，迁移进来。
>
> 所以我们认为降低搭建与迁移的成本, 非常重要.

> 我们对比了普通页面转向常规的状态管理框架，需要经历的哪些步骤：
> 1. 需要把共享数据抽到新建Model类, 删除页面本地数据；
> 2. 然后为了让Model收集比较的数据, 把分散到页面里对共享数据的读写操作, 全部抽到Model类里做成函数, 删除页面本地相关代码片段，转为函数调用；
> 3. 最后需要思考全量刷新时, 哪些widget需要将保留数据不丢失, 可能需要改写为StatefulWidget.
     > 这个步骤之所以会有的原因是某些回调现在可能直接调用就完成了, 但因为要集中延时处理(对象级比较总不能每改一个数据都notifyListeners()执行一次吧, 肯定是集中到末尾才执行一次)还原现场就会有额外的数据传参, 以及还原现场的数据怎么保留下来.

> 传统的状态管理, 提供的是手动调用更新, 而何时调用则由开发者自行判断. 但多数据改变如果不在同一处, 实际你是不知道最后一次调用刷新的. 那么就是每次都刷新, 但是会很低效.

> 下面我们来看看AutoBinding是怎么降低改造成本的?
>
> 1. 首先, AutoBinding的数据提供者被设计为仅仅是一个普通的数据对象. 既不需要具有触发能力的ChangNotifier (Provider的方案), 也不需要额外继承GetxController (GetX的方案).
>
> AutoBinding的数据提供者只需要是个State或StatelessWidget即可, 从这个点出发原数据拥有者所在的Widget就可以直接拿来改成数据共享;
>
> 2. 其次, 我们反对将页面相关度大的函数抽到, 数据提供者, 仅仅只是因为控制刷新在数据提供者会减少次数.
>
> 我们的刷新机制是由字段绑定的依赖关系保证的, 而不是开发者自行调用notifyListeners()(实际只是把难题转嫁给开发者);
>
> 也是由于字段级的依赖关系, 本质上延时/异步的现场都是被保留下来的. 既然现场被保留了, 也就不需要维护额外的状态. 所以函数调用仍保持原样即可.
>
> 最后, 我们需要创建一系列字段级的Ref引用, 以及Binding绑定对象, 并且把原先从本地值全部换成从Binding对象里取值.
>
> 从本地页面的角度, Binding就像是把共享数据下载一份到本地使用一样.
>
> 完成上述步骤, 状态管理就可以工作起来了, 是不是很简单?

> AutoBinding搭建的后续维护:
> * 可考虑在把复用度高的函数, 几乎原样的抽到数据提供者, 只需从复用度考虑;
> * 可考虑本地字段迁向数据提供者, 只需从复用度考虑;

<h4>如果觉得我们这个框架不错, 欢迎点赞/邮件进行交流.</h4>
<ellise@qq.com>

[AutoBinding](https://pub.dev/packages/auto_binding)
