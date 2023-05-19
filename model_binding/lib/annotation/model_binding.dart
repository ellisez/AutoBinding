part of annotation;

/// binding annotation
class Binding {
  /// type converts
  final Map<Type, String> converts;
  /// field settings
  final List<Property> properties;

  /// binding annotation
  const Binding(this.properties, {this.converts  = const {}});

}