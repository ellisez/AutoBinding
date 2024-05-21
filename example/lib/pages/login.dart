import 'package:example/models/login_form.dart';
import 'package:flutter/material.dart';
import 'package:model_binding/model_binding.dart';
import '../models/login_form.g.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DefaultState();
  }
}

class _DefaultState extends BindingState<LoginFormViewModel, LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  LoginFormViewModel data = LoginFormViewModel("", "");

  @override
  Widget build(BuildContext context) {
    var binder = data.getBinder(this);
    return Scaffold(
      body: Container(
          alignment: Alignment.center,
          // color: Colors.white,
          child: SizedBox(
              width: 300,
              height: 400,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text('Modeling',
                        style: TextStyle(
                            fontSize: 36,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    const Text('面向模型的渐进式原型设计工具',
                        style: TextStyle(fontSize: 16, color: Colors.black38)),
                    const SizedBox(height: 30),
                    TextField(
                      controller:
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
                    ElevatedButton(
                      onPressed: () async {
                        //var navigator = Navigator.of(context);

                        if (_formKey.currentState!.validate()) {
                          debugPrint('${data.username}, ${data.password}');
                          setState(() {
                            data.username = 'abc';
                          });
                        }
                      },
                      style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll<Color>(Colors.lightBlue),
                      ),
                      child: const Text('登录 & 注册'),
                    )
                  ],
                ),
              ))),
    );
  }
}
