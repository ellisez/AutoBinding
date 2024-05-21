import 'package:model_binding/model_binding.dart';

@Binding("LoginFormViewModel")
class LoginForm {
  String username;
  String password;

  LoginForm(this.username, this.password);
}
