import 'dart:convert';
import 'dart:io';

import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

/// Job class to handle entity generation
/// Uses Mason templates to generate entity files
/// querying EntityData for necessary information
class EntityJob {
  final EntityData data;
  final Logger logger;
  final EntityGeneratorService entityGeneratorService;
  final EntityDetectionService entityDetectionService;
  final EnvironmentValidatorService environmentService;
  final PostGenerationService postGenerationService;
  final ModelJob? modelJob;

  EntityJob(
    this.data, {
    EntityGeneratorService? entityGeneratorService,
    EntityDetectionService? entityDetectionService,
    EnvironmentValidatorService? environmentService,
    PostGenerationService? postGenerationService,
    this.modelJob,
    Logger? logger,
  }) : logger = logger ?? Logger(),
       entityGeneratorService =
           entityGeneratorService ?? EntityGeneratorService(logger: logger),
       entityDetectionService =
           entityDetectionService ?? EntityDetectionService(),
       environmentService =
           environmentService ?? EnvironmentValidatorService(logger: logger),
       postGenerationService =
           postGenerationService ?? PostGenerationService(logger: logger);

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

    // Validate that entity generation is supported for current template
    final supportedTemplates =
        ComponentRegistry.get(NameComponent.entities)?.supportedTemplates ?? {};
    if (!supportedTemplates.contains(data.template)) {
      throw ValidationException.custom(
        'Entity generation is not supported for ${data.template.displayName} template. '
        'Supported templates: ${supportedTemplates.map((t) => t.displayName).join(", ")}',
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
    final targetDir = await _prepareTargetDirectory();
    for (final entry in generatedFiles.entries) {
      final filePath = path.join(targetDir.path, entry.key);
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

    // Generate model if requested using ModelJob
    if (data.withModel) {
      await _generateModelUsingModelJob(
        ModelInputSourceType.template,
        templateFields: fields,
      );
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

    // Generate entity without model
    final entityFiles = await entityGeneratorService.generateFromJson(
      entityName: data.name,
      jsonContent: jsonContent,
      style: data.style,
      template: data.template,
      withModel: false, // We handle model separately
      equatable: data.equatable,
    );

    // Generate model separately if requested
    if (data.withModel) {
      await _generateModelUsingModelJob(
        ModelInputSourceType.file,
        filePath: data.filePath,
      );
    }

    return entityFiles;
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

    // Generate entity without model
    final entityFiles = await entityGeneratorService.generateFromJson(
      entityName: data.name,
      jsonContent: response.body,
      style: data.style,
      template: data.template,
      withModel: false, // We handle model separately
      equatable: data.equatable,
    );

    // Generate model separately if requested
    if (data.withModel) {
      await _generateModelUsingModelJob(
        ModelInputSourceType.url,
        urlPath: data.urlPath,
      );
    }

    return entityFiles;
  }

  /// Prepare target directory for generated files
  Future<Directory> _prepareTargetDirectory() async {
    final String targetPath = ArchitectureCoordinator.getFullTargetPath(
      projectPath: data.targetDir.path,
      component: data.component,
      template: data.template,
      onPath: data.onPath,
    );

    final targetDir = Directory(targetPath);

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
      logger.detail('Created directory: $targetPath');
    }

    return targetDir;
  }

  /// Generate model using ModelJob for proper placement
  Future<void> _generateModelUsingModelJob(
    ModelInputSourceType inputSourceType, {
    String? filePath,
    String? urlPath,
    List<EntityField>? templateFields,
  }) async {
    // Create ModelData for ModelJob
    final modelData = ModelData(
      name: data.name,
      targetDir: data.targetDir,
      template: data.template,
      component: NameComponent.models,
      inputSourceType: inputSourceType,
      filePath: filePath,
      urlPath: urlPath,
      style: _convertEntityStyleToModelStyle(data.style),
      immutable: true,
      copyWith: false,
      equatable: data.equatable,
      relationshipsInFolder: false,
      onPath: data.onPath,
      force: data.force,
      starterTemplate: _getModelStarterTemplate(templateFields),
      customFields: _convertEntityFieldsToModelFields(templateFields),
    );

    // Create and execute ModelJob if not provided
    final effectiveModelJob = modelJob ?? ModelJob(modelData, logger: logger);

    // Execute ModelJob to generate model in proper location
    await effectiveModelJob.execute();
  }

  /// Convert EntityStyle to ModelStyle
  ModelStyle _convertEntityStyleToModelStyle(EntityStyle entityStyle) {
    switch (entityStyle) {
      case EntityStyle.plain:
        return ModelStyle.plain;
      case EntityStyle.immutable:
        return ModelStyle.json;
      case EntityStyle.freezed:
        return ModelStyle.freezed;
    }
  }

  /// Get appropriate ModelStarterTemplate based on fields
  ModelStarterTemplate _getModelStarterTemplate(List<EntityField>? fields) {
    if (fields != null && fields.isNotEmpty) {
      return ModelStarterTemplate.custom;
    }
    return ModelStarterTemplate.basic; // Default template
  }

  /// Convert EntityField to CustomField
  List<CustomField> _convertEntityFieldsToModelFields(
    List<EntityField>? entityFields,
  ) {
    if (entityFields == null) return [];

    return entityFields.map((field) {
      // Try to map entity field type to FieldType
      final fieldType = _mapEntityTypeToFieldType(field.type);

      return CustomField.fromInput(name: field.name, type: fieldType);
    }).toList();
  }

  /// Map Entity field type to ModelField FieldType
  FieldType _mapEntityTypeToFieldType(String entityType) {
    switch (entityType.toLowerCase()) {
      case 'string':
        return FieldType.string;
      case 'int':
      case 'integer':
        return FieldType.integer;
      case 'double':
        return FieldType.double;
      case 'bool':
      case 'boolean':
        return FieldType.boolean;
      case 'datetime':
        return FieldType.dateTime;
      default:
        return FieldType.string; // Default to string
    }
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
    // Dependencies are handled by PostGenerationService or manual installation
    logger.detail('Model dependencies handled by project template');
  }

  /// Add Equatable dependency
  Future<void> _addEquatableDependency() async {
    // Dependencies are handled by PostGenerationService or manual installation
    logger.detail(
      'Equatable dependency should be added manually if not present',
    );
  }

  /// Format generated files
  Future<void> _formatFiles(Map<String, String> files) async {
    if (files.isEmpty) return;

    // Get the actual target directory path where files were generated
    final String targetPath = ArchitectureCoordinator.getFullTargetPath(
      projectPath: data.targetDir.path,
      component: data.component,
      template: data.template,
      onPath: data.onPath,
    );

    // Convert file names to full paths
    final filePaths = files.keys.map((fileName) {
      return path.join(targetPath, fileName);
    }).toList();

    await postGenerationService.formatSpecificFiles(
      filePaths,
      data.targetDir.path,
    );
  }

  /// Log generation summary
  void _logSummary(Map<String, String> generatedFiles) {
    // Get the relative path from project root
    final String targetPath = ArchitectureCoordinator.getFullTargetPath(
      projectPath: data.targetDir.path,
      component: data.component,
      template: data.template,
      onPath: data.onPath,
    );

    // Calculate relative path from project root
    final String relativePath = path.relative(
      targetPath,
      from: data.targetDir.path,
    );

    logger.info('');
    logger.info('🎉 Entity generation completed successfully!');
    logger.info('');
    logger.info('Generated files:');

    for (final fileName in generatedFiles.keys) {
      final fullPath = path.join(relativePath, fileName);
      logger.info('  ✅ $fullPath');
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

    if (data.template == ProjectTemplate.clean) {
      logger.info('  • Create repository interfaces and implementations');
      logger.info('  • Add use cases for your domain logic');
      logger.info(
        '  • Consider using "gexd make repository" and "gexd make usecase"',
      );
    } else if (data.template == ProjectTemplate.getx) {
      logger.info('  • Create data providers and repositories');
      logger.info('  • Add controllers to manage entity state');
      logger.info('  • Consider using GetX state management features');
    }
  }
}
