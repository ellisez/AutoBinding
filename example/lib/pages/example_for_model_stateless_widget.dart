import 'package:example/models/login_form.dart';
import 'package:flutter/material.dart';
import 'package:auto_binding/auto_binding.dart';
import 'package:auto_binding/widget/text_field.dart';

class ExampleForModelStatelessWidget extends StatelessWidget {
  ExampleForModelStatelessWidget({super.key});

  final usernameRef = Ref.fromData(
    getter: (ModelStatelessWidget<LoginForm> widget) => widget.model.username,
    setter: (ModelStatelessWidget<LoginForm> widget, String username) =>
        widget.model.username = username,
  );

  @override
  Widget build(BuildContext context) {
    return ModelStatelessWidget<LoginForm>(
      model: LoginForm("", ""),
      child: Builder(
        builder: (context) {
          var node = Binding.node(context);

          var username = usernameRef.$nodeOf(node);

          username.value;

          var password = Ref.fromData(
            getter: (ModelStatelessWidget<LoginForm> widget) =>
                widget.model.password,
            setter: (ModelStatelessWidget<LoginForm> widget, String password) =>
                widget.model.password = password,
          ).$nodeOf(node);
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
                      const Text(
                          'DataBinding example for ModelStatelessWidget.',
                          style: TextStyle(
                              fontSize: 36,
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      const Text('轻便的MVVM双向绑定的框架',
                          style:
                              TextStyle(fontSize: 16, color: Colors.black38)),
                      const SizedBox(height: 30),
                      BindingTextField(
                        username.ref,
                        decoration: const InputDecoration(
                          labelText: '用户名',
                          hintText: '请输入用户名',
                        ),
                        style: const TextStyle(
                            color: Colors.indigo, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      BindingTextField(
                        Ref.fromData(
                          getter: (ModelStatelessWidget<LoginForm> widget) =>
                              widget.model.password,
                          setter: (ModelStatelessWidget<LoginForm> widget,
                                  String password) =>
                              widget.model.password = password,
                        ).toRef(context),
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
                              debugPrint(
                                  '${username.value}, ${password.value}');
                            },
                            style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll<Color>(
                                  Colors.lightBlue),
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
                              backgroundColor: WidgetStatePropertyAll<Color>(
                                  Colors.lightBlue),
                              foregroundColor:
                                  WidgetStatePropertyAll<Color>(Colors.white),
                            ),
                            child: const Text('更改当前值'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () async {
                              DataStatelessWidget.of(context)
                                  ?.notifyDependents();
                            },
                            style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll<Color>(
                                  Colors.lightBlue),
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
                        var node = Binding.node(subContext);

                        var username = usernameRef.$nodeOf(node);

                        var password = Ref.fromData(
                          getter: (ModelStatelessWidget<LoginForm> widget) =>
                              widget.model.password,
                          setter: (ModelStatelessWidget<LoginForm> widget,
                                  String password) =>
                              widget.model.password = password,
                        ).$nodeOf(node);
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
        },
      ),
    );
  }
}
