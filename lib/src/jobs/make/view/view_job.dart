import 'dart:io';

import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

/// Job class to handle view generation
/// Uses Mason templates to generate view files
/// querying ViewData for necessary information
class ViewJob {
  final ViewData data;
  final Logger logger;
  final MasonServiceInterface masonService;
  final PostGenerationServiceInterface postGenerationService;

  ViewJob(
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
    logger.info('View generation summary:');
    logger.info('  Name: ${data.name}');
    logger.info('  Location: ${data.location.key}');
    if (data.onPath != null && data.onPath!.isNotEmpty) {
      logger.info('  On: ${data.onPath}');
    }
    if (data.screenName != null && data.screenName!.isNotEmpty) {
      logger.info('  Screen: ${data.screenName}');
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
      MainConstants.generatedFileSuccess.formatWith({'name': 'view'}),
    );
  }

  /// Generate files using Mason brick
  Future<List<String>> _generate(ViewData data) async {
    final progress = logger.progress(
      MainConstants.generatingFile.formatWith({'component': 'view'}),
    );

    try {
      final targetDir = await _prepareTargetDirectory(data);

      await masonService.generateFromPackageBrick(
        brickName: 'view',
        targetDir: targetDir,
        vars: data.toVars(),
        overwrite: true,
      );

      progress.complete(
        MainConstants.generatedFilesSuccess.formatWith({'name': 'view'}),
      );

      return _buildGeneratedFilesList(data);
    } catch (e) {
      progress.fail(
        MainConstants.generationFilesFailed.formatWith({'name': 'view'}),
      );
      rethrow;
    }
  }

  Future<Directory> _prepareTargetDirectory(ViewData data) async {
    String targetPath;
    if (data.location == ViewLocation.screen && data.screenName != null) {
      // For screen views, place in the specific screen's views folder
      final screenBasePath = ArchitectureCoordinator.getComponentWithOnPath(
        component: NameComponent.screen,
        template: data.template,
        onPath: data.onPath,
      );
      final screenPath = StringHelpers.toSnakeCase(data.screenName!);
      targetPath = path.join(
        data.targetDir.path,
        screenBasePath,
        screenPath,
        'views',
      );
    } else {
      // For shared views
      targetPath = ArchitectureCoordinator.getFullTargetPath(
        projectPath: data.targetDir.path,
        component: data.component,
        template: data.template,
        onPath: data.onPath,
      );
    }

    final targetDir = Directory(targetPath);

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
      logger.detail('Created directory: $targetPath');
    }

    return targetDir;
  }

  /// Build full file paths for formatting
  List<String> _buildFullFilePaths(List<String> relativePaths, ViewData data) {
    return relativePaths.map((relativePath) {
      return path.join(data.targetDir.path, relativePath);
    }).toList();
  }

  /// Build list of generated files for reporting
  List<String> _buildGeneratedFilesList(ViewData data) {
    String basePath;
    if (data.location == ViewLocation.screen && data.screenName != null) {
      // For screen views, show path in the screen's views folder
      final screenBasePath = ArchitectureCoordinator.getComponentPath(
        NameComponent.screen,
        data.template,
      );
      final screenPath = StringHelpers.toSnakeCase(data.screenName!);
      basePath = data.onPath != null
          ? '$screenBasePath/${data.onPath}/$screenPath/views/'
          : '$screenBasePath/$screenPath/views/';
    } else {
      // For shared views
      final componentBasePath = ArchitectureCoordinator.getComponentPath(
        data.component,
        data.template,
      );
      basePath = data.onPath != null
          ? '$componentBasePath/${data.onPath}/'
          : '$componentBasePath/';
    }
    final nameSnakeCase = StringHelpers.toSnakeCase(data.name);

    return [
      '$basePath${data.location == ViewLocation.shared ? MainConstants.viewSingleSuffix : MainConstants.viewSuffix}'
          .formatWith({'name': nameSnakeCase}),
    ];
  }
}
