import 'package:example/your_model.dart';
import 'package:flutter/material.dart';
import 'package:model_binding/binding/binding.dart';

class DataBindingPage extends StatefulWidget {
  const DataBindingPage({super.key});

  @override
  State<StatefulWidget> createState() => DataBindingState();
}

class DataBindingState extends State<DataBindingPage> {
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
        body: Row(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  children: [
                    const Text(
                      'Free Binding',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: TextField(
                        controller: dataBinding.textField('nullableString'),
                        onChanged: (value) {
                          dataBinding.nullableString = value;
                          setState(() {});
                        },
                      ),
                    ),
                    Text(dataBinding.nullableString ?? ''),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  children: [
                    const Text(
                      'Only Widget Self Binding',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: TextFieldBinding(
                        binding: dataBinding,
                        property: 'nullableString',
                      ),
                    ),
                    Text(dataBinding.nullableString ?? ''),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  children: [
                    const Text(
                      'All Widget Self Binding',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: TextFieldBinding(
                        binding: dataBinding,
                        property: 'nullableString',
                        context: context,
                      ),
                    ),
                    Text(dataBinding.nullableString ?? ''),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
