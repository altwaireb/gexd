import 'dart:convert';
import 'dart:io';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:http/http.dart' as http;

/// QuicktypeService - Generate Dart models from JSON using Quicktype
///
/// This service handles:
/// - JSON to Dart model conversion
/// - Support for different model styles (plain, json_serializable, freezed)
/// - Relationship detection and extraction
/// - Complex nested object handling
class QuicktypeService {
  final Logger _logger;

  QuicktypeService({Logger? logger}) : _logger = logger ?? Logger();

  /// Generate Dart model from JSON content
  ///
  /// Returns a map of fileName -> fileContent for all generated files
  Future<Map<String, String>> generateFromJson({
    required String modelName,
    required String jsonContent,
    required ModelStyle style,
    bool immutable = false,
    bool copyWith = false,
    bool equatable = false,
    bool detectRelationships = true,
  }) async {
    try {
      // Parse JSON to validate and extract structure
      final jsonData = _parseJsonSafely(jsonContent);
      if (jsonData == null) {
        throw ValidationException.custom('Invalid JSON format');
      }

      // Generate primary model
      final primaryModel = await _generatePrimaryModel(
        modelName: modelName,
        jsonData: jsonData,
        style: style,
        immutable: immutable,
        copyWith: copyWith,
        equatable: equatable,
      );

      final generatedFiles = <String, String>{
        '${StringHelpers.toSnakeCase(modelName)}.dart': primaryModel,
      };

      // Extract and generate relationship models if enabled
      if (detectRelationships) {
        final relationships = _extractRelationships(jsonData, modelName);
        for (final relationship in relationships.entries) {
          final relationshipModel = await _generateRelationshipModel(
            modelName: relationship.key,
            jsonData: relationship.value,
            style: style,
            immutable: immutable,
            copyWith: copyWith,
            equatable: equatable,
          );

          final fileName =
              '${StringHelpers.toSnakeCase(relationship.key)}.dart';
          generatedFiles[fileName] = relationshipModel;
        }
      }

      return generatedFiles;
    } catch (e) {
      _logger.err('Failed to generate model: $e');
      rethrow;
    }
  }

  /// Generate Dart model from JSON URL
  Future<Map<String, String>> generateFromUrl({
    required String modelName,
    required String url,
    required ModelStyle style,
    bool immutable = false,
    bool copyWith = false,
    bool equatable = false,
    bool detectRelationships = true,
  }) async {
    final progress = _logger.progress('Fetching JSON from URL...');

    try {
      progress.update('Downloading data from: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        progress.fail('Failed to fetch JSON from URL');
        throw ValidationException.custom(
          'Failed to fetch JSON from URL. Status: ${response.statusCode}',
        );
      }

      progress.complete('✅ JSON data downloaded successfully');

      return generateFromJson(
        modelName: modelName,
        jsonContent: response.body,
        style: style,
        immutable: immutable,
        copyWith: copyWith,
        equatable: equatable,
        detectRelationships: detectRelationships,
      );
    } catch (e) {
      _logger.err('Failed to generate model from URL: $e');
      rethrow;
    }
  }

