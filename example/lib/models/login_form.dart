class LoginForm {
  String username;
  String password;

  Info info = Info(nickName: '', gender: 'man');

  LoginForm(this.username, this.password);

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
  };

  static LoginForm fromJson(Map<String, dynamic> json) {
    var loginForm = LoginForm(json['username'], json['password']);
    loginForm.info = Info.fromJson(json['password']);
    return loginForm;
  }
}

class Info {
  String nickName;
  String gender;

  Info({required this.nickName, required this.gender});

  Map<String, dynamic> toJson() => {
    'nickName': nickName,
    'gender': gender,
  };

  static Info fromJson(Map<String, dynamic> json) =>
      Info(nickName: json['nickname'], gender: json['gender']);
}
