import 'dart:collection';

class MapBinding extends MapMixin {
  final Map<String, dynamic> _data;

  MapBinding([Map<String, dynamic>? data]): _data = data ?? {};

  @override
  operator [](Object? key) {
    // TODO: implement []
    throw UnimplementedError();
  }

  @override
  void operator []=(key, value) {
    // TODO: implement []=
  }

  @override
  void clear() {
    // TODO: implement clear
  }

  @override
  // TODO: implement keys
  Iterable get keys => throw UnimplementedError();

  @override
  remove(Object? key) {
    // TODO: implement remove
    throw UnimplementedError();
  }
  
}