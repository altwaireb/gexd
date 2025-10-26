import 'dart:io';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

/// RelationshipDetectorService - Detect and generate relationship models
///
/// This service handles:
/// - Detection of complex nested objects in JSON
/// - Generation of separate model files for relationships
/// - Organization of relationship files in dedicated folders
/// - Smart naming for relationship models
class RelationshipDetectorService {
  final Logger _logger;
  final QuicktypeService _quicktypeService;

  RelationshipDetectorService({
    Logger? logger,
    QuicktypeService? quicktypeService,
  }) : _logger = logger ?? Logger(),
       _quicktypeService = quicktypeService ?? QuicktypeService();

  /// Detect and generate relationship models from JSON data
  Future<List<String>> generateRelationships({
    required String parentModelName,
    required Map<String, dynamic> jsonData,
    required Directory targetDir,
    required ModelStyle style,
    bool folderPerModel = true,
    bool immutable = false,
    bool copyWith = false,
    bool equatable = false,
  }) async {
    final generatedFiles = <String>[];

    try {
      // Extract relationships from JSON
      final relationships = _extractRelationshipData(jsonData, parentModelName);

      if (relationships.isEmpty) {
        _logger.detail('No relationships detected in $parentModelName');
        return generatedFiles;
      }

      _logger.info(
        'Found ${relationships.length} relationships in $parentModelName',
      );

      // Prepare target directory
      final relationshipDir = folderPerModel
          ? await _createRelationshipDirectory(targetDir, parentModelName)
          : targetDir;

      // Generate each relationship model
      for (final relationship in relationships.entries) {
        final relationshipName = relationship.key;
        final relationshipData = relationship.value;

        _logger.detail('Generating relationship model: $relationshipName');

        final modelFiles = await _quicktypeService.generateFromJson(
          modelName: relationshipName,
          jsonContent: _mapToJsonString(relationshipData),
          style: style,
          immutable: immutable,
          copyWith: copyWith,
          equatable: equatable,
          detectRelationships: false, // Prevent infinite recursion
        );

        // Write relationship files
        for (final fileEntry in modelFiles.entries) {
          final fileName = fileEntry.key;
          final fileContent = fileEntry.value;
          final filePath = path.join(relationshipDir.path, fileName);

          await File(filePath).writeAsString(fileContent);
          generatedFiles.add(filePath);

          _logger.detail('Created relationship file: $fileName');
        }
      }

      _logger.info('✅ Generated ${generatedFiles.length} relationship files');
      return generatedFiles;
    } catch (e) {
      _logger.err('Failed to generate relationships: $e');
      rethrow;
    }
  }

  /// Extract relationship data from JSON
  Map<String, Map<String, dynamic>> _extractRelationshipData(
    Map<String, dynamic> jsonData,
    String parentModelName,
  ) {
    final relationships = <String, Map<String, dynamic>>{};

    for (final entry in jsonData.entries) {
      final key = entry.key;
      final value = entry.value;

      // Case 1: Nested object (single relationship)
      if (value is Map<String, dynamic> && _isComplexObject(value)) {
        final relationshipName = _generateRelationshipName(
          key,
          parentModelName,
        );
        relationships[relationshipName] = value;

        _logger.detail(
          'Detected object relationship: $key -> $relationshipName',
        );
      }
      // Case 2: Array of objects (one-to-many relationship)
      else if (value is List &&
          value.isNotEmpty &&
          value.first is Map<String, dynamic> &&
          _isComplexObject(value.first)) {
        final singularName = StringHelpers.toSingular(key);
        final relationshipName = _generateRelationshipName(
          singularName,
          parentModelName,
        );
        relationships[relationshipName] = value.first as Map<String, dynamic>;

        _logger.detail(
          'Detected array relationship: $key -> $relationshipName',
        );
      }
      // Case 3: Nested arrays with objects
      else if (value is List && _hasNestedComplexObjects(value)) {
        final processedObjects = _extractNestedObjects(
          value,
          key,
          parentModelName,
        );
        relationships.addAll(processedObjects);
      }
    }

    return relationships;
  }

  /// Check if an object is complex enough to warrant a separate model
  bool _isComplexObject(Map<String, dynamic> obj) {
    // Simple heuristics to determine if object needs separate model:

    // 1. Has more than 2 fields
    if (obj.length > 2) return true;

    // 2. Contains nested objects or arrays
    for (final value in obj.values) {
      if (value is Map<String, dynamic> ||
          (value is List && value.isNotEmpty)) {
        return true;
      }
    }

    // 3. Contains fields that suggest it's an entity (id, name, etc.)
    final keys = obj.keys.map((k) => k.toLowerCase()).toSet();
    final entityIndicators = {
      'id',
      'uuid',
      'name',
      'title',
      'email',
      'username',
    };
    if (keys.intersection(entityIndicators).isNotEmpty) {
      return true;
    }

    return false;
  }

  /// Check if list contains nested complex objects
  bool _hasNestedComplexObjects(List<dynamic> list) {
    for (final item in list) {
      if (item is Map<String, dynamic> && _isComplexObject(item)) {
        return true;
      }
      if (item is List && _hasNestedComplexObjects(item)) {
        return true;
      }
    }
    return false;
  }

