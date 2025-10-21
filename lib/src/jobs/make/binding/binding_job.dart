import 'dart:io';

import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

class BindingJob {
  final BindingData data;
  final Logger logger;
  final MasonServiceInterface masonService;
  final PostGenerationServiceInterface postGenerationService;

  BindingJob(
    this.data, {
    required this.masonService,
    required this.postGenerationService,
    Logger? logger,
  }) : logger = logger ?? Logger();

  Future<int> execute() async {
    try {
      // Generate files
      final List<String> generatedFile = await _generate(data);

      // Format generated file code for better quality
      final fileDir = Directory(path.join(data.targetDir.path, data.name));
      await postGenerationService.formatCode(fileDir.path);

      _logSummary(generatedFile);

      return ExitCode.success.code;
    } catch (e) {
      // Re-throw to let GexdCommandRunner handle it centrally
      rethrow;
    }
  }

  void _logSummary(List<String> generatedFiles) {
    logger.info('');
    logger.info('Screen generation summary:');
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
    logger.info(
      MainConstants.generatedFilesSuccess.formatWith({'name': 'Binding'}),
    );
  }

  /// Generate files using Mason brick
  Future<List<String>> _generate(BindingData data) async {
    final progress = logger.progress(
      MainConstants.generatingFiles.formatWith({'component': 'binding'}),
    );

    try {
      final targetDir = await _prepareTargetDirectory(data);

      await masonService.generateFromPackageBrick(
        brickName: 'binding',
        targetDir: targetDir,
        vars: data.toVars(),
        overwrite: true,
      );

      progress.complete(
        MainConstants.generatedFilesSuccess.formatWith({'name': 'Binding'}),
      );

      return _buildGeneratedFilesList(data);
    } catch (e) {
      progress.fail(
        MainConstants.generationFilesFailed.formatWith({'name': 'Binding'}),
      );
      rethrow;
    }
  }

  Future<Directory> _prepareTargetDirectory(BindingData data) async {
    final currentDir = data.targetDir;

    String targetPath;
    if (data.location == BindingLocation.screen && data.screenName != null) {
      // For screen bindings, place in the specific screen's bindings folder
      final screenBasePath = ArchitectureCoordinator.getComponentPath(
        NameComponent.screen,
        data.template,
      );
      final screenPath = StringHelpers.toSnakeCase(data.screenName!);
      targetPath = data.onPath != null
          ? path.join(
              currentDir.path,
              screenBasePath,
              data.onPath!,
              screenPath,
              'bindings',
            )
          : path.join(currentDir.path, screenBasePath, screenPath, 'bindings');
    } else {
      // For core and shared bindings
      final basePath = ArchitectureCoordinator.getComponentPath(
        data.component,
        data.template,
      );
      targetPath = data.onPath != null
          ? path.join(currentDir.path, basePath, data.onPath!)
          : path.join(currentDir.path, basePath);
    }

    final targetDir = Directory(targetPath);

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
      logger.detail('Created directory: $targetPath');
    }

    return targetDir;
  }

  /// Build list of generated files for reporting
  List<String> _buildGeneratedFilesList(BindingData data) {
    String basePath;
    if (data.location == BindingLocation.screen && data.screenName != null) {
      // For screen bindings, show path in the screen's bindings folder
      final screenBasePath = ArchitectureCoordinator.getComponentPath(
        NameComponent.screen,
        data.template,
      );
      final screenPath = StringHelpers.toSnakeCase(data.screenName!);
      basePath = data.onPath != null
          ? '$screenBasePath/${data.onPath}/$screenPath/bindings/'
          : '$screenBasePath/$screenPath/bindings/';
    } else {
      // For core and shared bindings
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
      '$basePath${MainConstants.bindingSingleSuffix}'.formatWith({
        'name': nameSnakeCase,
      }),
    ];
  }
}
