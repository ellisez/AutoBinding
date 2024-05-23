part of annotation;

/// binding annotation
class Binding {
  /// classname
  final String? classname;

  /// binding annotation
  const Binding(String? classname) : this.classname = classname;
}

class Inject {
  const Inject({
    required String name,
    required String provider,
    required Map<String, String> props,
    Map<String, List>? notifiers,
  });
}
