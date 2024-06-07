import 'package:auto_binding/core/inject.dart';
import 'package:example/models/login_form.dart';
import 'package:flutter/widgets.dart';

extension ref on LoginForm {
  LoginFormRef toRef() => LoginFormRef(this);
}

class LoginFormRef extends Ref<LoginForm> {
  LoginForm _raw;

  LoginFormRef(this._raw) : super.of(_raw);

  // 声明字段
  late final Ref<String> username = Ref(
    getter: () => _raw.username,
    setter: (String username) => _raw.username = username,
  );

  late final Ref<String> password = Ref(
    getter: () => _raw.password,
    setter: (String password) => _raw.password = password,
  );

  late final InfoProxy info = InfoProxy(_raw.info);
}

class InfoProxy extends Ref<Info> {
  Info _raw;

  Info get $raw => _raw;

  InfoProxy(this._raw) : super.of(_raw);

  late final Ref<String> nickName = Ref(
    getter: () => _raw.nickName,
    setter: (String nickName) => _raw.nickName = nickName,
  );

  late final Ref<String> gender = Ref(
    getter: () => _raw.gender,
    setter: (String gender) => _raw.gender = gender,
  );
}
