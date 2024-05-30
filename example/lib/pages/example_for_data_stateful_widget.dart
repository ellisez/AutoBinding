import 'package:flutter/material.dart';
import 'package:data_binding/data_binding.dart';
import 'package:data_binding/widget/text_field.dart';

class ExampleForDataStatefulWidget extends DataStatefulWidget {
  ExampleForDataStatefulWidget({super.key});

  @override
  ExampleForDataState createState() => ExampleForDataState();
}

class ExampleForDataState extends DataState<ExampleForDataStatefulWidget> {
  String username = '';
  String password = '';

  @override
  Widget builder(BuildContext context) => const CallDataStatefulWidget();
}

class CallDataStatefulWidget extends StatefulWidget {
  const CallDataStatefulWidget({super.key});

  @override
  State<StatefulWidget> createState() => CallDataState();
}

class CallDataState extends State<CallDataStatefulWidget> {
  var usernameRef = StateRef(
    getter: (ExampleForDataState state) => state.username,
    setter: (ExampleForDataState state, String username) =>
        state.username = username,
  );

  var passwordRef = StateRef(
    getter: (ExampleForDataState state) => state.password,
    setter: (ExampleForDataState state, String password) =>
        state.password = password,
  );

  @override
  Widget build(BuildContext context) {
    var username = usernameRef.connect(context);

    username.value;

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
                const Text(
                    'DataBinding example for subclass of DataStatefulWidget.',
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
                        DataState.of<ExampleForDataState>(context)
                            ?.notifyDependents();
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