  /// Extract nested objects from complex list structures
  Map<String, Map<String, dynamic>> _extractNestedObjects(
    List<dynamic> list,
    String parentKey,
    String parentModelName,
  ) {
    final relationships = <String, Map<String, dynamic>>{};

    for (int i = 0; i < list.length; i++) {
      final item = list[i];

      if (item is Map<String, dynamic> && _isComplexObject(item)) {
        final relationshipName = _generateRelationshipName(
          '${StringHelpers.toSingular(parentKey)}${i > 0 ? i + 1 : ''}',
          parentModelName,
        );
        relationships[relationshipName] = item;
      }

      if (item is List && _hasNestedComplexObjects(item)) {
        final nestedRelationships = _extractNestedObjects(
          item,
          '${parentKey}Nested',
          parentModelName,
        );
        relationships.addAll(nestedRelationships);
      }
    }

    return relationships;
  }

  /// Generate smart relationship name
  String _generateRelationshipName(String fieldName, String parentModelName) {
    // Convert to PascalCase
    String relationshipName = StringHelpers.toPascalCase(fieldName);

    // Avoid conflicts with parent model name
    if (StringHelpers.isSimilar(relationshipName, parentModelName)) {
      relationshipName = '${relationshipName}Detail';
    }

    // Handle common relationship patterns
    final lowercaseName = relationshipName.toLowerCase();

    // Add context based on naming patterns
    if (lowercaseName.contains('address')) {
      relationshipName = _ensureSuffix(relationshipName, 'Address');
    } else if (lowercaseName.contains('profile')) {
      relationshipName = _ensureSuffix(relationshipName, 'Profile');
    } else if (lowercaseName.contains('setting')) {
      relationshipName = _ensureSuffix(relationshipName, 'Settings');
    } else if (lowercaseName.contains('config')) {
      relationshipName = _ensureSuffix(relationshipName, 'Config');
    }

    return relationshipName;
  }

  /// Ensure string ends with specific suffix
  String _ensureSuffix(String input, String suffix) {
    if (!input.toLowerCase().endsWith(suffix.toLowerCase())) {
      return input + suffix;
    }
    return input;
  }

  /// Create relationship directory
  Future<Directory> _createRelationshipDirectory(
    Directory baseDir,
    String parentModelName,
  ) async {
    final relationshipDirName =
        '${StringHelpers.toSnakeCase(parentModelName)}_relationships';
    final relationshipDir = Directory(
      path.join(baseDir.path, relationshipDirName),
    );

    if (!await relationshipDir.exists()) {
      await relationshipDir.create(recursive: true);
      _logger.detail('Created relationship directory: $relationshipDirName');
    }

    return relationshipDir;
  }

  /// Convert Map to JSON string
  String _mapToJsonString(Map<String, dynamic> data) {
    return '''
{
${data.entries.map((e) => '  "${e.key}": ${_formatJsonValue(e.value)}').join(',\n')}
}''';
  }

  /// Format JSON value for string representation
  String _formatJsonValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"$value"';
    if (value is num || value is bool) return value.toString();
    if (value is Map) {
      final entries = value.entries.map(
        (e) => '"${e.key}": ${_formatJsonValue(e.value)}',
      );
      return '{\n    ${entries.join(',\n    ')}\n  }';
    }
    if (value is List) {
      if (value.isEmpty) return '[]';
      final items = value.map((item) => _formatJsonValue(item));
      return '[\n    ${items.join(',\n    ')}\n  ]';
    }
    return '"$value"';
  }

  /// Get relationship statistics for reporting
  Map<String, dynamic> getRelationshipStats(Map<String, dynamic> jsonData) {
    final relationships = _extractRelationshipData(jsonData, 'temp');

    return {
      'totalRelationships': relationships.length,
      'relationshipNames': relationships.keys.toList(),
      'complexityScore': _calculateComplexityScore(jsonData),
      'maxNestingLevel': _calculateMaxNestingLevel(jsonData),
    };
  }

  /// Calculate complexity score for JSON data
  int _calculateComplexityScore(Map<String, dynamic> data) {
    int score = 0;

    for (final value in data.values) {
      if (value is Map<String, dynamic>) {
        score += 2 + _calculateComplexityScore(value);
      } else if (value is List && value.isNotEmpty) {
        score += 1;
        if (value.first is Map<String, dynamic>) {
          score += _calculateComplexityScore(value.first);
        }
      } else {
        score += 1;
      }
    }

    return score;
  }

  /// Calculate maximum nesting level
  int _calculateMaxNestingLevel(dynamic data, [int currentLevel = 0]) {
    if (data is Map<String, dynamic>) {
      int maxChildLevel = currentLevel;
      for (final value in data.values) {
        final childLevel = _calculateMaxNestingLevel(value, currentLevel + 1);
        maxChildLevel = maxChildLevel > childLevel ? maxChildLevel : childLevel;
      }
      return maxChildLevel;
    } else if (data is List && data.isNotEmpty) {
      return _calculateMaxNestingLevel(data.first, currentLevel);
    }

    return currentLevel;
  }
}
