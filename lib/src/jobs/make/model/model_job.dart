import 'dart:convert';
import 'dart:io';

import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

/// Job class to handle model generation
/// Uses Quicktype to generate model files
/// querying ModelData for necessary information
class ModelJob {
  final ModelData data;
  final Logger logger;
  final QuicktypeService quicktypeService;
  final RelationshipDetectorService relationshipService;
  final EnvironmentValidatorService environmentService;

  ModelJob(
    this.data, {
    QuicktypeService? quicktypeService,
    RelationshipDetectorService? relationshipService,
    EnvironmentValidatorService? environmentService,
    Logger? logger,
  }) : logger = logger ?? Logger(),
       quicktypeService = quicktypeService ?? QuicktypeService(logger: logger),
       relationshipService =
           relationshipService ?? RelationshipDetectorService(logger: logger),
       environmentService =
           environmentService ?? EnvironmentValidatorService(logger: logger);

  Future<int> execute() async {
    try {
      // Validate environment first
      await _validateEnvironment();

      // Generate files using Quicktype
      final generatedFiles = await _generateModels();

      // Generate relationships if enabled
      final relationshipFiles = await _generateRelationships(generatedFiles);
      generatedFiles.addAll(relationshipFiles);

      // Auto-fix environment and run build_runner if needed
      await _postGeneration();

      // Format generated files
      await _formatFiles(generatedFiles);

      _logSummary(generatedFiles);

      return ExitCode.success.code;
    } catch (e) {
      logger.err('Model generation failed: $e');
      rethrow;
    }
  }

  /// Validate environment and install dependencies if needed
  Future<void> _validateEnvironment() async {
    logger.detail('Validating environment for ${data.style.displayName}...');

    final validation = await environmentService.validateEnvironmentForStyle(
      data.style,
    );

    if (validation.hasWarnings) {
      for (final warning in validation.warnings) {
        logger.warn(warning);
      }
    }

    if (!validation.isValid) {
      for (final issue in validation.issues) {
        logger.err(issue);
      }
      throw ValidationException.custom('Environment validation failed');
    }

    // Auto-fix environment if there are warnings
    if (validation.hasWarnings) {
      final shouldAutoFix = await _promptAutoFix();
      if (shouldAutoFix) {
        await environmentService.autoFixEnvironment(data.style);
      }
    }
  }

  /// Generate main models using Quicktype
  Future<List<String>> _generateModels() async {
    final progress = logger.progress('Generating ${data.name} model...');

    try {
      final targetDir = await _prepareTargetDirectory();

      Map<String, String> modelFiles;

      // Use appropriate generation method based on input source type
      switch (data.inputSourceType) {
        case ModelInputSourceType.file:
          final filePath = data.filePath!;
          modelFiles = await quicktypeService.generateFromFile(
            modelName: data.name,
            filePath: filePath,
            style: data.style,
            immutable: data.immutable,
            copyWith: data.copyWith,
            equatable: data.equatable,
            detectRelationships: false, // We handle relationships separately
          );
          break;

        case ModelInputSourceType.url:
          final url = data.urlPath!;
          modelFiles = await quicktypeService.generateFromUrl(
            modelName: data.name,
            url: url,
            style: data.style,
            immutable: data.immutable,
            copyWith: data.copyWith,
            equatable: data.equatable,
            detectRelationships: false, // We handle relationships separately
          );
          break;

        case ModelInputSourceType.template:
          String jsonContent;

          // Check if using custom template with custom fields
          if (data.starterTemplate == ModelStarterTemplate.custom &&
              data.customFields.isNotEmpty) {
            jsonContent = _generateJsonFromCustomFields(data.customFields);
          } else {
            jsonContent = data.starterTemplate.json;
          }

          modelFiles = await quicktypeService.generateFromJson(
            modelName: data.name,
            jsonContent: jsonContent,
            style: data.style,
            immutable: data.immutable,
            copyWith: data.copyWith,
            equatable: data.equatable,
            detectRelationships: false, // We handle relationships separately
          );
          break;
      }

      final generatedFiles = <String>[];

      // Write generated files
      for (final entry in modelFiles.entries) {
        final fileName = entry.key;
        final fileContent = entry.value;
        final filePath = path.join(targetDir.path, fileName);

        await File(filePath).writeAsString(fileContent);
        generatedFiles.add(filePath);

        logger.detail('Generated: $fileName');
      }

      progress.complete('✅ Model generated successfully');
      return generatedFiles;
    } catch (e) {
      progress.fail('❌ Model generation failed');
      rethrow;
    }
  }

  /// Generate relationship models if enabled
  Future<List<String>> _generateRelationships(List<String> mainFiles) async {
    if (!data.relationshipsInFolder) {
      return [];
    }

    try {
      final jsonContent = await _getActualJsonContent();
      final jsonData = _parseJsonSafely(jsonContent);

      if (jsonData == null) {
        logger.warn('Cannot generate relationships: Invalid JSON');
        return [];
      }

      final targetDir = await _prepareTargetDirectory();

      final relationshipFiles = await relationshipService.generateRelationships(
        parentModelName: data.name,
        jsonData: jsonData,
        targetDir: targetDir,
        style: data.style,
        folderPerModel: data.relationshipsInFolder,
        immutable: data.immutable,
        copyWith: data.copyWith,
        equatable: data.equatable,
      );

      if (relationshipFiles.isNotEmpty) {
        logger.info(
          '✅ Generated ${relationshipFiles.length} relationship models',
        );
      }

      return relationshipFiles;
    } catch (e) {
      logger.warn('Failed to generate relationships: $e');
      return [];
    }
  }

