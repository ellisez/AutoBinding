import 'package:example/pages/example_for_data_stateful_widget.dart';
import 'package:example/pages/example_for_data_stateless_widget.dart';
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
        title: 'DataBinding Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routes: {
          '/': (_) => const MyHomePage(title: 'DataBinding Demo Home Page'),
          '/ExampleForModelStatefulWidget': (_) => const ExampleForModelStatefulWidget(),
          '/ExampleForModelStatelessWidget': (_) => ExampleForModelStatelessWidget(),
          '/ExampleForDataStatefulWidget': (_) => ExampleForDataStatefulWidget(),
          '/ExampleForDataStatelessWidget': (_) => ExampleForDataStatelessWidget(),
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
                  Navigator.of(context).pushNamed('/ExampleForModelStatefulWidget');
                },
                child: const Text('Example for ModelStatefulWidget')),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/ExampleForModelStatelessWidget');
                },
                child: const Text('Example for ModelStatelessWidget')),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/ExampleForDataStatefulWidget');
                },
                child: const Text('Example for subclass of DataStatefulWidget')),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/ExampleForDataStatelessWidget');
                },
                child: const Text('Example for subclass of DataStatelessWidget')),
          ),
        ],
      ),
    );
  }
}
