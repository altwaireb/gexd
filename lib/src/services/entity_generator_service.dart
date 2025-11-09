import 'package:mason_logger/mason_logger.dart';
import '../core/enums/entity_style.dart';
import '../core/enums/model_style.dart';
import '../core/helpers/string_helpers.dart';
import 'entity_detection_service.dart';
import 'quicktype_service.dart';

/// EntityGeneratorService - Generate Domain entities, optionally from JSON
///
/// This service handles:
/// - Entity generation from scratch or JSON structure
/// - Integration with existing QuicktypeService for JSON parsing
/// - Corresponding Model generation when requested
/// - Clean Architecture domain layer compliance
class EntityGeneratorService {
  final Logger _logger;
  final QuicktypeService _quicktypeService;

  EntityGeneratorService({Logger? logger, QuicktypeService? quicktypeService})
    : _logger = logger ?? Logger(),
      _quicktypeService = quicktypeService ?? QuicktypeService(logger: logger);

  /// Generate Entity from JSON (leveraging existing model generation)
  Future<Map<String, String>> generateFromJson({
    required String entityName,
    required String jsonContent,
    required EntityStyle style,
    bool withModel = false,
    bool immutable = true,
    bool equatable = true,
  }) async {
    try {
      _logger.detail('Generating entity $entityName from JSON');

      // 🚀 الاستفادة من QuicktypeService لتحليل JSON
      final modelFiles = await _quicktypeService.generateFromJson(
        modelName: entityName,
        jsonContent: jsonContent,
        style: _entityStyleToModelStyle(style),
        immutable: immutable,
        copyWith: false, // Entities don't need copyWith typically
        equatable: equatable,
        detectRelationships: true,
      );

      final generatedFiles = <String, String>{};

      // Generate Entity file
      for (final entry in modelFiles.entries) {
        final originalModelContent = entry.value;
        final entityContent = _convertModelToEntity(
          modelContent: originalModelContent,
          entityName: entityName,
          style: style,
        );

        final entityFileName = EntityDetectionService.getEntityFileName(
          entityName,
        );
        generatedFiles[entityFileName] = entityContent;

        // Generate corresponding Model if requested
        if (withModel) {
          final modelFileName = entry.key.replaceAll(
            StringHelpers.toSnakeCase(entityName),
            '${StringHelpers.toSnakeCase(entityName)}_model',
          );

          final modelContent = _convertEntityToModel(
            entityContent: entityContent,
            entityName: entityName,
            originalModelContent: originalModelContent,
          );

          generatedFiles[modelFileName] = modelContent;
        }
      }

      _logger.detail(
        'Generated ${generatedFiles.length} files for entity $entityName',
      );
      return generatedFiles;
    } catch (e) {
      _logger.err('Failed to generate entity from JSON: $e');
      rethrow;
    }
  }

  /// Generate Entity from scratch (without JSON)
  Future<String> generateFromScratch({
    required String entityName,
    required EntityStyle style,
    required List<EntityField> fields,
    bool equatable = true,
  }) async {
    try {
      _logger.detail('Generating entity $entityName from scratch');

      final className = EntityDetectionService.getEntityClassName(entityName);

      return _generateEntityClass(
        className: className,
        fields: fields,
        style: style,
        equatable: equatable,
      );
    } catch (e) {
      _logger.err('Failed to generate entity from scratch: $e');
      rethrow;
    }
  }

  /// Convert Model style to EntityStyle mapping
  ModelStyle _entityStyleToModelStyle(EntityStyle entityStyle) {
    switch (entityStyle) {
      case EntityStyle.plain:
        return ModelStyle.plain;
      case EntityStyle.immutable:
        return ModelStyle.json; // Use JSON style for better structure
      case EntityStyle.freezed:
        return ModelStyle.freezed;
    }
  }

