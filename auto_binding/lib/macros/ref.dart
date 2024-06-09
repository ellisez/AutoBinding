import 'dart:async';

import 'package:macros/macros.dart';

/// 1. 创建引用类
///
/// 2. 扫描原属性, 创建新成员成员
///
/// 3. 添加toRef()
macro class RefCodable
    implements
        ClassDeclarationsMacro,
        ClassDefinitionMacro,
        FieldDeclarationsMacro,
        FieldDefinitionMacro {
  const RefCodable();

  Future<Identifier> _RefIdentifier(TypePhaseIntrospector builder) =>
      // ignore: deprecated_member_use
  builder.resolveIdentifier(
      Uri.parse('package:auto_binding/core/inject.dart'), 'Ref');

  FutureOr<List<Object>> _RefNamedTypeParts(TypePhaseIntrospector builder,
      Object namedType) async =>
      [
        await _RefIdentifier(builder), '<', namedType, '>',
      ];

  FutureOr<void> _buildFieldRef(FieldDeclaration field,
      TypePhaseIntrospector builder, Identifier refClassName,
      List<Object> codeParts) async {
    var sourceFieldName = field.identifier.name;
    Object sourceFieldType = field.type.code;
    if (field.type is OmittedTypeAnnotation) {
      // ignore: deprecated_member_use
      sourceFieldType = await builder.resolveIdentifier(
          Uri.parse('dart:core'), 'dynamic');
    }
    if (sourceFieldName.startsWith('_')) {
      return;
    }
    var targetFieldName = '${sourceFieldName}Ref';
    var targetFieldNamedTypeParts = await _RefNamedTypeParts(
        builder, sourceFieldType);
    codeParts.addAll([
      '''
  late final ''',
      ...targetFieldNamedTypeParts,
      ''' _${targetFieldName} = ''',
      refClassName,
      '''(
    getter: () => ${sourceFieldName},
    setter: (''',
      sourceFieldType,
      ''' ${sourceFieldName}) => ${sourceFieldName} = ${sourceFieldName},
  );
''',
      '\n',
      '  ',
      ...targetFieldNamedTypeParts,
      ' get ${targetFieldName} => _${targetFieldName};',
      '\n\n',
    ]);
  }

  bool hasClassAnnotation(ClassDeclaration clazz) {
    for (var meta in clazz.metadata) {
      if (meta is ConstructorMetadataAnnotation &&
          meta.type.identifier.name == 'RefCodable') {
        return true;
      }
    }
    return false;
  }

  bool hasIgnoreRefCodable(FieldDeclaration field) {
    for (var meta in field.metadata) {
      if (meta is IdentifierMetadataAnnotation &&
          meta.identifier.name == 'IgnoreRefCodable') {
        return true;
      }
    }
    return false;
  }

  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz,
      MemberDeclarationBuilder builder) async {
    var refClassName = await _RefIdentifier(builder);

    List<Object> codeParts = [];

    var fields = await builder.fieldsOf(clazz);
    for (var field in fields) {
      if (hasIgnoreRefCodable(field)) {
        continue;
      }
      await _buildFieldRef(field, builder, refClassName, codeParts);
    }

    builder.declareInType(DeclarationCode.fromParts(codeParts));
  }

  @override
  FutureOr<void> buildDefinitionForClass(ClassDeclaration clazz,
      TypeDefinitionBuilder builder) async {
    Map<String, FieldDeclaration> sourceFields = {};
    Map<String, FieldDeclaration> targetFields = {};

    var fields = await builder.fieldsOf(clazz);
    for (var field in fields) {
      if (hasIgnoreRefCodable(field)) {
        continue;
      }
      var fieldName = field.identifier.name;
      if (fieldName.startsWith('_') && fieldName.endsWith('Ref')) {
        var sourceFieldName = fieldName.substring(
            1, fieldName.length - 'Ref'.length);
        targetFields[sourceFieldName] = field;
      } else {
        sourceFields[fieldName] = field;
      }
    }

    for (var item in targetFields.entries) {
      var sourceField = sourceFields[item.key]!;
      var targetField = item.value;

      var sourceFieldType = sourceField.type;
      if (sourceFieldType is OmittedTypeAnnotation) {
        sourceFieldType = await builder.inferType(sourceFieldType);
        var targetFieldNamedTypeParts = await _RefNamedTypeParts(
            builder, sourceFieldType.code);

        var targetFieldName = targetField.identifier.name;
        var fieldBuilder = await builder.buildField(targetField.identifier);
        var publicFieldName = targetFieldName.substring(1);
        fieldBuilder.augment(getter: DeclarationCode.fromParts([
          ...targetFieldNamedTypeParts,
          ' get ${publicFieldName} => ${targetFieldName} as ',
          ...targetFieldNamedTypeParts,
          ';\n',
        ]),
        );
      }
    }
  }

  @override
  FutureOr<void> buildDeclarationsForField(FieldDeclaration field,
      MemberDeclarationBuilder builder) async {
    var clazz = await builder.typeDeclarationOf(
        field.definingType) as ClassDeclaration;

    if (hasClassAnnotation(clazz)) {
      return;
    }

    if (hasIgnoreRefCodable(field)) {
      return;
    }

    var refClassName = await _RefIdentifier(builder);

    List<Object> codeParts = [];

    await _buildFieldRef(field, builder, refClassName, codeParts);

    builder.declareInType(DeclarationCode.fromParts(codeParts));
  }

  @override
  FutureOr<void> buildDefinitionForField(FieldDeclaration field,
      VariableDefinitionBuilder builder) async {
    var clazz = await builder.typeDeclarationOf(
        field.definingType) as ClassDeclaration;

    if (hasClassAnnotation(clazz)) {
      return;
    }

    if (hasIgnoreRefCodable(field)) {
      return;
    }

    if (field.type is OmittedTypeAnnotation) {
      var sourceFieldType = await builder.inferType(
          field.type as OmittedTypeAnnotation);
      var sourceFieldName = field.identifier.name;
      var publicFieldName = '${sourceFieldName}Ref';
      var targetFieldName = '_${publicFieldName}';

      var targetFieldNamedTypeParts = await _RefNamedTypeParts(
          builder, sourceFieldType.code);

      builder.augment(getter: DeclarationCode.fromParts([
        ...targetFieldNamedTypeParts,
        ' get ${publicFieldName} => ${targetFieldName} as ',
        ...targetFieldNamedTypeParts,
        ';\n',
      ]),
      );
    }
  }


}

const Object IgnoreRefCodable = Null;
