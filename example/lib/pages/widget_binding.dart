import 'package:example/your_model.dart';
import 'package:flutter/material.dart';
import 'package:model_binding/model_binding.dart';

class WidgetBindingPage extends StatefulWidget {
  const WidgetBindingPage({super.key});

  @override
  State<StatefulWidget> createState() => WidgetBindingState();
}

class WidgetBindingState extends State<WidgetBindingPage>
    with BindingSupport<WidgetBindingPage, SuperBinding> {
  @override
  late SuperBinding binding;
  RefreshMode mode = RefreshMode.self;

  @override
  void initState() {
    binding = SuperBinding();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: const Text('Widget src.binding'),
        ),
        body: Center(
          child: Column(
            children: [
              RefreshableBuilder(
                builder: (context) => Column(
                  children: [
                    RadioListTile<RefreshMode>(
                        title: const Text('self: only control rebuild'),
                        value: RefreshMode.self,
                        groupValue: mode,
                        onChanged: (value) {
                          mode = value!;
                          setState(() {});
                        }),
                    RadioListTile<RefreshMode>(
                        title: const Text('partially: find RefreshableBuilder to rebuild'),
                        value: RefreshMode.partially,
                        groupValue: mode,
                        onChanged: (value) {
                          mode = value!;
                          setState(() {});
                        }),
                    const Text(
                      'Both self and partially based on context arguments',
                      style: TextStyle(),
                    ),
                    const Divider(),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: TextFieldBinding(
                        binding: binding,
                        property: 'nullableString',
                        mode: mode,
                        //context: context, // base on from
                      ),
                    ),
                    Text('partially refresh point：${binding.nullableString ?? ''}'),
                  ],
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Text('refresh outside')),
              Text('outside refresh point：${ModelBinding.of<WidgetBindingState, SuperBinding>(context)?.nullableString ?? ''}'),
            ],
          ),
        ),
      );
}