  /// Convert generated Model content to Entity content
  String _convertModelToEntity({
    required String modelContent,
    required String entityName,
    required EntityStyle style,
  }) {
    final className = EntityDetectionService.getEntityClassName(entityName);

    // Remove JSON serialization parts and make it abstract
    String entityContent = modelContent
        // Replace class name
        .replaceAll(RegExp(r'class\s+\w+Model'), 'abstract class $className')
        .replaceAll(RegExp(r'class\s+\w+'), 'abstract class $className')
        // Remove JSON serialization
        .replaceAll(RegExp(r'@JsonSerializable\(\)'), '')
        .replaceAll(RegExp(r'@JsonKey\([^)]*\)'), '')
        .replaceAll(RegExp(r'factory\s+\w+\.fromJson[^}]+}'), '')
        .replaceAll(RegExp(r'Map<String,\s*dynamic>\s+toJson\(\)[^}]+}'), '')
        // Remove build runner imports
        .replaceAll(
          "import 'package:json_annotation/json_annotation.dart';",
          '',
        )
        .replaceAll(RegExp(r"part\s+'[^']+\.g\.dart';"), '')
        // Add domain-specific imports
        .replaceFirst(
          "import 'package:equatable/equatable.dart';",
          "import 'package:equatable/equatable.dart';\n",
        );

    // Clean up extra newlines
    entityContent = entityContent.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');

    return entityContent;
  }

  /// Generate corresponding Model that extends Entity
  String _convertEntityToModel({
    required String entityContent,
    required String entityName,
    required String originalModelContent,
  }) {
    final entityClassName = EntityDetectionService.getEntityClassName(
      entityName,
    );
    final modelClassName = '${entityName}Model';

    // Extract entity fields for constructor
    final fields = _extractFieldsFromEntity(entityContent);
    final constructorParams = fields
        .map((f) => 'required super.${f.name}')
        .join(', ');

    return '''
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/${StringHelpers.toSnakeCase(entityName)}_entity.dart';

part '${StringHelpers.toSnakeCase(entityName)}_model.g.dart';

@JsonSerializable()
class $modelClassName extends $entityClassName {
  const $modelClassName({
    $constructorParams,
  });

  factory $modelClassName.fromJson(Map<String, dynamic> json) =>
      _\$${modelClassName}FromJson(json);

  Map<String, dynamic> toJson() => _\$${modelClassName}ToJson(this);
}
''';
  }

  /// Generate Entity class from fields
  String _generateEntityClass({
    required String className,
    required List<EntityField> fields,
    required EntityStyle style,
    required bool equatable,
  }) {
    final buffer = StringBuffer();

    // Imports
    if (equatable || style.requiresEquatable) {
      buffer.writeln("import 'package:equatable/equatable.dart';");
    }

    if (style == EntityStyle.freezed) {
      buffer.writeln("import 'package:freezed/freezed.dart';");
      buffer.writeln(
        "part '${StringHelpers.toSnakeCase(className.replaceAll('Entity', ''))}_entity.freezed.dart';",
      );
    }

    buffer.writeln();

    // Class definition
    if (style == EntityStyle.freezed) {
      buffer.writeln('@freezed');
      buffer.writeln('abstract class $className with _\$$className {');
      buffer.writeln('  const factory $className({');

      for (final field in fields) {
        buffer.writeln('    required ${field.type} ${field.name},');
      }

      buffer.writeln('  }) = _$className;');
      buffer.writeln('}');
    } else {
      final extendsClause = (equatable || style.requiresEquatable)
          ? ' extends Equatable'
          : '';
      buffer.writeln('abstract class $className$extendsClause {');

      // Fields
      for (final field in fields) {
        buffer.writeln('  final ${field.type} ${field.name};');
      }
      buffer.writeln();

      // Constructor
      buffer.writeln('  const $className({');
      for (final field in fields) {
        buffer.writeln('    required this.${field.name},');
      }
      buffer.writeln('  });');

      // Equatable props
      if (equatable || style.requiresEquatable) {
        buffer.writeln();
        buffer.writeln('  @override');
        final props = fields.map((f) => f.name).join(', ');
        buffer.writeln('  List<Object?> get props => [$props];');
      }

      buffer.writeln('}');
    }

    return buffer.toString();
  }

  /// Extract fields from entity content
  List<EntityField> _extractFieldsFromEntity(String entityContent) {
    final fields = <EntityField>[];
    final fieldRegex = RegExp(r'final\s+(\w+(?:<[^>]*>)?)\s+(\w+);');

    for (final match in fieldRegex.allMatches(entityContent)) {
      fields.add(EntityField(name: match.group(2)!, type: match.group(1)!));
    }

    return fields;
  }
}

/// Represents an entity field
class EntityField {
  final String name;
  final String type;

  const EntityField({required this.name, required this.type});
}
