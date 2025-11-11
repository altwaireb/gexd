import 'dart:io';

import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

/// Job class to handle service generation
/// Uses Mason templates to generate service files
/// querying ServiceData for necessary information

class ServiceJob {
  final ServiceData data;
  final Logger logger;
  final MasonServiceInterface masonService;
  final PostGenerationServiceInterface postGenerationService;

  ServiceJob(
    this.data, {
    required this.masonService,
    required this.postGenerationService,
    Logger? logger,
  }) : logger = logger ?? Logger();

  Future<int> execute() async {
    try {
      // Generate files
      final List<String> generatedFiles = await _generate(data);

      // Format only the generated files for better performance
      final fullFilePaths = _buildFullFilePaths(generatedFiles, data);
      await postGenerationService.formatSpecificFiles(
        fullFilePaths,
        data.targetDir.path,
      );

      _logSummary(generatedFiles);

      return ExitCode.success.code;
    } catch (e) {
      // Re-throw to let GexdCommandRunner handle it centrally
      rethrow;
    }
  }

  void _logSummary(List<String> generatedFiles) {
    logger.info('');
    logger.info('Service generation summary:');
    logger.info('  Name: ${data.name}');
    if (data.onPath != null && data.onPath!.isNotEmpty) {
      logger.info('  On: ${data.onPath}');
    }

    logger.info('');
    if (generatedFiles.isNotEmpty) {
      logger.info('Generated files:');
      for (final file in generatedFiles) {
        logger.info(' - $file');
      }
    } else {
      logger.info('No files were generated.');
    }
    _logNextSteps();

    logger.success(
      MainConstants.generatedFileSuccess.formatWith({'name': 'service'}),
    );
  }

  /// Log helpful next steps for service usage
  void _logNextSteps() {
    logger.info('');
    logger.info(' Next Steps:');
    logger.info(' 1. Register in dependency injection:');
    logger.info('');

    if (data.template == ProjectTemplate.getx) {
      logger.info('   // In lib/app/core/bindings/initial_binding.dart');
    } else {
      logger.info('   // In lib/core/bindings/initial_binding.dart');
    }

    logger.info(
      '   Get.lazyPut<${data.name}Service>(() => ${data.name}Service());',
    );
    logger.info('');
    logger.info(' 2. Usage in controllers:');
    logger.info(
      '   final ${data.name}Service ${StringHelpers.toCamelCase(data.name)}Service = Get.find<${data.name}Service>();',
    );
    logger.info('');
    logger.info(
      '💡 Tip: Use Get.lazyPut for services that are not immediately needed.',
    );
  }

  /// Generate files using Mason brick
  Future<List<String>> _generate(ServiceData data) async {
    final progress = logger.progress(
      MainConstants.generatingFile.formatWith({'component': 'service'}),
    );

    try {
      final targetDir = await _prepareTargetDirectory(data);

      await masonService.generateFromPackageBrick(
        brickName: 'service',
        targetDir: targetDir,
        vars: data.toVars(),
        overwrite: true,
      );

      progress.complete(
        MainConstants.generatedFilesSuccess.formatWith({'name': 'service'}),
      );

      return _buildGeneratedFilesList(data);
    } catch (e) {
      progress.fail(
        MainConstants.generationFilesFailed.formatWith({'name': 'service'}),
      );
      rethrow;
    }
  }

  Future<Directory> _prepareTargetDirectory(ServiceData data) async {
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

  /// Build full file paths for formatting
  List<String> _buildFullFilePaths(
    List<String> relativePaths,
    ServiceData data,
  ) {
    return relativePaths.map((relativePath) {
      return path.join(data.targetDir.path, relativePath);
    }).toList();
  }

  /// Build list of generated files for reporting
  List<String> _buildGeneratedFilesList(ServiceData data) {
    final String basePath = ArchitectureCoordinator.getComponentWithOnPath(
      component: data.component,
      template: data.template,
      onPath: data.onPath,
    );

    final nameSnakeCase = StringHelpers.toSnakeCase(data.name);

    return [
      '$basePath/${MainConstants.serviceSuffix}'.formatWith({
        'name': nameSnakeCase,
      }),
    ];
  }
}
