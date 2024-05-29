
# ModelBinding v2

[`en`](https://github.com/ellisez/ModelBinding/blob/master/README.md) [`cn`](https://github.com/ellisez/ModelBinding/blob/master/README-ZH_CN.md)

ModelBinding是一个轻便的MVVM双向绑定的状态管理框架, 以达到数据共享与同步。

ModelBinding v2采用了全新的响应式编程方式，受到vue与react的启发，v2新版本允许利用原本已有的widget和build()扩展即可，也就是一个原本非双向绑定的普通Widget和build(), 无需重构大量WidgetTree层级关系，很丝滑的建立绑定关系。

与v1旧版本相比，数据提供方不再需要强制建立模型类用于绑定，数据调用方也无需强制继承特定的State和StatelessWidget，动态绑定也无手动进行释放；

v2版本总体设计原则是将数据提供方的数据结构最大程度的留给开发者，将数据调用方捆绑方式自由度最大程度的留给开发者。

## Setup

```shell
flutter pub add model_binding
```

or

```yaml
dependencies:
  model_binding: any
  ...
```

## 数据提供

系统提供了常见的四种数据提供方式:  `ModelStatefulWidget`, `ModelStatelessWidget`, `ModelProviderState`, `ModelProviderWidget`

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

### ModelProviderState

`ModelProviderState`提供了State抽象类, 开发者需要编写子类来继承它. 自定义的子类中可以自由的添加共享的数据作为成员变量.

```dart
/// ExampleForModelProviderState是ModelProviderState的子类;
/// ExampleForModelProviderStatefulWidget只是个普通的StatefulWidget
class ExampleForModelProviderState
    extends ModelProviderState<ExampleForModelProviderStatefulWidget> {
  
  //// 定义共享数据
  String username = '';
  String password = '';
  ////
  
  
  /// CallModelProvider调用方函数
  @override
  Widget builder(BuildContext context) => const CallModelProvider();
}
```
> 同样要求数据提供与调用分开定义(范例中是直接下级, 但实际调用处通常是跨很多层级的), 
> ModelProviderState<ExampleForModelProviderStatefulWidget>中ExampleForModelProviderStatefulWidget只需要是个普通的StateStatefulWidget即可.

> `ModelProviderState`与`ModelStatefulWidget`和`ModelStatelessWidget`相比提供了自由定义共享数据的代码区域.

### ModelProviderWidget

`ModelProviderWidget`是无状态的抽象类, 开发者需要编写其继承类, 扩展共享数据项;

```dart
/// ModelProviderWidget的继承类
class ExampleForModelProviderWidget extends ModelProviderWidget {
  
  /// 定义共享数据
  final loginForm = LoginForm('', '');
  ///
  
  /// CallModelProviderWidget是数据调用方
  ExampleForModelProviderWidget()
      : super(child: CallModelProviderWidget());
}
```
> 用法与`ModelProviderState`相似, 同样也要求提供方与调用方分别编写,
> 
> 与`ModelProviderState`比较, 同样也是无状态刷新丢失数据,与有状态刷新保留数据的区别.

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

> 无状态对应的是`ModelStatelessWidget`与`ModelProviderWidget`所提供的数据;

> 有状态对应的是`ModelStatelessWidget`与`ModelProviderState`所提供的数据;

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
  getter: (ModelStatelessWidget<LoginForm> widget) => widget.model.password,
  setter: (ModelStatelessWidget<LoginForm> widget, String password) =>
  widget.model.password = password,
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
    getter: (ModelStatelessWidget<LoginForm> widget) => widget.model.password,
    setter: (ModelStatelessWidget<LoginForm> widget, String password) =>
    widget.model.password = password,
  );
  return Column(
    children: [
      const Text('ModelBinding example for ModelStatelessWidget.',
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

## ModelBinding vs Provider vs GetX的优势

Provider和GetX都目前流行最广泛的状态管理框架, 但也存在许多被人诟病的机制, 我们正是看到了这些才有了ModelBinding的研发动力.

下面我们来看看ModelBinding在哪些方面做了提升:
* 刷新机制更便捷: 自动刷新 vs 手动刷新:

我们都知道flutter从刚出现的教程到后来提供的许多sdk, 都遵循了手动刷新这一原则, 如`State.setSate()`, `ChangeNotifier.notifyListeners()`等等, 当然Provider/GetX也延续了手动刷新这一做法;

所以我们在思考能不能做到MVVM级别的自动刷新呢, 类似与改变值时会自动更新与值有关的视图和事件. 我们翻遍了sdk发现了ValueNotifier内部是会在值发生改变时触发一边绑定的事件.

但是建立更新的机制时非常复杂的, 需要维护刷新页面与值的使用关系.

Provider/GetX只是粗暴的把关联的视图全都刷新一遍, 这样做会造成非常多无效的刷新, 本身并不提供细粒度更高的捆绑方式.

ModelBinding内部采用了多种捆绑方式, 有的需要刷新页面, 有的只需要触发listener, 真正做到了只对发生修改的部分进行刷新, 最小刷新, 而非总是全量刷新.

* 性能更高: 字段级比较 vs 对象级比较

刷新的性能, 取决于刷新的范围, 范围越小性能消耗越小, 刷新范围取决于比较数据的准确度.

> 判断数据是否发生修改: 
>
> * 对象级比较: 只能作为一个整体而难以得知多级属性的变化, 即属性的属性值发生的改变. 也只能得到一个整体的改变与否的标记, 而递归多级属性也是不实现的.
> Provider/GetX是对象级.
> * 字段级比较: 由于ModelBinding设计上采用Ref把字段拆出来了, 包括绑定到视图上也是以字段为单位, 所以可以做到字段级比较, 也能得知每个字段对应的视图, 以及刷新机制等等.
* 代码复杂度更低: 按需开发模式 vs 重Model开发模式
> * 重Model开发模式: Provider/GetX一般都需要单独编写一个Model类(Provider是各种XXXProvider, GetX则是GetxController).
>
>这个Model类本质上是类似Service服务层, 也就是把一些属性私有化, 公开调用方法.
>
>这样做会造成Model的函数越来越多, 哪怕有一些函数只在非常少的情况下使用, 因为调用方无法操作私有属性, 也必须汇总到Model上来.
>
> Model可能适配一两个调用方可能还好, 但如果调用方越来越多了, 这种"集中式管理"势必复杂度会上生的.
>
> * 按需开发模式: 我们分析了Service被多年流传下来的MVC模式, 实际并不适合前端项目, 原因是前端项目的模型数据实际是与页面控件深度绑定的, 页面随时可能改变, 那么数据随时发生改变.
> 
> 共享数据即使需要, 也只会是显示页面数据中很少的一部分, 强行套用Service, 就会发现大量函数需要通过页面参数传递, 而且每个页面传递和处理很难相同.
> 
> 这也不难理解, Service适合后端设计, 因为后端只管数据增删查改, 但前端还要管执行顺序和触发事件以及组装控件所需格式数据, 并不是这么规则的数据.
> 
> 既然Model并不适合管太多, 所以我们设计的思想是, 还业务处理能力给回调用的显示方, 只有共性的功能才抽到Model上.
> 
> 由于ModelBinding提供的字段级别的双向绑定, 调用方处理业务非常方便.
> 

* 改造成本更低: 
> 我们一直在思考一个问题, 怎么样降低一个原本非状态管理的项目, 转变为状态管理项目?
> (原本每个页面仅调用自身的数据, 改为部分数据来自共享数据)
>
> 我们先来看Provider/GetX, 他们需要把共享数据抽到新建Model类, 然后把分散到页面里对共享数据的读写操作, 全部抽到Model类里做成函数, 最后需要修改原页面调用Model函数的方式, 还有一步就是由于全量刷新, 需要将保留的widget做成StatefulWidget以保证数据不丢失.
>
> 这样看下来改造成本还是非常大的.
>
> 我们在设计ModelBinding是核心的思想就是"拿来主义", 也就是拿现有最接近的页面上直接改.
>
> 首先, 如果已经有一个页面的数据非常齐全了, 就拿这个页面继承特定的`ModelProviderState`或`ModelProviderWidget`, 主要看是有状态还是无状态的.
>
> 其次, 在调用页面新建Ref字段引用对象, build里连接context获得binding, 然后用binding去替换掉原先调用的位置.
>
> 由于, binding等同于把数据下载到本地, 所以生命周期与状态也是与原页面一致的, 不需要考虑改写widget的状态类型.
>
> 这么设计能最大程度不去更改原来的调用逻辑, 完全符合"开闭原则", 对新增与扩展开放, 对修改闭塞.

<h4>如果觉得我们这个框架不错, 点赞/邮件进行交流.</h4>
<ellise@qq.com>

[ModelBinding](https://pub.flutter-io.cn/packages/model_binding)
