import 'package:example/pages/login.dart';

import 'package:flutter/material.dart';
import 'package:model_binding/annotation/library.dart';
import 'package:model_binding/widget/model_provider.dart';

import 'models/login_form.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This src.widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ModelStatefulWidget<LoginForm>(
      model: LoginForm("", ""),
      builder: (context) => MaterialApp(
        title: 'ModelBinding Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routes: {
          '/': (_) => const MyHomePage(title: 'ModelBinding Demo Home Page'),
          '/login': (_) => const LoginPage(),
        },
        initialRoute: '/',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

@Provider(
  name: 'ModelSharingProvider',
  props: {},
)
class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/login');
                },
                child: const Text('Example')),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
