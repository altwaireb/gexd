import 'dart:io';

import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

/// Job class to handle exception generation
/// Uses Mason templates to generate exception files
/// querying ExceptionData for necessary information
class ExceptionJob {
  final ExceptionData data;
  final Logger logger;
  final MasonServiceInterface masonService;
  final PostGenerationServiceInterface postGenerationService;

  ExceptionJob(
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
    logger.info('Exception generation summary:');
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
      MainConstants.generatedFileSuccess.formatWith({'name': 'exception'}),
    );
  }

  /// Log helpful next steps for exception usage
  void _logNextSteps() {
    logger.info('');
    logger.info(' Next Steps:');
    logger.info(' Use in your code:');
    logger.info('');

    logger.info('   try {');
    logger.info('     // Your risky operation');
    logger.info('   } catch (e) {');
    logger.info('     throw ${data.name}Exception(');
    logger.info("       'Error occurred: \${e.toString()}',");
    logger.info("       code: 'OPERATION_FAILED',");
    logger.info('     );');
    logger.info('   }');
    logger.info('');
    logger.info('💡 Tips:');
    logger.info('   • Use meaningful error messages');
    logger.info('   • Include error codes for better debugging');
    logger.info('   • Handle exceptions appropriately in UI layers');

    // Add import suggestion
    final importPath = _getImportPath();
    if (importPath.isNotEmpty) {
      logger.info('');
      logger.info(' 📦 Import statement:');
      logger.info("   import '$importPath';");
    }
  }

  /// Generate appropriate import path
  String _getImportPath() {
    final cleanPath = ArchitectureCoordinator.getComponentWithOnPathWithoutLib(
      component: data.component,
      template: data.template,
      onPath: data.onPath,
    );

    final nameSnakeCase = StringHelpers.toSnakeCase(data.name);
    return '$cleanPath/${nameSnakeCase}_exception.dart';
  }

  /// Generate files using Mason brick
  Future<List<String>> _generate(ExceptionData data) async {
    final progress = logger.progress(
      MainConstants.generatingFile.formatWith({'component': 'exception'}),
    );

    try {
      final targetDir = await _prepareTargetDirectory(data);

      await masonService.generateFromPackageBrick(
        brickName: 'exception',
        targetDir: targetDir,
        vars: data.toVars(),
        overwrite: true,
      );

      progress.complete(
        MainConstants.generatedFilesSuccess.formatWith({'name': 'exception'}),
      );

      return _buildGeneratedFilesList(data);
    } catch (e) {
      progress.fail(
        MainConstants.generationFilesFailed.formatWith({'name': 'exception'}),
      );
      rethrow;
    }
  }

  Future<Directory> _prepareTargetDirectory(ExceptionData data) async {
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
    ExceptionData data,
  ) {
    return relativePaths.map((relativePath) {
      return path.join(data.targetDir.path, relativePath);
    }).toList();
  }

  /// Build list of generated files for reporting
  List<String> _buildGeneratedFilesList(ExceptionData data) {
    final String basePath = ArchitectureCoordinator.getComponentWithOnPath(
      component: data.component,
      template: data.template,
      onPath: data.onPath,
    );

    final nameSnakeCase = StringHelpers.toSnakeCase(data.name);

    return [
      '$basePath/${MainConstants.exceptionSuffix}'.formatWith({
        'name': nameSnakeCase,
      }),
    ];
  }
}
