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
    logger.info('Binding generation summary:');
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
    _logNextSteps();

    logger.success(
      MainConstants.generatedFileSuccess.formatWith({'name': 'Binding'}),
    );
  }

  /// Log helpful next steps for binding usage
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
    logger.info('     name: Routes.YOUR_ROUTE,');
    logger.info('     page: () => YourView(),');
    logger.info('     binding: ${data.name}Binding(),');
    logger.info('   ),');
    logger.info('');
    logger.info('💡 Tip: Define the route constant in app_routes.dart');
  }

  /// Generate files using Mason brick
  Future<List<String>> _generate(BindingData data) async {
    final progress = logger.progress(
      MainConstants.generatingFile.formatWith({'component': 'binding'}),
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
    String targetPath;
    if (data.location == BindingLocation.screen && data.screenName != null) {
      // For screen bindings, place in the specific screen's bindings folder
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
        'bindings',
      );
    } else {
      // For core and shared bindings
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
  List<String> _buildFullFilePaths(
    List<String> relativePaths,
    BindingData data,
  ) {
    return relativePaths.map((relativePath) {
      return path.join(data.targetDir.path, relativePath);
    }).toList();
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
      // get screen name in snake_case
      final screenPath = StringHelpers.toSnakeCase(data.screenName!);
      basePath = data.onPath != null
          ? '$screenBasePath/${data.onPath}/$screenPath/bindings/'
          : '$screenBasePath/$screenPath/bindings/';
    } else {
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
