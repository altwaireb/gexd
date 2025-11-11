import 'dart:io';

import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

/// Job class to handle widget generation
/// Uses Mason templates to generate widget files
/// querying WidgetData for necessary information
class WidgetJob {
  final WidgetData data;
  final Logger logger;
  final MasonServiceInterface masonService;
  final PostGenerationServiceInterface postGenerationService;

  WidgetJob(
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
    logger.info('Widget generation summary:');
    logger.info('  Name: ${data.name}');
    logger.info('  Location: ${data.location.key}');
    if (data.onPath != null && data.onPath!.isNotEmpty) {
      logger.info('  On: ${data.onPath}');
    }
    if (data.screenName != null && data.screenName!.isNotEmpty) {
      logger.info('  Screen: ${data.screenName}');
    }

    logger.info('');
    logger.info('Generated files:');
    for (final file in generatedFiles) {
      logger.info(' - $file');
    }

    logger.info('');
    logger.info('Generated widget successful');
  }

  /// Generates widget files using Mason
  Future<List<String>> _generate(WidgetData data) async {
    final progress = logger.progress(
      MainConstants.generatingFile.formatWith({'component': 'widget'}),
    );

    try {
      final targetDir = await _prepareTargetDirectory(data);

      await masonService.generateFromPackageBrick(
        brickName: 'widget',
        targetDir: targetDir,
        vars: data.toVars(),
        overwrite: true,
      );

      progress.complete(
        MainConstants.generatedFilesSuccess.formatWith({'name': 'widget'}),
      );

      return _buildGeneratedFilesList(data);
    } catch (e) {
      progress.fail(
        MainConstants.generationFileFailed.formatWith({'name': 'widget'}),
      );
      rethrow;
    }
  }

  /// Prepare target directory for generation
  Future<Directory> _prepareTargetDirectory(WidgetData data) async {
    final targetPath = _getTargetPath(data);
    final targetDir = Directory(targetPath);

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    return targetDir;
  }

  /// Build list of generated files for logging
  List<String> _buildGeneratedFilesList(WidgetData data) {
    final targetPath = _getTargetPath(data);
    final widgetFile = MainConstants.widgetSingleSuffix.formatWith({
      'name': StringHelpers.toSnakeCase(data.name),
    });

    return [
      path.relative(
        path.join(targetPath, widgetFile),
        from: data.targetDir.path,
      ),
    ];
  }

  /// Gets the full target path for widget generation
  String _getTargetPath(WidgetData data) {
    return ArchitectureCoordinator.getFullTargetPath(
      projectPath: data.targetDir.path,
      component: data.component,
      template: data.template,
      onPath: data.onPath,
    );
  }

  /// Build full file paths for formatting
  List<String> _buildFullFilePaths(
    List<String> relativeFilePaths,
    WidgetData data,
  ) {
    return relativeFilePaths
        .map((file) => path.join(data.targetDir.path, file))
        .toList();
  }
}
