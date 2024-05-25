part of annotation;

/// binding annotation
class Binding {
  /// classname
  final String? classname;

  /// binding annotation
  const Binding(String? classname) : this.classname = classname;
}

class Provider {
  const Provider({
    required String name,
    required Map<String, List> props,
  });
}

class DependOn {
  const DependOn(
    String name, {
    required List<DependModel> models,
  });
}

class DependModel {
  const DependModel(
    Type provider, {
    required List<DependProperty> props,
  });
}

class DependProperty {
  const DependProperty(
    String name, {
    required Type type,
    required String exp,
    bool? supportInput,
  });
}
