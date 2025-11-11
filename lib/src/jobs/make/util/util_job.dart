import 'dart:io';

import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

/// Job class to handle util generation
/// Uses Mason templates to generate util files
/// querying UtilData for necessary information
class UtilJob {
  final UtilData data;
  final Logger logger;
  final MasonServiceInterface masonService;
  final PostGenerationServiceInterface postGenerationService;

  UtilJob(
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
    logger.info('Util generation summary:');
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

    logger.info('');
    logger.success(
      MainConstants.generatedFileSuccess.formatWith({'name': 'util'}),
    );
  }

  /// Generate files using Mason brick
  Future<List<String>> _generate(UtilData data) async {
    final progress = logger.progress(
      MainConstants.generatingFile.formatWith({'component': 'util'}),
    );

    try {
      final targetDir = await _prepareTargetDirectory(data);

      await masonService.generateFromPackageBrick(
        brickName: 'util',
        targetDir: targetDir,
        vars: data.toVars(),
        overwrite: true,
      );

      progress.complete(
        MainConstants.generatedFilesSuccess.formatWith({'name': 'util'}),
      );

      return _buildGeneratedFilesList(data);
    } catch (e) {
      progress.fail(
        MainConstants.generationFilesFailed.formatWith({'name': 'util'}),
      );
      rethrow;
    }
  }

  Future<Directory> _prepareTargetDirectory(UtilData data) async {
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
  List<String> _buildFullFilePaths(List<String> relativePaths, UtilData data) {
    return relativePaths.map((relativePath) {
      return path.join(data.targetDir.path, relativePath);
    }).toList();
  }

  /// Build list of generated files for reporting
  List<String> _buildGeneratedFilesList(UtilData data) {
    final String basePath = ArchitectureCoordinator.getComponentWithOnPath(
      component: data.component,
      template: data.template,
      onPath: data.onPath,
    );

    final nameSnakeCase = StringHelpers.toSnakeCase(data.name);

    return [
      '$basePath/${MainConstants.utilSuffix}'.formatWith({
        'name': nameSnakeCase,
      }),
    ];
  }
}
