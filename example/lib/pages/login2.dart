import 'package:example/models/login_form.dart';
import 'package:flutter/material.dart';
import 'package:model_binding/model_binding.dart';
import '../models/login_form.g.dart';

/*
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DefaultState();
  }
}

class _DefaultState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // 步骤一: 创建可供绑定的模型
  // Step 1: create model for binding
  var binding = LoginFormBinding("", "");

  // 步骤二: 注册切换widget事件
  // Step 2: register didUpdateWidget() to update the new widget
  @override
  void didUpdateWidget(LoginPage oldWidget) {
    binding.didUpdateWidget(oldWidget, widget);
    super.didUpdateWidget(oldWidget);
  }

  // 步骤三: 注册销毁事件, 解绑widget
  // Step 3: register dispose() to unbind widget
  @override
  void dispose() {
    binding.unbind(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 步骤四: 建立绑定widget, 必须在build()里有且只有一次调用
    // Step 4: bind to widget, it must be called only once in the build()
    var binder = binding.bind(this);
    debugPrint('父视图发生刷新');
    return Scaffold(
      body: Container(
          alignment: Alignment.center,
          // color: Colors.white,
          child: SizedBox(
              width: 400,
              height: 600,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text('ModelBinding',
                        style: TextStyle(
                            fontSize: 36,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    const Text('轻便的MVVM双向绑定的框架',
                        style: TextStyle(fontSize: 16, color: Colors.black38)),
                    const SizedBox(height: 30),
                    TextField(
                      controller:
                          // 步骤五-1: 绑定到TextField
                          // Step 5-1: bind to TextField
                          binder.username.bindToTextEditingController(null),
                      decoration: const InputDecoration(
                        labelText: '用户名',
                        hintText: '请输入用户名',
                      ),
                      style: const TextStyle(
                          color: Colors.indigo, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller:
                          // 步骤五-1: 绑定到TextField
                          // Step 5-1: bind to TextField
                          binder.password.bindToTextEditingController(null),
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
                                '${binding.username}, ${binding.password}');
                          },
                          style: const ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll<Color>(
                                Colors.lightBlue),
                            foregroundColor:
                                MaterialStatePropertyAll<Color>(Colors.white),
                          ),
                          child: const Text('打印当前值'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            // 步骤六:
                            binding.username = '来自指定值的修改';
                            binding.password = '来自指定值的修改';
                          },
                          style: const ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll<Color>(
                                Colors.lightBlue),
                            foregroundColor:
                                MaterialStatePropertyAll<Color>(Colors.white),
                          ),
                          child: const Text('更改当前值'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            // 步骤六:
                            setState(() {});
                          },
                          style: const ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll<Color>(
                                Colors.lightBlue),
                            foregroundColor:
                            MaterialStatePropertyAll<Color>(Colors.white),
                          ),
                          child: const Text('强行刷新'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Builder(builder: (subContext) {
                      debugPrint('子视图发生刷新');
                      return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 10),
                          color: Colors.blueGrey,
                          child: Text(
                            'username = ${binder.username.bindTo(subContext)}\npassword = ${binding.password}',
                            //style: const TextStyle(color: Colors.white),
                          ));
                    }),
                  ],
                ),
              ))),
    );
  }
}
*/
