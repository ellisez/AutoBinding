import 'package:example/your_model.dart';
import 'package:flutter/material.dart';
import 'package:model_binding/model_binding.dart';

class SyncWidgetBinding extends StatefulWidget {
  const SyncWidgetBinding({super.key});

  @override
  State<StatefulWidget> createState() => SyncWidgetBindingState();
}

class SyncWidgetBindingState
    extends BindingState<SyncWidgetBinding, SuperBinding> {
  /// BindingState Can be found by subWidget
  @override
  SuperBinding binding = SuperBinding();

  @override
  void initState() {
    super.initState();

    /// binding super widget
    binding.$sync(
      fields: ['nullableString'],
      callback: () {
        setState(() {});
      },
      notifierType: NotifierType.textField,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Cross level call',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text('sync in SupperWidget:'),
            SizedBox(
              width: 150,
              child: TextFieldBinding(
                binding: binding,
                property: 'nullableString',
                //context: context, // base on from
              ),
            ),
            const Divider(),
            const SubWidget(),
          ],
        ),
      ),
    );
  }
}

class SubWidget extends StatefulWidget {
  const SubWidget({super.key});

  @override
  State<StatefulWidget> createState() => SubWidgetState();
}

class SubWidgetState extends State<SubWidget> {
  SubBinding subBinding = SubBinding();

  @override
  void initState() {
    super.initState();

    /// binding sub widget
    ModelBinding.of<SyncWidgetBindingState, SuperBinding>(context)?.$bindSync(
      subBinding,
      context: context,
      fields: ['nullableString'],
      notifierType: NotifierType.textField,

      /// support TextField
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('sync in SubWidget:'),
        SizedBox(
          width: 100,
          child: TextFieldBinding(
            binding: subBinding,
            property: 'nullableString',
            //context: context, // base on from
          ),
        ),
      ],
    );
  }
}