  /// Handle post-generation tasks
  Future<void> _postGeneration() async {
    if (data.style.requiresBuildRunner) {
      final hasRunner = await environmentService.hasBuildRunner();
      if (hasRunner) {
        final shouldRun = await _promptBuildRunner();
        if (shouldRun) {
          logger.info('Running build_runner...');
          await environmentService.runBuildRunner();
        }
      }
    }
  }

  /// Format generated files
  Future<void> _formatFiles(List<String> files) async {
    if (files.isEmpty) return;

    try {
      logger.detail('Formatting generated files...');

      for (final filePath in files) {
        final result = await Process.run('dart', ['format', filePath]);
        if (result.exitCode != 0) {
          logger.warn('Failed to format: ${path.basename(filePath)}');
        }
      }

      logger.detail('✅ Files formatted successfully');
    } catch (e) {
      logger.warn('Formatting failed: $e');
    }
  }

  /// Get actual JSON content based on input source type
  Future<String> _getActualJsonContent() async {
    switch (data.inputSourceType) {
      case ModelInputSourceType.file:
        final file = File(data.filePath!);
        return await file.readAsString();

      case ModelInputSourceType.url:
        // Use HTTP client to get fresh JSON for relationship processing
        final response = await http.get(Uri.parse(data.urlPath!));
        if (response.statusCode == 200) {
          return response.body;
        } else {
          throw Exception(
            'Failed to fetch JSON from URL: ${response.statusCode}',
          );
        }

      case ModelInputSourceType.template:
        // Check if using custom template with custom fields
        if (data.starterTemplate == ModelStarterTemplate.custom &&
            data.customFields.isNotEmpty) {
          return _generateJsonFromCustomFields(data.customFields);
        } else {
          return data.starterTemplate.json;
        }
    }
  }

  /// Generate JSON string from custom fields
  String _generateJsonFromCustomFields(List<CustomField> fields) {
    final jsonMap = <String, dynamic>{};

    for (final field in fields) {
      jsonMap[field.name] = field.jsonValue;
    }

    return jsonEncode(jsonMap);
  }

  /// Prepare target directory
  Future<Directory> _prepareTargetDirectory() async {
    final targetPath = ArchitectureCoordinator.getFullTargetPath(
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

  /// Parse JSON safely
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

  /// Prompt for auto-fix
  Future<bool> _promptAutoFix() async {
    // For now, return true to auto-fix. In interactive mode, this would prompt the user
    return true;
  }

  /// Prompt for build runner
  Future<bool> _promptBuildRunner() async {
    // For now, return true to run build_runner. In interactive mode, this would prompt the user
    return true;
  }

  /// Log summary of generated files
  void _logSummary(List<String> generatedFiles) {
    logger.info('');
    logger.success('✅ Model generation completed successfully!');
    logger.info('');
    logger.info('📊 Generation Summary:');
    logger.info('  • Model Name: ${data.name}');
    logger.info('  • Style: ${data.style.displayName}');
    logger.info('  • Input Source: ${data.inputSourceType.displayName}');

    if (data.onPath != null && data.onPath!.isNotEmpty) {
      logger.info('  • Subdirectory: ${data.onPath}');
    }

    if (data.filePath != null) {
      logger.info('  • Source File: ${data.filePath}');
    }

    if (data.urlPath != null) {
      logger.info('  • Source URL: ${data.urlPath}');
    }

    // Feature flags
    final features = <String>[];
    if (data.immutable) features.add('immutable');
    if (data.copyWith) features.add('copyWith');
    if (data.equatable) features.add('equatable');
    if (data.relationshipsInFolder) features.add('relationships');

    if (features.isNotEmpty) {
      logger.info('  • Features: ${features.join(', ')}');
    }

    logger.info('');
    logger.info('📁 Generated Files (${generatedFiles.length}):');

    for (final file in generatedFiles) {
      final relativePath = path.relative(file, from: data.targetDir.path);
      logger.info('  • $relativePath');
    }

    logger.info('');

    // Additional information based on style
    if (data.style.requiresBuildRunner) {
      logger.info('💡 Next Steps:');
      logger.info('  • Run: dart run build_runner build');
      logger.info('  • This generates .g.dart files for serialization');
      logger.info('');
    }

    if (data.style.needsDependencies) {
      logger.info('📦 Required Dependencies:');
      for (final dep in data.style.requiredDependencies) {
        logger.info('  • $dep');
      }
      for (final devDep in data.style.requiredDevDependencies) {
        logger.info('  • $devDep (dev)');
      }
      logger.info('');
    }
  }
}
