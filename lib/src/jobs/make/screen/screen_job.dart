import 'dart:io';

import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

class ScreenJob {
  final ScreenData data;
  final Logger logger;
  final MasonServiceInterface masonService;
  final RouteUpdateServiceInterface routeUpdateService;
  final PostGenerationServiceInterface postGenerationService;

  ScreenJob(
    this.data, {
    required this.masonService,
    required this.routeUpdateService,
    required this.postGenerationService,
    Logger? logger,
  }) : logger = logger ?? Logger();

  Future<int> execute() async {
    try {
      // Generate files
      final List<String> generatedFiles = await _generate(data);

      // Update routes if not skipped
      bool routesUpdated = false;
      if (data.skipRoute == false) {
        routesUpdated = await _tryUpdateRoutes(data);
      }

      // Format only the generated files for better performance
      final fullFilePaths = _buildFullFilePaths(generatedFiles, data);
      await postGenerationService.formatSpecificFiles(
        fullFilePaths,
        data.targetDir.path,
      );

      _logSummary(generatedFiles, routesUpdated);
      return ExitCode.success.code;
    } catch (e) {
      // Re-throw to let GexdCommandRunner handle it centrally
      rethrow;
    }
  }

  void _logSummary(List<String> generatedFiles, bool routesUpdated) {
    logger.info('');
    logger.info('Screen generation summary:');
    logger.info('  Name: ${data.name}');
    logger.info('  Type: ${data.screenType.key}');
    if (data.onPath != null && data.onPath!.isNotEmpty) {
      logger.info('  On: ${data.onPath}');
    }
    if (data.hasModel) {
      logger.info('  Model: ${data.modelName}');
    }
    if (data.skipRoute == false && routesUpdated == true) {
      logger.info('  Route Update: Attempted');
    } else {
      logger.warn('  Route Update: Skipped');
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
      MainConstants.generatedFilesSuccess.formatWith({'name': 'Screen'}),
    );
  }

  /// Generate screen files using Mason brick
  Future<List<String>> _generate(ScreenData screenData) async {
    final progress = logger.progress(
      MainConstants.generatingFiles.formatWith({'component': 'screen'}),
    );

    try {
      final targetDir = await _prepareTargetDirectory(screenData);

      await masonService.generateFromPackageBrick(
        brickName: 'screen',
        targetDir: targetDir,
        vars: data.toVars(),
        overwrite: true,
      );

      progress.complete(
        MainConstants.generatedFilesSuccess.formatWith({'name': 'Screen'}),
      );

      return _buildGeneratedFilesList(screenData);
    } catch (e) {
      progress.fail(
        MainConstants.generationFilesFailed.formatWith({'name': 'screen'}),
      );
      rethrow;
    }
  }

  Future<Directory> _prepareTargetDirectory(ScreenData screenData) async {
    final targetPath = await ArchitectureCoordinator.getFullTargetPathByConfig(
      projectPath: screenData.targetDir.path,
      component: NameComponent.screen,
      onPath: screenData.onPath,
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
    ScreenData data,
  ) {
    return relativePaths.map((relativePath) {
      return path.join(data.targetDir.path, relativePath);
    }).toList();
  }

  /// Build list of generated files for reporting
  List<String> _buildGeneratedFilesList(ScreenData data) {
    final componentBasePath = ArchitectureCoordinator.getComponentPath(
      NameComponent.screen,
      data.template,
    );
    final basePath = data.onPath != null
        ? '$componentBasePath/${data.onPath}/'
        : '$componentBasePath/';
    final screenSnakeCase = StringHelpers.toSnakeCase(data.name);

    return [
      '$basePath$screenSnakeCase/${MainConstants.controllerSuffix}'.formatWith({
        'name': screenSnakeCase,
      }),
      '$basePath$screenSnakeCase/${MainConstants.viewSuffix}'.formatWith({
        'name': screenSnakeCase,
      }),
      '$basePath$screenSnakeCase/${MainConstants.bindingSuffix}'.formatWith({
        'name': screenSnakeCase,
      }),
    ];
  }

  /// Try to update routes automatically
  Future<bool> _tryUpdateRoutes(ScreenData screenData) async {
    final progress = logger.progress(MainConstants.updatingRoutes);

    try {
      final success = await routeUpdateService.addScreenRoute(
        screenName: screenData.name,
        subPath: screenData.onPath,
        template: screenData.template,
      );

      if (success) {
        progress.complete(MainConstants.routesUpdatedSuccess);
        return true;
      } else {
        progress.fail(MainConstants.routeUpdateFailed);
        logger.detail('Routes were not updated automatically');
        return false;
      }
    } catch (e) {
      progress.fail(MainConstants.routeUpdateFailed);
      logger.detail('Route update failed: $e');
      return false;
    }
  }
}
