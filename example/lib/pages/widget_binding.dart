import 'package:example/your_model.dart';
import 'package:flutter/material.dart';

class WidgetBindingPage extends StatefulWidget {
  const WidgetBindingPage({super.key});

  @override
  State<StatefulWidget> createState() => DataBindingState();
}

class DataBindingState extends State<WidgetBindingPage> {
  late YourBinding dataBinding;

  @override
  void initState() {
    dataBinding = YourBinding();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: true,
      title: const Text('Data binding'),
    ),
    body: Center(
          child: Column(
            children: [
              const Text('Free Binding', style: TextStyle(fontWeight: FontWeight.bold),),
              const Divider(),
              TextField(
                controller:
                    dataBinding.textField(dataBinding.nullableString ?? ''),
                onChanged: (value) {
                  dataBinding.nullableString = value;
                },
              ),
              Text(dataBinding.nullableString ?? ''),
            ],
          ),
        ),
  );
}
