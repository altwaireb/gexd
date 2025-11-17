import 'dart:io';

import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

/// Job to create a new Flutter project with specified architecture
/// Uses FlutterProjectService to create base project
/// Uses MasonService to generate architecture structure
/// Uses DependencyService to add necessary dependencies
/// Uses PostGenerationService for post-creation tasks
class CreateJob {
  final CreateData data;
  final Logger logger;
  final FlutterProjectServiceInterface flutterService;
  final MasonServiceInterface masonService;
  final DependencyServiceInterface dependencyService;
  final PostGenerationServiceInterface postGenService;

  CreateJob(
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

      final masonProgress = logger.progress(
        'Generating project structure from template...',
      );

      await masonService.generateFromPackageBrick(
        brickName: data.template.key,
        targetDir: targetDir,
        vars: data.toVars(),
        overwrite: true,
        hooks: true,
      );

      masonProgress.complete('Project structure generated successfully');

      // Verify key files were created
      final configFile = File('${targetDir.path}/.gexd/config.yaml');
      final testFile = File('${targetDir.path}/test/widget_test.dart');

      if (!configFile.existsSync()) {
        logger.warn('Warning: .gexd/config.yaml was not created properly');
      } else {
        logger.detail('✓ .gexd/config.yaml created');
      }

      if (!testFile.existsSync()) {
        logger.warn('Warning: test/widget_test.dart was not created properly');
      } else {
        final content = await testFile.readAsString();
        if (content.contains('{{project_name.snakeCase()}}')) {
          logger.warn(
            'Warning: test/widget_test.dart contains unprocessed Mason variables',
          );
        } else {
          logger.detail('✓ test/widget_test.dart created and processed');
        }
      }

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
    logger.info('📚 Documentation: ${MainConstants.packageDocumentation}');
    logger.info('💡 Need help? Visit our docs for guides and examples!');
    logger.info('');
  }
}
