# AutoBinding v2

[`en`](https://github.com/ellisez/AutoBinding/blob/master/README.md) [`cn`](https://github.com/ellisez/AutoBinding/blob/master/README-ZH_CN.md)

AutoBinding is a lightweight MVVM bidirectional binding state management framework for data sharing and synchronization.

AutoBinding v2 adopts a new responsive programming approach, inspired by Vue and React, The new version of v2 allows for
the use of existing widgets and build() extensions, which are a regular widget and build() that were originally non
bidirectional, without the need to refactor a large number of WidgetTree hierarchical relationships and smoothly
establish binding relationships.

Compared to the older version of v1, data providers no longer need to force the establishment of model classes for
binding, data callers do not need to forcibly inherit specific State and StatelessWidgets, and dynamic binding does not
require manual release;

The overall design principle of the v2 version is to leave the data structure of the data provider to the maximum extent
possible for developers, and to leave the binding method of the data caller to the maximum extent possible for
developers.

## Setup

```shell
flutter pub add auto_binding
```

## Data provider

The system provides four
ways:  `ModelStatefulWidget`, `ModelStatelessWidget`, `DataStatefulWidget`, `DataStatelessWidget`

### ModelStatefulWidget

`ModelStatefulWidget` provides a `model` parameter and gives it a generic, which can be directly used as a WidgetTree in
build(), making it easier to use existing data types;

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

### ModelStatelessWidget

`ModelStatelessWidget`, similar to `ModelStatefulWidget`, also provides a `model` parameter that can be used directly as
a WidgetTree.

```dart
  @override
Widget build(BuildContext context) {
  return ModelStatelessWidget<LoginForm>(
    model: LoginForm("", ""),
    child: CallModelStatelessWidget(),
  );
}
```

> The example is similar to the example of `ModelStatefulWidget`, but they differ when facing ancestor node refresh
> The ModelStatelessWidget is stateless, so the model will be recreated;
> The ModelStatefulWidget can still retain data after refreshing;

### DataStatefulWidget

`DataStatefulWidget` provides an abstract class of `StatefulWidget`, and developers need to write subclasses to inherit
it Shared data can be freely added as member variables in custom subclasses.

```dart
/// ExampleForDataStatefulWidget a subclass of DataStatefulWidget.
class ExampleForDataStatefulWidget extends DataStatefulWidget {
  ExampleForDataStatefulWidget({super.key});

  @override
  ExampleForDataState createState() => ExampleForDataState();
}

/// ExampleForDataState is a subclass of DataState;
class ExampleForDataState extends DataState<ExampleForDataStatefulWidget> {

  //// declare sharing data
  String username = '';
  String password = '';

  ////


  /// CallDataStatefulWidget calling
  @override
  Widget builder(BuildContext context) => const CallDataStatefulWidget();
}
```

> Compared to `ModelStatefulWidget` and `ModelStatelessWidget`, `DataState` provides a code area for freely defining shared data.

### DataStatelessWidget

`DataStatelessWidget` is a stateless abstract class, and developers need to write its inheritance class to extend shared
data items;

```dart
/// Inheritance class of DataStatelessWidget
class ExampleForModelProviderWidget extends DataStatelessWidget {

  /// declare sharing data
  final loginForm = LoginForm('', '');

  ///

  /// ExampleForDataStatelessWidget calling
  ExampleForModelProviderWidget()
      : super(child: CallDataStatelessWidget());
}
```

> The usage is similar to DataState, and shared data can also be freely defined.

## Data calling

The data call is divided into three steps: creating a constructor, binding references, and binding views;

### Create Builder

Create a Builder through context

```dart
  @override
  Widget build(BuildContext context) {
    var builder = BindingBuilder(context);
  }
```

> The bound context should adhere to a smaller range as much as possible, as any changes in the context are within the refreshed range.
>
> <font color=yellow>Note: The constructor must be created within the build() function;</font>

### Binding references

Two binding methods: direct binding and reference binding
```dart
  final usernameRef = Ref(
    getter: (ModelStatelessWidget<LoginForm> widget) => widget.model.username,
    setter: (ModelStatelessWidget<LoginForm> widget, String username) =>
      widget.model.username = username,
  );

  @override
  Widget build(BuildContext context) {
    var builder = BindingBuilder(context);
    /// Reference binding: using defined Ref variables
    var username = builder.createBuildBinding(usernameRef);

    /// Direct binding: provide getter/setter
    var password = builder.createBuildBinding(
      Ref(
        getter: (ModelStatelessWidget<LoginForm> widget) => widget.model.password,
        setter: (ModelStatelessWidget<LoginForm> widget, String password) =>
        widget.model.password = password,
      ),
    );
    ...
  }
```

> When using multiple contexts, the way of `reference binding` should be considered, so that Ref variables can be reused

### Binding views

Fill a WidgetTree with binding
```dart
class ExampleForModelStatelessWidget extends StatelessWidget {
  
  final usernameRef = Ref(
    getter: (ModelStatelessWidget<LoginForm> widget) => widget.model.username,
    setter: (ModelStatelessWidget<LoginForm> widget, String username) =>
    widget.model.username = username,
  );

  Widget build(BuildContext context) {
    /// connecting context
    var builder = BindingBuilder(context);

    var username = builder.createBuildBinding(usernameRef);

    /// no bind
    username.raw;

    var password = builder.createBuildBinding(
      Ref(
        getter: (ModelStatelessWidget<LoginForm> widget) => widget.model.password,
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
          usernameRef,

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
          Ref(
            getter: (ModelStatelessWidget<LoginForm> widget) => widget.model.password,
            setter: (ModelStatelessWidget<LoginForm> widget, String password) =>
            widget.model.password = password,
          ),

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
            'username = ${username.value}\npassword = ${password.value}',
          )),
    );
  }
}
```
> In the example, bind to the TextField input box through `BindingTextField`, and bind the value to the Text view through `value`. `raw` will not generate binding;
>
> Modify from specified value through `username.value = '来自指定值的修改'` Assign values to immediately generate page
> refresh;
>
> `BindingTextField` also provides `valueToString` and `stringToValue` for more formatted input and output. For more
> bundling methods, please refer to the [Bind Control section]().

## AutoBinding advantages

* Field level comparison: More precise triggering, smaller view refresh range, and higher performance.

> The traditional comparison method is object level comparison, and the general approach is to compare the entire object
> in the ChangeNotify. addListener() or didChangeDependencies() function. Changes will only trigger the corresponding view
> refresh;
>
>However, complex objects cannot achieve recursive multi-level attributes, resulting in inaccurate comparison results.
>
>Another approach is to overload the equal sign operator or rewrite the hashCode. Although this reduces the complexity,
> in practical business, sometimes we want its comparison rules to be multiple in different situations. In this case, you
> can only write another class with almost the same structure to have different comparison rules.
>
>Moreover, overloading operators makes it difficult to introduce variables other than class members for comparison. So
> when the object itself is not sufficient for comparison, a lot of bloated code will be generated for comparison and
> debugging purposes.
>
>Even more deadly is that if there are two different types of data, but they are actually the same, an additional
> modification synchronization mechanism for the two sets of data needs to be established.

> The characteristic of field level comparison is to only compare fields that generate trigger events, and skip data
> that does not trigger events even if changes occur.
>
>Moreover, field level comparison does not depend on whether the objects to which the field belongs are equal, and can
> even be compared with different types.
>
>Field comparison can also easily introduce external variables to participate in calculation rules. In principle, the
> rules for field values are the rules for field comparison;

* Field level binding: establishes independent dependency relationships for each field to achieve bidirectional
  synchronization between the field and the view.

> Traditional event triggering, because it is impossible to determine how much data this change will affect the view, is
> usually a large-scale repeated refresh of the page.
>
>Field level binding will collect views with dependencies for each field. After all comparisons are completed, the
> system will refresh the view based on the dependencies of the changed fields.
>
>In principle, which views reference a field can determine which views depend on its updates.
>
>Of course, if the view is modified, it will also be written back from the page to the field through dependency
> relationships.
>
>Due to the analysis of value changes and dependencies within the system, the annoying setState () no longer needs to be
> used. In fact, data changes may affect multiple views, and the value of setState () for a single view is not high, and
> it is not recommended to use it.

* Progressive development reduces refactoring

> We have been thinking about a question, whether a Flutter project can be fully planned from the beginning of project
> creation, which data is shared, and which functions will be called.
>
>We believe that the vast majority of projects should evolve from simple to complex processes, even if state management
> has been established, new data may be merged and migrated in at any time.
>
>So we believe that reducing the cost of setup and migration is very important

> What steps do we need to go through to transition from a regular page to a regular state management framework
> 1. Need to extract shared data to create a new Model class and delete local data on the page;
> 2. Then, in order for the Model to collect comparative data, all read and write operations on shared data scattered on
> the page are extracted into the Model class and made into functions, deleting local code fragments on the page and
> converting them into function calls;
> 3. Finally, it is necessary to consider which widgets need to retain data during full refresh and may need to be
> rewritten as StatefulWidget
> The reason why this step occurs is that some callbacks may be directly called and completed now, but because
> centralized delay processing is required (object level comparison cannot execute notifyListeners() every time a data
> change is made, it must be concentrated until the end), there will be additional data parameters at the restore site,
> and how to preserve the data at the restore site
> Traditional state management provides manual invocation of updates, with developers making their own decisions on when
> to invoke them But if multiple data changes are not in the same place, you actually don't know the last refresh call So
> it's refreshing every time, but it's very inefficient

> Let's take a look at how AutoBinding reduces renovation costs?
>
>1. Firstly, the data provider of AutoBinding is designed to be just a regular data object There is no need for a
> ChangNotify (provider's solution) with triggering capability, nor does it require additional inheritance from
> GetxController (GetX's solution)
>
>The data provider for AutoBinding only needs to be a State or StatelessWidget, and from this point on, the Widget where
> the original data owner is located can be directly used for data sharing;
>
>2. Secondly, we oppose selecting functions with high page relevance as data providers simply because controlling refresh
> in data providers would reduce the number of times
>
>Our refresh mechanism is ensured by the dependency relationship of field binding, rather than developers calling
> notifyListeners() on their own (in reality, it only shifts the problem onto the developers);
>
>Due to field level dependencies, delayed/asynchronous scenes are essentially preserved Since the site has been
> preserved, there is no need to maintain additional status So just keep the function calls as they are
>
>Finally, we need to create a series of field level Ref references and Binding binding objects, and replace all local
> values with values from the Binding object
>
>From the perspective of local pages, Binding is like downloading a copy of shared data for local use
>
>After completing the above steps, status management can start working, isn't it very simple?

> Subsequent maintenance of AutoBinding setup:
> * Consider selecting functions with high reusability almost as they are from data providers, only considering
> reusability;
> * Consider migrating local fields to data providers, only considering reusability;

<h4>If you think our framework is good, like/email for communication.</h4>
<ellise@qq.com>

[AutoBinding](https://pub.dev/packages/auto_binding)
