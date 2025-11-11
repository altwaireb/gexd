import 'dart:io';

import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

/// Job class to handle middleware generation
/// Uses Mason templates to generate middleware files
/// querying MiddlewareData for necessary information
class MiddlewareJob {
  final MiddlewareData data;
  final Logger logger;
  final MasonServiceInterface masonService;
  final PostGenerationServiceInterface postGenerationService;

  MiddlewareJob(
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
    logger.info('Middleware generation summary:');
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
      MainConstants.generatedFileSuccess.formatWith({'name': 'middleware'}),
    );
  }

  /// Log helpful next steps for middleware usage
  void _logNextSteps() {
    logger.info('');
    logger.info(' Next Steps:');
    logger.info(' Register in route:');
    logger.info('');

    if (data.template == ProjectTemplate.getx) {
      logger.info('   // In lib/app/routes/app_pages.dart');
    } else {
      logger.info('   // In lib/presentation/routes/app_pages.dart');
    }

    logger.info('   GetPage(');
    logger.info("     name: '/your_route',");
    logger.info('     page: () => YourPage(),');
    logger.info('     middlewares: [');
    logger.info('       ${data.name}Middleware(priority: 1),');
    logger.info('     ],');
    logger.info('   ),');
    logger.info('');
    logger.info('💡 Tips:');
    logger.info('   • Lower priority numbers run earlier');
    logger.info('   • Use redirect() for authentication checks');
    logger.info('   • Use onPageBuilt() to wrap pages');

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
    return '$cleanPath/${nameSnakeCase}_middleware.dart';
  }

  /// Generate files using Mason brick
  Future<List<String>> _generate(MiddlewareData data) async {
    final progress = logger.progress(
      MainConstants.generatingFile.formatWith({'component': 'middleware'}),
    );

    try {
      final targetDir = await _prepareTargetDirectory(data);

      await masonService.generateFromPackageBrick(
        brickName: 'middleware',
        targetDir: targetDir,
        vars: data.toVars(),
        overwrite: true,
      );

      progress.complete(
        MainConstants.generatedFilesSuccess.formatWith({'name': 'middleware'}),
      );

      return _buildGeneratedFilesList(data);
    } catch (e) {
      progress.fail(
        MainConstants.generationFilesFailed.formatWith({'name': 'middleware'}),
      );
      rethrow;
    }
  }

  Future<Directory> _prepareTargetDirectory(MiddlewareData data) async {
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
    MiddlewareData data,
  ) {
    return relativePaths.map((relativePath) {
      return path.join(data.targetDir.path, relativePath);
    }).toList();
  }

  /// Build list of generated files for reporting
  List<String> _buildGeneratedFilesList(MiddlewareData data) {
    final String basePath = ArchitectureCoordinator.getComponentWithOnPath(
      component: data.component,
      template: data.template,
      onPath: data.onPath,
    );

    final nameSnakeCase = StringHelpers.toSnakeCase(data.name);

    return [
      '$basePath/${MainConstants.middlewareSuffix}'.formatWith({
        'name': nameSnakeCase,
      }),
    ];
  }
}
