import '../macros/auto_binding.dart';

@RefCodable()
class LoginForm {
  String username = '123';
  String password;

  Info info = Info(nickName: '', gender: 'man');

  LoginForm(this.username, this.password);

}

@RefCodable()
class Info {
  String nickName;
  String gender;

  Info({required this.nickName, required this.gender});

}
