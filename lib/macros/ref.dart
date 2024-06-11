// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:macros/macros.dart';

var _refUri = Uri.parse('package:auto_binding/core/inject.dart');
var _dartCoreUri = Uri.parse('dart:core');

macro class RefCodable
    implements ClassDeclarationsMacro, FieldDeclarationsMacro {
  const RefCodable();

  Future<Identifier> _refIdentifier(TypePhaseIntrospector builder) =>

      builder.resolveIdentifier(_refUri, 'Ref');

  FutureOr<List<Object>> _refNamedTypeParts(TypePhaseIntrospector builder,
      Object namedType) async =>
      [
        await _refIdentifier(builder), '<', namedType, '>',
      ];

  FutureOr<void> _buildFieldRef(FieldDeclaration field,
      DeclarationBuilder builder, Identifier refClassName,
      List<Object> codeParts) async {
    if (field.type is OmittedTypeAnnotation) {
      reportError(builder,
          'Only fields with explicit types are allowed on serializable classes.',
          correctionMessage: 'Please add a type',
          target: field.asDiagnosticTarget);
      return;
    }

    var sourceFieldName = field.identifier.name;
    var sourceFieldType = field.type.code;
    if (sourceFieldName.startsWith('_')) {
      return;
    }

    var assertionError = await builder.resolveIdentifier(
        _dartCoreUri, 'AssertionError');
    var setter = field.hasFinal
        ? [
      'throw ',
      assertionError,
      '("\'$sourceFieldName\' can\'t be used as a setter because it\'s final.")'
    ]
        : ['this.$sourceFieldName = $sourceFieldName'];
    var targetFieldName = '${sourceFieldName}Ref';
    var targetFieldNamedTypeParts = await _refNamedTypeParts(
        builder, sourceFieldType);
    codeParts.addAll([
      '''
  late final ''',
      ...targetFieldNamedTypeParts,
      ''' $targetFieldName = ''',
      refClassName,
      '''(
    getter: () => $sourceFieldName,
    setter: (''',
      sourceFieldType,
      ''' $sourceFieldName) => ''',
      ...setter,
      ''',
  );
''',
    ]);
  }

  bool hasRefCodable(Declaration decl) {
    for (var meta in decl.metadata) {
      if (meta is ConstructorMetadataAnnotation &&
          meta.type.identifier.name == 'RefCodable') {
        return true;
      }
    }
    return false;
  }

  bool hasIgnoreRefCodable(Declaration decl) {
    for (var meta in decl.metadata) {
      if (meta is ConstructorMetadataAnnotation &&
          meta.type.identifier.name == 'IgnoreRefCodable') {
        return true;
      }
    }
    return false;
  }

  void reportError(Builder builder, String message,
      {DiagnosticTarget? target, String? correctionMessage, List<
          DiagnosticMessage>? contextMessages}) {
    builder.report(
        Diagnostic(DiagnosticMessage(message, target: target), Severity.error,
          correctionMessage: correctionMessage,
          contextMessages: contextMessages ?? [],
        ));
  }

  void reportWarning(Builder builder, String message,
      {DiagnosticTarget? target, String? correctionMessage, List<
          DiagnosticMessage>? contextMessages}) {
    builder.report(Diagnostic(
      DiagnosticMessage(message, target: target), Severity.warning,
      correctionMessage: correctionMessage,
      contextMessages: contextMessages ?? [],
    ));
  }

  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz,
      MemberDeclarationBuilder builder) async {
    var refClassName = await _refIdentifier(builder);

    List<Object> codeParts = [];

    var fields = await builder.fieldsOf(clazz);
    for (var field in fields) {
      if (hasRefCodable(field)) {
        reportError(builder,
            '''There is a conflict with the annotation 'RefCodable' of member '${field
                .identifier.name}\'''',
            correctionMessage: 'Please delete itself.');
        return;
      }
    }

    for (var field in fields) {
      if (hasIgnoreRefCodable(field)) {
        continue;
      }
      await _buildFieldRef(field, builder, refClassName, codeParts);
    }

    builder.declareInType(DeclarationCode.fromParts(codeParts));
  }

  @override
  FutureOr<void> buildDeclarationsForField(FieldDeclaration field,
      MemberDeclarationBuilder builder) async {
    var clazz = await builder.typeDeclarationOf(field.definingType);
    if (hasRefCodable(clazz)) {
      return;
    }
    if (hasIgnoreRefCodable(field)) {
      return;
    }

    var refClassName = await _refIdentifier(builder);

    List<Object> codeParts = [];

    await _buildFieldRef(field, builder, refClassName, codeParts);

    builder.declareInType(DeclarationCode.fromParts(codeParts));
  }

}

macro class IgnoreRefCodable implements FieldTypesMacro {
  const IgnoreRefCodable();

  @override
  FutureOr<void> buildTypesForField(FieldDeclaration field,
      TypeBuilder builder) {
  }
}
