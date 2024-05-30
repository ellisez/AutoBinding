
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

> 注意: `ModelStatefulWidget`提供数据应当与调用数据不在同一处定义, 如果不跨层数据提供方与调用方互相是可见的, 也就失去了数据共享与状态同步的意义了.

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
> 同样要求数据提供与调用分开定义(范例中是直接下级, 但实际调用处通常是跨很多层级的), 

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
> 用法与`DataState`相似, 同样也要求提供方与调用方分别编写,
> 
> 与`DataState`比较, 同样也是无状态刷新丢失数据,与有状态刷新保留数据的区别.

## 数据调用

数据调用分为三个步骤: 建立引用, 连接上下文, 捆绑视图;

### 建立引用
引用可分为有状态引用与无状态引用

有状态使用: `StateRef`类完成引用实例的创建
```dart
  final usernameRef = StateRef<ModelState<LoginForm>, String>(
    getter: (ModelState<LoginForm> state) => state.model.username,
    setter: (ModelState<LoginForm> state, String username) =>
        state.model.username = username,
  );
```

无状态使用: `WidgetRef`类完成引用实例的创建
```dart
  final usernameRef = WidgetRef<ModelStatelessWidget<LoginForm>, String>(
    getter: (ModelStatelessWidget<LoginForm> widget) => widget.model.username,
    setter: (ModelStatelessWidget<LoginForm> widget, String username) =>
        widget.model.username = username,
  );
```
> 很容易看到, 引用类型需要提供getter与setter, 另外就是数据提供方的类型.

> 无状态对应的是`ModelStatelessWidget`与`DataStatelessWidget`所提供的数据;

> 有状态对应的是`ModelStatelessWidget`与`DataState`所提供的数据;

> <font color=yellow>注意: 引用变量应当创建在build()函数之外, 而不是跟随着页面刷新总是创建新的;</font>
### 连接上下文

使用引用connect()连接context可获得已建立绑定关系的binding实例
```dart
  @override
  Widget build(BuildContext context) {
    var username = usernameRef.connect(context);
    ...
  }
```
> 连接上下文应当编写在build()范围里, 当视图刷新时就要重新进行连接, 以保证绑定总是最新的.
> 
> connect()所连接的context应当遵守范围越小越好, context即发生变化是刷新的范围.

### 直接连接
```dart
var password = Binding(
  context,
  WidgetRef(
    getter: (ModelStatelessWidget<LoginForm> widget) =>
    widget.model.password,
    setter: (ModelStatelessWidget<LoginForm> widget, String password) =>
    widget.model.password = password,
  ),
);
```

### 捆绑视图

使用binding填充到某个WidgetTree上
```dart
Widget build(BuildContext context) {
  /// connecting context
  var username = usernameRef.connect(context);

  var password = Binding(
    context,
    WidgetRef(
      getter: (ModelStatelessWidget<LoginForm> widget) =>
      widget.model.password,
      setter: (ModelStatelessWidget<LoginForm> widget, String password) =>
      widget.model.password = password,
    ),
  );
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
        username, /// 传入binding
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
        password, /// 传入binding
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
        username.value = '来自指定值的修改';
        password.value = '来自指定值的修改';
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
          'username = ${username.bindTo()}\npassword = ${password.bindTo()}',
        )),
  );
}
```
> 范例中通过`BindingTextField`绑定到TextField输入框, 通过bindTo()绑定值;
> 
> 通过`username.value = '来自指定值的修改';`赋值立刻产生页面的刷新;
> 
> `BindingTextField`还提供了`valueToString`与`stringToValue`用于更多的格式化输入输出, 更多捆绑方式请参见[绑定控件篇]()

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