  /// Generate Dart model from local file
  Future<Map<String, String>> generateFromFile({
    required String modelName,
    required String filePath,
    required ModelStyle style,
    bool immutable = false,
    bool copyWith = false,
    bool equatable = false,
    bool detectRelationships = true,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw ValidationException.custom('File does not exist: $filePath');
      }

      final jsonContent = await file.readAsString();

      return generateFromJson(
        modelName: modelName,
        jsonContent: jsonContent,
        style: style,
        immutable: immutable,
        copyWith: copyWith,
        equatable: equatable,
        detectRelationships: detectRelationships,
      );
    } catch (e) {
      _logger.err('Failed to generate model from file: $e');
      rethrow;
    }
  }

  /// Parse JSON safely and return data or null if invalid
  Map<String, dynamic>? _parseJsonSafely(String jsonContent) {
    try {
      final decoded = json.decode(jsonContent);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Generate primary model based on style
  Future<String> _generatePrimaryModel({
    required String modelName,
    required Map<String, dynamic> jsonData,
    required ModelStyle style,
    bool immutable = false,
    bool copyWith = false,
    bool equatable = false,
  }) async {
    switch (style) {
      case ModelStyle.plain:
        return _generatePlainModel(
          modelName: modelName,
          jsonData: jsonData,
          immutable: immutable,
          copyWith: copyWith,
          equatable: equatable,
        );
      case ModelStyle.json:
        return _generateJsonModel(
          modelName: modelName,
          jsonData: jsonData,
          immutable: immutable,
          copyWith: copyWith,
          equatable: equatable,
        );
      case ModelStyle.freezed:
        return _generateFreezedModel(
          modelName: modelName,
          jsonData: jsonData,
          copyWith: copyWith,
          equatable: equatable,
        );
    }
  }

  /// Generate relationship model
  Future<String> _generateRelationshipModel({
    required String modelName,
    required Map<String, dynamic> jsonData,
    required ModelStyle style,
    bool immutable = false,
    bool copyWith = false,
    bool equatable = false,
  }) async {
    return _generatePrimaryModel(
      modelName: modelName,
      jsonData: jsonData,
      style: style,
      immutable: immutable,
      copyWith: copyWith,
      equatable: equatable,
    );
  }

  /// Generate plain Dart model
  String _generatePlainModel({
    required String modelName,
    required Map<String, dynamic> jsonData,
    bool immutable = false,
    bool copyWith = false,
    bool equatable = false,
  }) {
    final buffer = StringBuffer();

    // Add imports
    if (equatable) {
      buffer.writeln("import 'package:equatable/equatable.dart';");
      buffer.writeln();
    }

    // Add class declaration
    final classDeclaration = equatable
        ? 'class $modelName extends Equatable {'
        : 'class $modelName {';
    buffer.writeln(classDeclaration);

    // Add fields
    final fields = _generateFields(jsonData, immutable);
    buffer.writeln(fields);

    // Add constructor
    final constructor = _generateConstructor(modelName, jsonData, immutable);
    buffer.writeln(constructor);

    // Add fromJson method
    final fromJson = _generateFromJsonMethod(modelName, jsonData);
    buffer.writeln(fromJson);

    // Add toJson method
    final toJson = _generateToJsonMethod(jsonData);
    buffer.writeln(toJson);

    // Add copyWith method if requested
    if (copyWith) {
      final copyWithMethod = _generateCopyWithMethod(modelName, jsonData);
      buffer.writeln(copyWithMethod);
    }

    // Add Equatable props if requested
    if (equatable) {
      final props = _generateEquatableProps(jsonData);
      buffer.writeln(props);
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  /// Generate JSON serializable model
  String _generateJsonModel({
    required String modelName,
    required Map<String, dynamic> jsonData,
    bool immutable = false,
    bool copyWith = false,
    bool equatable = false,
  }) {
    final buffer = StringBuffer();

    // Add imports
    buffer.writeln("import 'package:json_annotation/json_annotation.dart';");
    if (equatable) {
      buffer.writeln("import 'package:equatable/equatable.dart';");
    }
    buffer.writeln();
    buffer.writeln("part '${StringHelpers.toSnakeCase(modelName)}.g.dart';");
    buffer.writeln();

    // Add JsonSerializable annotation
    buffer.writeln('@JsonSerializable()');

    // Add class declaration
    final classDeclaration = equatable
        ? 'class $modelName extends Equatable {'
        : 'class $modelName {';
    buffer.writeln(classDeclaration);

    // Add fields with JsonKey annotations
    final fields = _generateFieldsWithJsonKey(jsonData, immutable);
    buffer.writeln(fields);

    // Add constructor
    final constructor = _generateConstructor(modelName, jsonData, immutable);
    buffer.writeln(constructor);

    // Add fromJson method
    buffer.writeln(
      '  factory $modelName.fromJson(Map<String, dynamic> json) => _\$${modelName}FromJson(json);',
    );
    buffer.writeln();

    // Add toJson method
    buffer.writeln(
      '  Map<String, dynamic> toJson() => _\$${modelName}ToJson(this);',
    );
    buffer.writeln();

    // Add copyWith method if requested
    if (copyWith) {
      final copyWithMethod = _generateCopyWithMethod(modelName, jsonData);
      buffer.writeln(copyWithMethod);
    }

    // Add Equatable props if requested
    if (equatable) {
      final props = _generateEquatableProps(jsonData);
      buffer.writeln(props);
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  /// Generate Freezed model
  String _generateFreezedModel({
    required String modelName,
    required Map<String, dynamic> jsonData,
    bool copyWith = false,
    bool equatable = false,
  }) {
    final buffer = StringBuffer();

    // Add imports
    buffer.writeln(
      "import 'package:freezed_annotation/freezed_annotation.dart';",
    );
    buffer.writeln("import 'package:json_annotation/json_annotation.dart';");
    buffer.writeln();
    buffer.writeln(
      "part '${StringHelpers.toSnakeCase(modelName)}.freezed.dart';",
    );
    buffer.writeln("part '${StringHelpers.toSnakeCase(modelName)}.g.dart';");
    buffer.writeln();

    // Add Freezed annotation
    buffer.writeln('@freezed');
    buffer.writeln('class $modelName with _\$$modelName {');

    // Add factory constructor
    final factoryConstructor = _generateFreezedFactoryConstructor(
      modelName,
      jsonData,
    );
    buffer.writeln(factoryConstructor);

    // Add fromJson method
    buffer.writeln(
      '  factory $modelName.fromJson(Map<String, dynamic> json) => _\$${modelName}FromJson(json);',
    );

    buffer.writeln('}');

    return buffer.toString();
  }

  /// Extract relationships from JSON data
  Map<String, Map<String, dynamic>> _extractRelationships(
    Map<String, dynamic> jsonData,
    String parentModelName,
  ) {
    final relationships = <String, Map<String, dynamic>>{};

    for (final entry in jsonData.entries) {
      final key = entry.key;
      final value = entry.value;

      // Check for nested objects
      if (value is Map<String, dynamic>) {
        final relationshipName = StringHelpers.toPascalCase(
          StringHelpers.isSimilar(key, parentModelName) ? '${key}Detail' : key,
        );
        relationships[relationshipName] = value;
      }
      // Check for arrays of objects
      else if (value is List &&
          value.isNotEmpty &&
          value.first is Map<String, dynamic>) {
        final singularName = StringHelpers.toSingular(key);
        final relationshipName = StringHelpers.toPascalCase(singularName);
        relationships[relationshipName] = value.first as Map<String, dynamic>;
      }
    }

    return relationships;
  }

  /// Generate fields for the model
  String _generateFields(Map<String, dynamic> jsonData, bool immutable) {
    final buffer = StringBuffer();

    for (final entry in jsonData.entries) {
      final fieldName = StringHelpers.toCamelCase(entry.key);
      final dartType = _getDartType(entry.value);
      final modifier = immutable ? 'final ' : '';

      buffer.writeln('  $modifier$dartType $fieldName;');
    }

    return buffer.toString();
  }

  /// Generate fields with JsonKey annotations
  String _generateFieldsWithJsonKey(
    Map<String, dynamic> jsonData,
    bool immutable,
  ) {
    final buffer = StringBuffer();

    for (final entry in jsonData.entries) {
      final originalKey = entry.key;
      final fieldName = StringHelpers.toCamelCase(originalKey);
      final dartType = _getDartType(entry.value);
      final modifier = immutable ? 'final ' : '';

      if (fieldName != originalKey) {
        buffer.writeln('  @JsonKey(name: \'$originalKey\')');
      }
      buffer.writeln('  $modifier$dartType $fieldName;');
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Generate constructor
  String _generateConstructor(
    String modelName,
    Map<String, dynamic> jsonData,
    bool immutable,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('  $modelName({');

    for (final entry in jsonData.entries) {
      final fieldName = StringHelpers.toCamelCase(entry.key);
      final isRequired = !_isNullableType(entry.value);
      final requiredKeyword = isRequired ? 'required ' : '';

      buffer.writeln('    ${requiredKeyword}this.$fieldName,');
    }

    buffer.writeln('  });');
    buffer.writeln();

    return buffer.toString();
  }

  /// Generate fromJson method for plain models
  String _generateFromJsonMethod(
    String modelName,
    Map<String, dynamic> jsonData,
  ) {
    final buffer = StringBuffer();
    buffer.writeln(
      '  factory $modelName.fromJson(Map<String, dynamic> json) {',
    );
    buffer.writeln('    return $modelName(');

    for (final entry in jsonData.entries) {
      final originalKey = entry.key;
      final fieldName = StringHelpers.toCamelCase(originalKey);
      final conversion = _getFromJsonConversion(originalKey, entry.value);

      buffer.writeln('      $fieldName: $conversion,');
    }

    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln();

    return buffer.toString();
  }

  /// Generate toJson method
  String _generateToJsonMethod(Map<String, dynamic> jsonData) {
    final buffer = StringBuffer();
    buffer.writeln('  Map<String, dynamic> toJson() {');
    buffer.writeln('    return {');

    for (final entry in jsonData.entries) {
      final originalKey = entry.key;
      final fieldName = StringHelpers.toCamelCase(originalKey);

      buffer.writeln('      \'$originalKey\': $fieldName,');
    }

    buffer.writeln('    };');
    buffer.writeln('  }');
    buffer.writeln();

    return buffer.toString();
  }

  /// Generate copyWith method
  String _generateCopyWithMethod(
    String modelName,
    Map<String, dynamic> jsonData,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('  $modelName copyWith({');

    for (final entry in jsonData.entries) {
      final fieldName = StringHelpers.toCamelCase(entry.key);
      final dartType = _getDartType(entry.value);

      buffer.writeln('    $dartType? $fieldName,');
    }

    buffer.writeln('  }) {');
    buffer.writeln('    return $modelName(');

    for (final entry in jsonData.entries) {
      final fieldName = StringHelpers.toCamelCase(entry.key);

      buffer.writeln('      $fieldName: $fieldName ?? this.$fieldName,');
    }

    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln();

    return buffer.toString();
  }

  /// Generate Equatable props
  String _generateEquatableProps(Map<String, dynamic> jsonData) {
    final buffer = StringBuffer();
    buffer.writeln('  @override');
    buffer.writeln('  List<Object?> get props => [');

    for (final entry in jsonData.entries) {
      final fieldName = StringHelpers.toCamelCase(entry.key);
      buffer.writeln('        $fieldName,');
    }

    buffer.writeln('      ];');
    buffer.writeln();

    return buffer.toString();
  }

  /// Generate Freezed factory constructor
  String _generateFreezedFactoryConstructor(
    String modelName,
    Map<String, dynamic> jsonData,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('  const factory $modelName({');

    for (final entry in jsonData.entries) {
      final originalKey = entry.key;
      final fieldName = StringHelpers.toCamelCase(originalKey);
      final dartType = _getDartType(entry.value);
      final isRequired = !_isNullableType(entry.value);
      final requiredKeyword = isRequired ? 'required ' : '';

      if (fieldName != originalKey) {
        buffer.writeln(
          '    @JsonKey(name: \'$originalKey\') $requiredKeyword$dartType $fieldName,',
        );
      } else {
        buffer.writeln('    $requiredKeyword$dartType $fieldName,');
      }
    }

    buffer.writeln('  }) = _$modelName;');
    buffer.writeln();

    return buffer.toString();
  }

  /// Get Dart type from JSON value
  String _getDartType(dynamic value) {
    if (value == null) return 'String?';

    if (value is int) return 'int';
    if (value is double) return 'double';
    if (value is bool) return 'bool';
    if (value is String) return 'String';
    if (value is List) {
      if (value.isEmpty) return 'List<dynamic>';
      final firstItem = value.first;
      if (firstItem is Map<String, dynamic>) {
        return 'List<Map<String, dynamic>>';
      }
      return 'List<${_getDartType(firstItem)}>';
    }
    if (value is Map) return 'Map<String, dynamic>';
    return 'dynamic';
  }

  /// Get fromJson conversion for field
  String _getFromJsonConversion(String jsonKey, dynamic value) {
    if (value == null) return 'json[\'$jsonKey\']';

    if (value is int) return 'json[\'$jsonKey\'] as int';
    if (value is double) return 'json[\'$jsonKey\'] as double';
    if (value is bool) return 'json[\'$jsonKey\'] as bool';
    if (value is String) return 'json[\'$jsonKey\'] as String';
    if (value is List) return 'json[\'$jsonKey\'] as List<dynamic>';
    if (value is Map) return 'json[\'$jsonKey\'] as Map<String, dynamic>';
    return 'json[\'$jsonKey\']';
  }

  /// Check if type should be nullable
  bool _isNullableType(dynamic value) {
    return value == null;
  }
}
