import 'dart:io';

import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

class InitJob {
  final InitData data;
  final Logger logger;
  final MasonServiceInterface masonService;
  final DependencyServiceInterface dependencyService;
  final PostGenerationServiceInterface postGenService;

  InitJob(
    this.data, {
    required this.masonService,
    required this.dependencyService,
    required this.postGenService,
    Logger? logger,
  }) : logger = logger ?? Logger();

  Directory get targetDirectory => Directory(data.targetDir);

  Future<int> execute() async {
    try {
      // Step 1: Generate project structure using Mason
      await masonService.generateFromPackageBrick(
        brickName: data.template.key,
        targetDir: targetDirectory,
        vars: data.toVars(),
        overwrite: true,
      );

      // Step 2: Add dependencies
      await dependencyService.addDependencies(
        projectPath: targetDirectory.path,
        template: data.template,
      );

      // Step 3: Post-generation tasks
      // (e.g., formatting code, running pub get)
      await postGenService.runPostGeneration(targetDirectory.path);

      _logSummary();

      return ExitCode.success.code;
    } catch (e) {
      // Re-throw to let GexdCommandRunner handle it centrally
      rethrow;
    }
  }

  void _logSummary() {
    logger.info('');
    logger.info('Project Info:');
    logger.info('  Name: ${data.name}');
    logger.info('  Template: ${data.template.key}');
    logger.info('  Project structure: ${data.full! ? 'full' : 'basic'}');
    logger.info('');
    logger.info('Next Steps:');
    logger.info('  cd ${data.name}');
    logger.info('  flutter run');
    logger.info('');
    logger.success(
      JobMessages.projectInitializationSuccessfully.format({'name': data.name}),
    );
    logger.info('');
  }
}
