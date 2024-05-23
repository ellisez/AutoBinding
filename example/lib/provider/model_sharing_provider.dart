import 'package:example/models/login_form.dart';
import 'package:model_binding/model_binding.dart';

class ModelSharingProvider extends ModelProvider {
  LoginForm loginForm = LoginForm("", "");

  ModelSharingProvider({super.key, required super.child});
}
