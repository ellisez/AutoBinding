import 'package:example/models/login_form.dart';
import 'package:flutter/material.dart';
import 'package:auto_binding/auto_binding.dart';
import 'package:auto_binding/widget/text_field.dart';

class ExampleForDataStatelessWidget extends DataStatelessWidget {
  final loginForm = LoginForm('', '');

  ExampleForDataStatelessWidget();

  final usernameRef = Ref(
    getter: (ExampleForDataStatelessWidget widget) => widget.loginForm.username,
    setter: (ExampleForDataStatelessWidget widget, String username) =>
        widget.loginForm.username = username,
  );

  final passwordRef = Ref(
    getter: (ExampleForDataStatelessWidget widget) => widget.loginForm.password,
    setter: (ExampleForDataStatelessWidget widget, String password) =>
        widget.loginForm.password = password,
  );

  @override
  Widget builder(BuildContext context) {
    var builder = BindingBuilder(context);

    var username = builder.createBuildBinding(usernameRef);

    username.value;

    var password = builder.createBuildBinding(passwordRef);
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
                const Text('DataBinding example for DataStatelessWidget.',
                    style: TextStyle(
                        fontSize: 36,
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text('轻便的MVVM双向绑定的框架',
                    style: TextStyle(fontSize: 16, color: Colors.black38)),
                const SizedBox(height: 30),
                BindingTextField(
                  usernameRef,
                  decoration: const InputDecoration(
                    labelText: '用户名',
                    hintText: '请输入用户名',
                  ),
                  style: const TextStyle(
                      color: Colors.indigo, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                BindingTextField(
                  passwordRef,
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
                        DataStatelessWidget.of(context)?.notifyDependents();
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
                  var builder = BindingBuilder(subContext);

                  var username = builder.createBuildBinding(
                    Ref(
                      getter: (ExampleForDataStatelessWidget widget) =>
                          widget.loginForm.username,
                      setter: (ExampleForDataStatelessWidget widget,
                              String username) =>
                          widget.loginForm.username = username,
                    ),
                  );

                  var password = builder.createBuildBinding(
                    Ref(
                      getter: (ExampleForDataStatelessWidget widget) =>
                          widget.loginForm.password,
                      setter: (ExampleForDataStatelessWidget widget,
                              String password) =>
                          widget.loginForm.password = password,
                    ),
                  );
                  return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 10),
                      color: Colors.blueGrey,
                      child: Text(
                        'username = ${username.value}\npassword = ${password.value}',
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
