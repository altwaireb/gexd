import 'dart:io';

import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

class RepositoryJob {
  final RepositoryData data;
  final Logger logger;
  final MasonServiceInterface masonService;
  final PostGenerationServiceInterface postGenerationService;

  RepositoryJob(
    this.data, {
    required this.masonService,
    required this.postGenerationService,
    Logger? logger,
  }) : logger = logger ?? Logger();

  Future<int> execute() async {
    try {
      String? generatedInterfaceFile;

      if (data.hasInterface) {
        generatedInterfaceFile = await _generateInterface(data);
      }
      // Generate files
      final List<String> generatedFiles = await _generate(data);

      // Add generated interface file to the list if applicable
      if (data.hasInterface && generatedInterfaceFile != null) {
        generatedFiles.add(generatedInterfaceFile);
      }

      // Format only the generated files for better performance
      final fullFilePaths = _buildFullFilePaths(generatedFiles, data);
      await postGenerationService.formatSpecificFiles(
        fullFilePaths,
        data.targetDir.path,
      );

      _logSummary(generatedFiles, generatedInterfaceFile);

      return ExitCode.success.code;
    } catch (e) {
      // Re-throw to let GexdCommandRunner handle it centrally
      rethrow;
    }
  }

  void _logSummary(
    List<String> generatedFiles,
    String? generatedInterfaceFile,
  ) {
    logger.info('');
    logger.info('Repository generation summary:');
    logger.info('  Name: ${data.name}');
    logger.info('  Type: ${data.type.key}');
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
      MainConstants.generatedFileSuccess.formatWith({'name': 'repository'}),
    );
  }

  /// Generate files using Mason brick
  Future<List<String>> _generate(RepositoryData data) async {
    final progress = logger.progress(
      MainConstants.generatingFile.formatWith({'component': 'repository'}),
    );

    try {
      final targetDir = await _prepareTargetDirectory(data);

      final String interfaceName = '${data.name}Repository';
      final String interfaceFileName = MainConstants.interfaceSuffix.formatWith(
        {'name': StringHelpers.toSnakeCase(interfaceName)},
      );

      final String interfaceImport =
          ArchitectureCoordinator.getImportComponentWithSuffixPath(
            component: NameComponent.repositoriesInterfaces,
            template: data.template,
            onPath: data.onPath,
            projectName: data.projectName,
            suffix: interfaceFileName,
          );

      final vars = data.toVars();

      // Add interface import variables if needed
      if (data.hasInterface) {
        vars['interfaceImport'] = interfaceImport;
      }

      await masonService.generateFromPackageBrick(
        brickName: 'repository',
        targetDir: targetDir,
        vars: vars,
        overwrite: true,
      );

      progress.complete(
        MainConstants.generatedFilesSuccess.formatWith({'name': 'repository'}),
      );

      return _buildGeneratedFilesList(data);
    } catch (e) {
      progress.fail(
        MainConstants.generationFilesFailed.formatWith({'name': 'repository'}),
      );
      rethrow;
    }
  }

  Future<String> _generateInterface(RepositoryData data) async {
    final progress = logger.progress(
      MainConstants.generatingFile.formatWith({'component': 'interface'}),
    );

    try {
      final targetDir = await _prepareTargetInterfaceDirectory(data);
      final String interfaceName = '${data.name}Repository';
      final String interfaceFileName = MainConstants.interfaceSuffix.formatWith(
        {'name': StringHelpers.toSnakeCase(interfaceName)},
      );

      final vars = {
        'name': '${data.name}Repository',
        'is_crud': data.type == RepositoryType.crud,
        'is_empty': data.type == RepositoryType.empty,
        'hasModel': data.hasModel,
        'modelName': data.modelName,
        'modelExists': data.modelData?.exists ?? false,
        'modelImport':
            data.modelData?.importPath != null && data.modelData!.exists
            ? data.modelData!.importPath
            : null,
        'packageName': data.projectName,
      };
      await masonService.generateFromPackageBrick(
        brickName: 'interface',
        targetDir: targetDir,
        vars: vars,
        overwrite: data.force,
      );

      progress.complete(
        MainConstants.generatedFilesSuccess.formatWith({'name': 'interface'}),
      );

      final file = ArchitectureCoordinator.getComponentWithSuffixPath(
        component: NameComponent.repositoriesInterfaces,
        template: data.template,
        onPath: data.onPath,
        suffix: interfaceFileName,
      );

      return file;
    } catch (e) {
      progress.fail(
        MainConstants.generationFilesFailed.formatWith({'name': 'interface'}),
      );
      rethrow;
    }
  }

  Future<Directory> _prepareTargetDirectory(RepositoryData data) async {
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

  Future<Directory> _prepareTargetInterfaceDirectory(
    RepositoryData data,
  ) async {
    final String targetPath = ArchitectureCoordinator.getFullTargetPath(
      projectPath: data.targetDir.path,
      component: NameComponent.repositoriesInterfaces,
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
    RepositoryData data,
  ) {
    return relativePaths.map((relativePath) {
      return path.join(data.targetDir.path, relativePath);
    }).toList();
  }

  /// Build list of generated files for reporting
  List<String> _buildGeneratedFilesList(RepositoryData data) {
    final String basePath = ArchitectureCoordinator.getComponentWithOnPath(
      component: data.component,
      template: data.template,
      onPath: data.onPath,
    );

    final nameSnakeCase = StringHelpers.toSnakeCase(data.name);

    return [
      '$basePath/${MainConstants.repositorySuffix}'.formatWith({
        'name': nameSnakeCase,
      }),
    ];
  }
}
