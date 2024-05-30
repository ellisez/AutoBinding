import 'package:example/models/login_form.dart';
import 'package:flutter/material.dart';
import 'package:data_binding/data_binding.dart';
import 'package:data_binding/widget/text_field.dart';

class ExampleForModelStatefulWidget extends StatefulWidget {
  const ExampleForModelStatefulWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DefaultState();
  }
}

class _DefaultState extends State<ExampleForModelStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return ModelStatefulWidget<LoginForm>(
      model: LoginForm("", ""),
      child: CallModelState(),
    );
  }
}

class CallModelState extends StatelessWidget {
  CallModelState({super.key});

  final usernameRef = StateRef(
    getter: (ModelState<LoginForm> state) => state.model.username,
    setter: (ModelState<LoginForm> state, String username) =>
        state.model.username = username,
  );

  final passwordRef = StateRef(
    getter: (ModelState<LoginForm> state) => state.model.password,
    setter: (ModelState<LoginForm> state, String password) =>
        state.model.password = password,
  );

  @override
  Widget build(BuildContext context) {
    var username = usernameRef.connect(context);

    // username.bindTo();

    var password = passwordRef.connect(context);
    debugPrint('父视图发生刷新');
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        // color: Colors.white,
        child: SizedBox(
          width: 400,
          height: 600,
          child: Form(
            child: Column(
              children: [
                const Text('DataBinding example for ModelStatefulWidget.',
                    style: TextStyle(
                        fontSize: 36,
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text('轻便的MVVM双向绑定的框架',
                    style: TextStyle(fontSize: 16, color: Colors.black38)),
                const SizedBox(height: 30),
                BindingTextField(
                  username,
                  decoration: const InputDecoration(
                    labelText: '用户名',
                    hintText: '请输入用户名',
                  ),
                  style: const TextStyle(
                      color: Colors.indigo, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                BindingTextField(
                  password,
                  decoration: const InputDecoration(
                    labelText: '密码',
                    hintText: '请输入密码',
                  ),
                  obscureText: true,
                  style: const TextStyle(
                      color: Colors.indigo, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        debugPrint('${username.value}, ${password.value}');
                      },
                      style: const ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll<Color>(Colors.lightBlue),
                        foregroundColor:
                            WidgetStatePropertyAll<Color>(Colors.white),
                      ),
                      child: const Text('打印当前值'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        username.value = '来自指定值的修改';
                        password.value = '来自指定值的修改';
                      },
                      style: const ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll<Color>(Colors.lightBlue),
                        foregroundColor:
                            WidgetStatePropertyAll<Color>(Colors.white),
                      ),
                      child: const Text('更改当前值'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        ModelState.of<ModelState<LoginForm>>(context)?.notifyDependents();
                      },
                      style: const ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll<Color>(Colors.lightBlue),
                        foregroundColor:
                            WidgetStatePropertyAll<Color>(Colors.white),
                      ),
                      child: const Text('强行刷新'),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Builder(builder: (subContext) {
                  debugPrint('子视图发生刷新');
                  var username = usernameRef.connect(subContext);
                  var password = passwordRef.connect(subContext);
                  return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 10),
                      color: Colors.blueGrey,
                      child: Text(
                        'username = ${username.bindTo()}\npassword = ${password.bindTo()}',
                        //style: const TextStyle(color: Colors.white),
                      ));
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
