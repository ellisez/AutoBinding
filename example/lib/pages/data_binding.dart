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
                    const Text(
                      'use raw widget',
                      style: TextStyle(),
                    ),
                    const Divider(),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: TextField(
                        controller: dataBinding.textField('nullableString'),// must be
                        onChanged: (value) {// must be
                          dataBinding.nullableString = value;
                          setState(() {});
                        },
                      ),
                    ),
                    Text('外部更新点1：${dataBinding.nullableString ?? ''}'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  children: [
                    const Text(
                      'Minimum Binding',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'use TextFieldBinding, only refresh controller',
                      style: TextStyle(),
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
                    Text('外部更新点2：${dataBinding.nullableString ?? ''}'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  children: [
                    const Text(
                      'Custom Binding',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'use TextFieldBinding, specify context',
                      style: TextStyle(),
                    ),
                    const Divider(),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: TextFieldBinding(
                        binding: dataBinding,
                        property: 'nullableString',
                        /// Specify the context to implement local refresh
                        context: context,
                      ),
                    ),
                    Text('外部更新点3：${dataBinding.nullableString ?? ''}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
