import 'dart:convert';
import 'dart:io';

import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class EntityJob {
  final EntityData data;
  final Logger logger;
  final EntityGeneratorService entityGeneratorService;
  final EntityDetectionService entityDetectionService;
  final EnvironmentValidatorService environmentService;

  EntityJob(
    this.data, {
    EntityGeneratorService? entityGeneratorService,
    EntityDetectionService? entityDetectionService,
    EnvironmentValidatorService? environmentService,
    Logger? logger,
  }) : logger = logger ?? Logger(),
       entityGeneratorService =
           entityGeneratorService ?? EntityGeneratorService(logger: logger),
       entityDetectionService =
           entityDetectionService ?? EntityDetectionService(),
       environmentService =
           environmentService ?? EnvironmentValidatorService(logger: logger);

  Future<int> execute() async {
    try {
      // Validate environment first
      await _validateEnvironment();

      // Generate entity files
      final generatedFiles = await _generateEntities();

      // Auto-fix environment if needed
      await _postGeneration();

      // Format generated files
      await _formatFiles(generatedFiles);

      _logSummary(generatedFiles);

      return ExitCode.success.code;
    } catch (e) {
      logger.err('Entity generation failed: $e');
      return ExitCode.software.code;
    }
  }

  /// Validate environment before generation
  Future<void> _validateEnvironment() async {
    logger.detail('Validating environment...');

    // Validate Clean Architecture template
    if (data.template != ProjectTemplate.clean) {
      throw ValidationException.custom(
        'Entity generation requires Clean Architecture template. '
        'Current project uses ${data.template.displayName}.',
      );
    }

    await environmentService.validateEnvironmentForStyle(ModelStyle.plain);
    logger.detail('Environment validation completed.');
  }

  /// Generate entity files using EntityGeneratorService
  Future<Map<String, String>> _generateEntities() async {
    logger.detail('Generating entity files...');

    Map<String, String> generatedFiles = {};

    switch (data.inputSourceType) {
      case EntityInputSourceType.template:
        generatedFiles = await _generateFromTemplate();
        break;
      case EntityInputSourceType.file:
        generatedFiles = await _generateFromFile();
        break;
      case EntityInputSourceType.url:
        generatedFiles = await _generateFromUrl();
        break;
    }

    // Write files to disk
    final targetPath = _getTargetPath();
    for (final entry in generatedFiles.entries) {
      final filePath = path.join(targetPath, entry.key);
      final file = File(filePath);

      // Check if file exists and handle overwrite
      if (file.existsSync() && !data.force) {
        throw ValidationException.custom(
          'File ${entry.key} already exists. Use --force to overwrite.',
        );
      }

      // Create directory if needed
      await file.parent.create(recursive: true);

      // Write file
      await file.writeAsString(entry.value);
      logger.detail('Generated: ${entry.key}');
    }

    return generatedFiles;
  }

  /// Generate entity from basic template
  Future<Map<String, String>> _generateFromTemplate() async {
    logger.detail('Generating entity from template...');

    // Create basic fields for template entity
    final fields = <EntityField>[
      EntityField(name: 'id', type: 'String'),
      EntityField(name: 'createdAt', type: 'DateTime'),
    ];

    final entityContent = await entityGeneratorService.generateFromScratch(
      entityName: data.name,
      style: data.style,
      fields: fields,
      equatable: data.equatable,
    );

    final entityFileName = EntityDetectionService.getEntityFileName(data.name);
    final files = <String, String>{entityFileName: entityContent};

    // Generate model if requested
    if (data.withModel) {
      // For template mode, create a basic model that extends the entity
      final modelContent = _generateModelFromEntity(entityContent);
      final modelFileName = _getModelFileName(data.name);
      files[modelFileName] = modelContent;
    }

    return files;
  }

  /// Generate entity from JSON file
  Future<Map<String, String>> _generateFromFile() async {
    if (data.filePath == null) {
      throw ValidationException.custom('File path is required');
    }

    logger.detail('Reading JSON file: ${data.filePath}');
    final file = File(data.filePath!);
    final jsonContent = await file.readAsString();

    return await entityGeneratorService.generateFromJson(
      entityName: data.name,
      jsonContent: jsonContent,
      style: data.style,
      withModel: data.withModel,
      equatable: data.equatable,
    );
  }

  /// Generate entity from URL
  Future<Map<String, String>> _generateFromUrl() async {
    if (data.urlPath == null) {
      throw ValidationException.custom('URL path is required');
    }

    logger.detail('Fetching JSON from URL: ${data.urlPath}');
    final response = await http.get(Uri.parse(data.urlPath!));

    if (response.statusCode != 200) {
      throw ValidationException.custom(
        'Failed to fetch data from URL: ${response.statusCode}',
      );
    }

    // Validate JSON
    try {
      json.decode(response.body);
    } catch (e) {
      throw ValidationException.custom('Invalid JSON response from URL: $e');
    }

    return await entityGeneratorService.generateFromJson(
      entityName: data.name,
      jsonContent: response.body,
      style: data.style,
      withModel: data.withModel,
      equatable: data.equatable,
    );
  }

  /// Generate model that extends entity
  String _generateModelFromEntity(String entityContent) {
    final entityClassName = EntityDetectionService.getEntityClassName(
      data.name,
    );
    final modelClassName = '${data.name}Model';

    // Extract fields from entity for constructor
    final fields = _extractFieldsFromEntity(entityContent);
    final constructorParams = fields
        .map((f) => 'required super.${f.name}')
        .join(', ');

    return '''
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/${StringHelpers.toSnakeCase(data.name)}_entity.dart';

part '${StringHelpers.toSnakeCase(data.name)}_model.g.dart';

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

  /// Extract fields from entity content
  List<EntityField> _extractFieldsFromEntity(String entityContent) {
    final fields = <EntityField>[];
    final fieldRegex = RegExp(r'final\s+(\w+(?:<[^>]*>)?)\s+(\w+);');

    for (final match in fieldRegex.allMatches(entityContent)) {
      fields.add(EntityField(name: match.group(2)!, type: match.group(1)!));
    }

    return fields;
  }

  /// Get target path for generated files
  String _getTargetPath() {
    final basePath = data.targetDir.path;

    if (data.onPath != null && data.onPath!.isNotEmpty) {
      return path.join(basePath, 'lib', data.onPath);
    }

    // Default path for Clean Architecture
    return path.join(basePath, 'lib', 'features');
  }

  /// Get model file name
  String _getModelFileName(String entityName) {
    return '${StringHelpers.toSnakeCase(entityName)}_model.dart';
  }

  /// Run post-generation tasks
  Future<void> _postGeneration() async {
    logger.detail('Running post-generation tasks...');

    // Add dependencies if needed
    if (data.withModel) {
      await _addModelDependencies();
    }

    if (data.equatable) {
      await _addEquatableDependency();
    }

    logger.detail('Post-generation completed.');
  }

  /// Add model-related dependencies
  Future<void> _addModelDependencies() async {
    logger.detail('Adding model dependencies...');
    // The dependencies will be handled by the project template or manual installation
    // as the DependencyService has private methods
  }

  /// Add Equatable dependency
  Future<void> _addEquatableDependency() async {
    logger.detail(
      'Equatable dependency should be added manually if not present...',
    );
    // The dependencies will be handled by the project template or manual installation
  }

  /// Format generated files
  Future<void> _formatFiles(Map<String, String> files) async {
    if (files.isEmpty) return;

    logger.detail('Formatting generated files...');

    try {
      await Process.run('dart', [
        'format',
        data.targetDir.path,
      ], workingDirectory: data.targetDir.path);
      logger.detail('Files formatted successfully.');
    } catch (e) {
      logger.warn('Failed to format files: $e');
    }
  }

  /// Log generation summary
  void _logSummary(Map<String, String> generatedFiles) {
    logger.info('');
    logger.info('🎉 Entity generation completed successfully!');
    logger.info('');
    logger.info('Generated files:');

    for (final fileName in generatedFiles.keys) {
      logger.info('  ✅ $fileName');
    }

    logger.info('');

    if (data.withModel) {
      logger.info(
        '💡 Don\'t forget to run "dart pub get && dart pub run build_runner build"',
      );
      logger.info('   to generate JSON serialization code for models.');
    }

    logger.info('');
    logger.info('Next steps:');
    logger.info('  • Add business logic to your entity');
    logger.info('  • Create repository interfaces and implementations');
    logger.info('  • Add use cases for your domain logic');

    if (data.template == ProjectTemplate.clean) {
      logger.info(
        '  • Consider using "gexd make repository" and "gexd make usecase"',
      );
    }
  }
}
