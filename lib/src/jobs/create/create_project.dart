import 'dart:io';

import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

class CreateProject {
  final CreateData data;
  final Logger logger;
  final FlutterProjectServiceInterface flutterService;
  final MasonServiceInterface masonService;
  final DependencyServiceInterface dependencyService;
  final PostGenerationServiceInterface postGenService;

  CreateProject(
    this.data, {
    required this.flutterService,
    required this.masonService,
    required this.dependencyService,
    required this.postGenService,
    Logger? logger,
  }) : logger = logger ?? Logger();

  Future<int> execute() async {
    try {
      // Step 1: Create Flutter project base structure
      await flutterService.createProject(
        projectName: data.name,
        organization: data.organization ?? 'com.example',
        description: data.description ?? 'A new Flutter project.',
        platforms: data.platforms ?? ['android', 'ios'],
      );

      // Step 2: Generate custom architecture using Mason
      final targetDir = Directory(data.name);
      // final targetDir = Directory('${Directory.current.path}/${data.name}');

      await masonService.generateFromPackageBrick(
        brickName: data.template.key,
        targetDir: targetDir,
        vars: data.toVars(),
        overwrite: true,
      );

      // Step 3: Create architecture directories
      final progress = logger.progress('Creating architecture directories...');
      final allDirectories = ArchitectureCoordinator.getDirectories(
        data.template,
        full: data.full!,
      );

      for (final dir in allDirectories) {
        final directory = Directory('${targetDir.path}/$dir');
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
          progress.update('Created directory: $dir');
        }
      }
      progress.complete('Architecture directories created successfully');

      // Step 4: Add dependencies
      await dependencyService.addDependencies(
        projectPath: data.name,
        template: data.template,
      );

      // Step 5: Post-generation tasks
      // (e.g., formatting code, running pub get)
      await postGenService.runPostGeneration(data.name);

      _logSummary();

      return ExitCode.success.code;
    } on ValidationException catch (e) {
      logger.errMessage(JobMessages.validationFailed, {'error': e.message});
      return ExitCode.usage.code;
    } on ProjectCreationException catch (e) {
      logger.errMessage(JobMessages.projectCreationFailed, {
        'error': e.message,
      });
      return ExitCode.software.code;
    } on MasonBrickException catch (e) {
      logger.errMessage(JobMessages.templateGeneratedFailed, {
        'error': e.message,
      });
      return ExitCode.software.code;
    } catch (e) {
      logger.errMessage(JobMessages.projectCreationFailed, {
        'error': e.toString(),
      });
      return ExitCode.software.code;
    }
  }

  void _logSummary() {
    logger.info('');
    logger.info('Project Info:');
    logger.info('  Name: ${data.name}');
    logger.info('  Template: ${data.template.key}');
    logger.info('  Platforms: ${data.platforms?.join(', ')}');
    logger.info('  Organization: ${data.organization}');
    logger.info('  Project structure: ${data.full! ? 'full' : 'basic'}');
    logger.info('');
    logger.info('Next Steps:');
    logger.info('  cd ${data.name}');
    logger.info('  flutter run');
    logger.info('');
    logger.success(
      JobMessages.projectCreatedSuccessfully.format({'name': data.name}),
    );
    logger.info('');
  }
}
