import 'dart:io';
import 'package:gexd/gexd.dart';

/// Service responsible for detecting entities within the project structure.
class EntityDetectionService {
  /// Check if an entity exists within the project by its name.
  ///
  /// This will:
  /// - Convert the entity name to `snake_case`
  /// - Append `_entity.dart`
  /// - Search in the domain/entities directory based on the project template.
  static Future<bool> exists({
    required String entityName,
    required ProjectTemplate template,
    required Directory basePath,
    List<String> suffixes = const ['Entity'],
  }) async {
    final result = await EntityDetectionService.getEntityPath(
      entityName: entityName,
      template: template,
      basePath: basePath,
      suffixes: suffixes,
    );

    return result != null && result.isNotEmpty;
  }

  /// Get the absolute path for the entity (if it exists), otherwise null.
  static Future<String?> getEntityPath({
    required String entityName,
    required ProjectTemplate template,
    required Directory basePath,
    List<String> suffixes = const ['Entity'],
  }) async {
    // Only clean architecture has entities
    if (template != ProjectTemplate.clean) return null;

    final entitiesPath = ArchitectureCoordinator.getComponentPath(
      NameComponent.entities,
      template,
    );

    if (entitiesPath.isEmpty) return null;

    final dir = Directory('${basePath.path}/$entitiesPath');
    if (!await dir.exists()) return null;

    // 🧠 تحديد baseName (اسم بدون أي suffix)
    String baseName = entityName;
    for (final suffix in suffixes) {
      if (entityName.endsWith(suffix)) {
        baseName = entityName.substring(0, entityName.length - suffix.length);
        break;
      }
    }

    final snakeCaseBaseName = StringHelpers.toSnakeCase(baseName);

    // Try different variations
    final possibleFileNames = [
      '${snakeCaseBaseName}_entity.dart',
      '$snakeCaseBaseName.dart',
    ];

    for (final fileName in possibleFileNames) {
      final file = File('${dir.path}/$fileName');
      if (await file.exists()) {
        return file.path;
      }
    }

    return null;
  }

  /// Get all entity files in the project
  static Future<List<String>> getAllEntities({
    required ProjectTemplate template,
    required Directory basePath,
  }) async {
    if (template != ProjectTemplate.clean) return [];

    final entitiesPath = ArchitectureCoordinator.getComponentPath(
      NameComponent.entities,
      template,
    );

    if (entitiesPath.isEmpty) return [];

    final dir = Directory('${basePath.path}/$entitiesPath');
    if (!await dir.exists()) return [];

    final entities = <String>[];

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final entityName = entity.path
            .split('/')
            .last
            .replaceAll('.dart', '')
            .replaceAll('_entity', '');
        entities.add(StringHelpers.toPascalCase(entityName));
      }
    }

    return entities;
  }

  /// Check if a model exists for this entity
  static Future<bool> hasCorrespondingModel({
    required String entityName,
    required ProjectTemplate template,
    required Directory basePath,
  }) async {
    return await ModelDetectionService.exists(
      modelName: entityName,
      template: template,
      basePath: basePath,
    );
  }

  /// Get entity class name with proper suffix
  static String getEntityClassName(String entityName) {
    if (entityName.endsWith('Entity')) return entityName;
    return '${entityName}Entity';
  }

  /// Get entity file name
  static String getEntityFileName(String entityName) {
    final baseName = entityName.endsWith('Entity')
        ? entityName.substring(0, entityName.length - 'Entity'.length)
        : entityName;
    return '${StringHelpers.toSnakeCase(baseName)}_entity.dart';
  }

  /// Get entity data with complete information for code generation
  static Future<EntityDetectionData> getEntityData({
    required String entityName,
    required ProjectTemplate template,
    required Directory basePath,
    List<String> suffixes = const ['Entity'],
  }) async {
    final className = getEntityClassName(entityName);
    final fileName = getEntityFileName(entityName);
    final filePath = await getEntityPath(
      entityName: entityName,
      template: template,
      basePath: basePath,
      suffixes: suffixes,
    );
    final importPath = _getEntityImportPath(
      entityName: entityName,
      template: template,
    );
    final exists = await EntityDetectionService.exists(
      entityName: entityName,
      template: template,
      basePath: basePath,
      suffixes: suffixes,
    );

    return EntityDetectionData(
      className: className,
      fileName: fileName,
      filePath: filePath ?? '',
      importPath: importPath,
      exists: exists,
    );
  }

  /// Get entity import path for Dart imports
  static String _getEntityImportPath({
    required String entityName,
    required ProjectTemplate template,
  }) {
    if (template != ProjectTemplate.clean) return '';

    final baseName = entityName.endsWith('Entity')
        ? entityName.substring(0, entityName.length - 'Entity'.length)
        : entityName;

    return 'package:{{packageName}}/domain/entities/${StringHelpers.toSnakeCase(baseName)}_entity.dart';
  }
}

/// Data class containing entity detection information
class EntityDetectionData {
  // PascalCase
  final String className;
  // file name with extension
  final String fileName;
  // full file path
  final String filePath;
  // import path to be used in Dart files
  final String importPath;
  // whether the entity file actually exists
  final bool exists;

  EntityDetectionData({
    required this.className,
    required this.fileName,
    required this.filePath,
    required this.importPath,
    required this.exists,
  });
}
