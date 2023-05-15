import 'package:example/pages/data_binding.dart';
import 'package:example/pages/widget_binding.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
        '/dataBinding': (_) => const DataBindingPage(),
        '/widgetBinding': (_) => const WidgetBindingPage(),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/dataBinding');
                },
                child: const Text('DataBinding Example')),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/widgetBinding');
                },
                child: const Text('WidgetBinding Example')),
          ],
        ),
      ),
    );
  }
}
