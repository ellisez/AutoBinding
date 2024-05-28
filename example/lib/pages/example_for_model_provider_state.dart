import 'package:flutter/material.dart';
import 'package:model_binding/model_binding.dart';
import 'package:model_binding/widget/text_field.dart';

class ExampleForModelProviderStatefulWidget extends StatefulWidget {
  const ExampleForModelProviderStatefulWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ExampleForModelProviderState();
  }
}

class ExampleForModelProviderState
    extends ModelProviderState<ExampleForModelProviderStatefulWidget> {
  String username = '';
  String password = '';

  @override
  Widget builder(BuildContext context) => const CallModelProvider();
}

class CallModelProvider extends StatefulWidget {
  const CallModelProvider({super.key});

  @override
  State<StatefulWidget> createState() => CallModelProviderState();
}

class CallModelProviderState extends State<CallModelProvider> {

  var usernameRef = StateRef<ExampleForModelProviderState, String>(
    getter: (ExampleForModelProviderState state) => state.username,
    setter: (ExampleForModelProviderState state, String username) =>
        state.username = username,
  );

  var passwordRef = StateRef<ExampleForModelProviderState, String>(
    getter: (ExampleForModelProviderState state) => state.password,
    setter: (ExampleForModelProviderState state, String password) =>
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
                    'ModelBinding example for subclass of ModelProviderState.',
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
                            MaterialStatePropertyAll<Color>(Colors.lightBlue),
                        foregroundColor:
                            MaterialStatePropertyAll<Color>(Colors.white),
                      ),
                      child: const Text('打印当前值'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        // 步骤六:
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
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        // 步骤六:
                        setState(() {});
                      },
                      style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll<Color>(Colors.lightBlue),
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
