
# ModelBinding v2

[`en`](https://github.com/ellisez/ModelBinding/blob/master/README.md) [`cn`](https://github.com/ellisez/ModelBinding/blob/master/README-ZH_CN.md)

ModelBinding is a lightweight MVVM bidirectional binding state management framework for data sharing and synchronization.

ModelBinding v2 adopts a new responsive programming approach, inspired by Vue and React, The new version of v2 allows for the use of existing widgets and build() extensions, which are a regular widget and build() that were originally non bidirectional, without the need to refactor a large number of WidgetTree hierarchical relationships and smoothly establish binding relationships.

Compared to the older version of v1, data providers no longer need to force the establishment of model classes for binding, data callers do not need to forcibly inherit specific State and StatelessWidgets, and dynamic binding does not require manual release;

The overall design principle of the v2 version is to leave the data structure of the data provider to the maximum extent possible for developers, and to leave the binding method of the data caller to the maximum extent possible for developers.

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

## Data provider

The system provides four ways:  `ModelStatefulWidget`, `ModelStatelessWidget`, `ModelProviderState`, `ModelProviderWidget`

### ModelStatefulWidget
`ModelStatefulWidget` provides a `model` parameter and gives it a generic, which can be directly used as a WidgetTree in build(), making it easier to use existing data types;

```dart
/// add WidgetTree
  @override
  Widget build(BuildContext context) {
    return ModelStatefulWidget<LoginForm>(
      model: LoginForm("", ""),
      child: CallModelState(),
    );
  }
```
> The model data type of the ModelStatefulWidget in the example is LoginForm, provided by LoginForm;
> 
> child is a regular widget called;

> Note: The data provided by `ModelStatefulWidget` should not be defined at the same location as the calling data. If the data provider and caller are not visible to each other across layers, the meaning of data sharing and state synchronization will be lost.

### ModelStatelessWidget

`ModelStatelessWidget`, similar to `ModelStatefulWidget`, also provides a `model` parameter that can be used directly as a WidgetTree.

```dart
  @override
  Widget build(BuildContext context) {
    return ModelStatelessWidget<LoginForm>(
      model: LoginForm("", ""),
      child: CallModelStatelessWidget(),
    );
  }
```
> The example is similar to the example of 'ModelStatefulWidget', but they differ when facing ancestor node refresh.
> The ModelStatelessWidget is stateless, so the model will be recreated;
> The ModelStatefulWidget can still retain data after refreshing;

### ModelProviderState

`ModelProviderState` provides an abstract class called State, and developers need to write subclasses to inherit it Shared data can be freely added as member variables in custom subclasses.

```dart
/// ExampleForModelProviderState is a subclass of ModelProviderState;
/// ExampleForModelProviderStatefulWidget is just a regular StatefullWidget.
class ExampleForModelProviderState
    extends ModelProviderState<ExampleForModelProviderStatefulWidget> {
  
  //// declare sharing data
  String username = '';
  String password = '';
  ////
  
  
  /// CallModelProvider calling
  @override
  Widget builder(BuildContext context) => const CallModelProvider();
}
```
> Similarly, it is required that data provision be defined separately from invocation (in the example, it is a direct subordinate, but the actual invocation is usually across many levels),
> In ModelProviderState<ExampleForModelProviderStatefulWidget>, the ExampleForModelProviderStatefulWidget only needs to be a regular StatefulWidget.

> `ModelProviderState` provides a code area for freely defining shared data compared to `ModelStatefulWidget` and `ModelStatelessWidget`.

### ModelProviderWidget

`ModelProviderWidget` is a stateless abstract class, and developers need to write its inheritance class to extend shared data items;

```dart
/// Inheritance class of ModelProviderWidget
class ExampleForModelProviderWidget extends ModelProviderWidget {
  
  /// declare sharing data
  final loginForm = LoginForm('', '');
  ///
  
  /// CallModelProviderWidget calling
  ExampleForModelProviderWidget()
      : super(child: CallModelProviderWidget());
}
```
> The usage is similar to 'ModelProviderState', which also requires the provider and caller to write separately,
> Compared to `ModelProviderState`, it is also the difference between stateless refresh losing data and stateful refresh preserving data.

## Data calling

The data call is divided into three steps: establishing references, connecting context, and binding views;

### establishing references
References can be divided into stateful references and stateless references

State based usage: The 'StateRef' class completes the creation of reference instances
```dart
  final usernameRef = StateRef<ModelState<LoginForm>, String>(
    getter: (ModelState<LoginForm> state) => state.model.username,
    setter: (ModelState<LoginForm> state, String username) =>
        state.model.username = username,
  );
```

Stateless use: The 'WidgetRef' class completes the creation of reference instances
```dart
  final usernameRef = WidgetRef<ModelStatelessWidget<LoginForm>, String>(
    getter: (ModelStatelessWidget<LoginForm> widget) => widget.model.username,
    setter: (ModelStatelessWidget<LoginForm> widget, String username) =>
        widget.model.username = username,
  );
```
> It is easy to see that the reference type needs to provide a getter and setter, as well as the type of the data provider.

> Stateless corresponds to the data provided by `ModelStatelessWidget` and `ModelProviderWidget`;

> State corresponds to the data provided by `ModelStatelessWidget` and `ModelProviderState`;

> <font color=yellow>Note: Referencing variables should be created outside of the build() function, rather than always creating new ones following page refresh;</font>
### connecting context

Using the reference connection() to connect to the context can obtain a binding instance with an established binding relationship.
```dart
  @override
  Widget build(BuildContext context) {
    var username = usernameRef.connect(context);
    ...
  }
```
> The connection context should be written within the build() scope, and when the view is refreshed, it should be reconnected to ensure that the binding is always up-to-date.
>
> The context connected by connect() should adhere to a smaller scope as much as possible, The change in context is the refresh range.

### binding views

Fill a WidgetTree with binding
```dart
Widget build(BuildContext context) {
  /// connecting context
  var username = usernameRef.connect(context);
  
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
    ],
    const SizedBox(height: 30),
    ElevatedButton(
      onPressed: () async {
        /// write data, to refresh view
        username.value = '来自指定值的修改';
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
> In the example, bind to the TextField input box through `BindingTextField` and bind the value through bindTo();
>
> Modify from specified value through `username.value = '来自指定值的修改'` Assign values to immediately generate page refresh;
>
> `BindingTextField` also provides `valueToString` and `stringToValue` for more formatted input and output. For more bundling methods, please refer to the [Bind Control section]().

## ModelBinding vs Provider vs GetX

Both Provider and GetX are currently the most widely used state management frameworks, but there are also many criticized mechanisms that have given us the impetus to develop ModelBinding.

Let's take a look at where ModelBinding has improved:
* More convenient refresh mechanism: automatic refresh vs manual refresh

We all know that Flutter has followed the principle of manual refreshing from its initial tutorials to many subsequent SDKs, such as `State. setSate()`, `ChangeNotify.notifyListeners()`, and so on. Of course, Provider/GetX has also continued this practice of manual refreshing;

So we are thinking about whether we can achieve automatic refreshing at the MVVM level, similar to automatically updating views and events related to values when changing them We searched through the SDK and found that the Value Notify triggers a side bound event when the value changes.

However, establishing an update mechanism is very complex and requires maintaining the usage relationship between refreshing pages and values.

Provider/GetX only rudely refreshes all associated views, which can cause a lot of invalid refreshes and does not provide a finer grained binding method.

ModelBinding employs multiple bundling methods internally, some requiring page refresh and others simply triggering a listener, truly achieving a minimum refresh of only the modified parts, rather than always refreshing in full.

* Higher performance: field level comparison vs. object level comparison

The performance of refreshing depends on the refresh range. The smaller the range, the lower the performance consumption. The refresh range depends on the accuracy of the compared data.

> Determine whether the data has been modified:
>
> * Object level comparison: It can only be seen as a whole and is difficult to determine the changes in multi-level attributes, that is, the changes in attribute values It can only obtain a marker for the overall change, and recursive multi-level attributes are also not implemented.
> Provider/GetX is Object level comparison.
> * Field level comparison: Due to the use of Ref in the design of ModelBinding, which separates fields and binds them to views on a field by field basis, field level comparison can be achieved, and the corresponding view and refresh mechanism for each field can be determined.
* Lower code complexity: on-demand development mode vs. heavy model development mode
> * Model heavy development mode: Providers/GetX usually require a separate Model class to be written (Providers are various XXXProviders, GetX is GetxController.
>
> This Model class is essentially similar to the Service layer, which privatizes some properties and publicly calls methods
>
> This will result in more and more functions in the Model, even if some functions are only used in very few cases, because the caller cannot manipulate private properties and must be summarized in the Model.
>
> The Model may be suitable for one or two callers, but if there are more and more callers, this centralized management will inevitably increase in complexity.
>
> * On demand development mode: We analyzed the MVC mode that Service has been passed down for many years and found that it is not suitable for front-end projects. The reason is that the model data of front-end projects is actually deeply bound to page controls, and the page can change at any time, so the data can change at any time.
>
> Even if shared data is needed, it will only be a small part of the displayed page data. Forcefully applying Service will find that a large number of functions need to be passed through page parameters, and it is difficult to pass and process them the same on each page.
>
> It's not difficult to understand, Service is suitable for backend design because the backend only focuses on data addition, deletion, querying, and modification, but the frontend also needs to manage the execution order, triggering events, and formatting data required for assembling controls, which is not such a regular data.
>
> Since the Model is not suitable for managing too many, our design idea is to provide business processing capabilities to the display side for callbacks, and only common functions are drawn to the Model.
>
> Due to the field level bidirectional binding provided by ModelBinding, it is very convenient for the caller to handle business.
>

* Lower renovation costs:
> We have been thinking about a question, how to reduce a project that was originally non state managed and transform it into a state managed project?
>(Originally, each page only called its own data, but now some of the data comes from shared data)
>
>Let's first take a look at Provider/GetX. They need to extract shared data into a new Model class, and then scatter the read and write operations on the shared data into the Model class to make functions. Finally, they need to modify the way the original page calls the Model function. Another step is to make the reserved widgets into StatefulWidgets to ensure data is not lost due to full refresh
>
>From this perspective, the cost of renovation is still very high
>
>Our core idea in designing ModelBinding is "borrowing", which means directly modifying the existing closest page
>
>Firstly, if there is already a page with very complete data, inherit a specific 'ModelProviderState' or 'ModelProviderWidget' from that page, mainly depending on whether it is stateful or stateless
>
>Secondly, create a new Ref field reference object on the calling page, Connect context in build to obtain a binding, and then use the binding to replace the original calling location
>
>Due to, Binding is equivalent to downloading data locally, so the lifecycle and state are also consistent with the original page, and there is no need to consider rewriting the state type of the widget
>
>This design can minimize the need to change the original calling logic, fully comply with the "open and closed principle", open to new additions and extensions, and block modifications

<h4>If you think our framework is good, like/email for communication.</h4>
<ellise@qq.com>

[ModelBinding](https://pub.flutter-io.cn/packages/model_binding)
