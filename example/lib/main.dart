import 'package:example/pages/example_for_model_provider_state.dart';
import 'package:example/pages/example_for_model_provider_widget.dart';
import 'package:example/pages/example_for_model_stateful_widget.dart';
import 'package:example/pages/example_for_model_stateless_widget.dart';

import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This src.widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ModelBinding Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routes: {
          '/': (_) => const MyHomePage(title: 'ModelBinding Demo Home Page'),
          '/exampleForModelStatefulWidget': (_) => const ExampleForModelStatefulWidget(),
          '/exampleForModelStatelessWidget': (_) => ExampleForModelStatelessWidget(),
          '/exampleForModelProviderState': (_) => const ExampleForModelProviderStatefulWidget(),
          '/exampleForModelProviderWidget': (_) => ExampleForModelProviderWidget(),
        },
        initialRoute: '/',
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

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
                  Navigator.of(context).pushNamed('/exampleForModelStatefulWidget');
                },
                child: const Text('Example for ModelStatefulWidget')),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/exampleForModelStatelessWidget');
                },
                child: const Text('Example for ModelStatelessWidget')),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/exampleForModelProviderState');
                },
                child: const Text('Example for subclass of ModelProviderState')),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/exampleForModelProviderWidget');
                },
                child: const Text('Example for subclass of ModelProviderWidget')),
          ),
        ],
      ),
    );
  }
}
