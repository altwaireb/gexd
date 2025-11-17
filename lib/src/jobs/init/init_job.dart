import 'dart:io';

import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

/// Job to initialize a project with specified architecture
/// Validates Flutter project
/// Uses MasonService to generate architecture structure
/// Uses DependencyService to add necessary dependencies
/// Uses PostGenerationService for post-initialization tasks
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
      final masonProgress = logger.progress(
        'Generating project structure from template...',
      );

      await masonService.generateFromPackageBrick(
        brickName: data.template.key,
        targetDir: targetDirectory,
        vars: data.toVars(),
        overwrite: true,
        hooks: true,
      );

      masonProgress.complete('Project structure generated successfully');

      // Verify key files were created
      final configFile = File('${targetDirectory.path}/.gexd/config.yaml');
      final testFile = File('${targetDirectory.path}/test/widget_test.dart');

      if (!configFile.existsSync()) {
        logger.warn('Warning: .gexd/config.yaml was not created properly');
        // Try to create it manually as fallback
        final gexdDir = Directory('${targetDirectory.path}/.gexd');
        if (!gexdDir.existsSync()) {
          gexdDir.createSync(recursive: true);
        }
        await configFile.writeAsString('''# Generation Details
generated_by: Gexd CLI
creation_version: $packageVersion
current_version: $packageVersion
generated_date: ${DateTime.now().toIso8601String()}
last_updated: null

# Project Information
project_name: ${data.name}
template: ${data.template.key}
''');
        logger.detail('✓ .gexd/config.yaml created manually');
      } else {
        logger.detail('✓ .gexd/config.yaml created');
      }

      if (!testFile.existsSync()) {
        logger.warn('Warning: test/widget_test.dart was not created properly');
        // Create it manually as fallback
        await testFile.writeAsString(
          '''import 'package:flutter_test/flutter_test.dart';

import 'package:${data.name}/main.dart';

void main() {
  testWidgets('MainApp builds and settles', (WidgetTester tester) async {
    // Build the application and ensure it boots without throwing.
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    // Basic sanity: MainApp is present in the widget tree.
    expect(find.byType(MainApp), findsOneWidget);
  });
}
''',
        );
        logger.detail('✓ test/widget_test.dart created manually');
      } else {
        final content = await testFile.readAsString();

        // Check if it's the correct template (should contain MainApp, not MyApp)
        final hasCorrectTemplate =
            content.contains('MainApp') &&
            content.contains('package:${data.name}/main.dart');
        final hasUnprocessedVariables = content.contains(
          '{{project_name.snakeCase()}}',
        );

        if (!hasCorrectTemplate || hasUnprocessedVariables) {
          if (!hasCorrectTemplate) {
            logger.warn(
              'Warning: test/widget_test.dart has wrong template content',
            );
          }
          if (hasUnprocessedVariables) {
            logger.warn(
              'Warning: test/widget_test.dart contains unprocessed Mason variables',
            );
          }

          // Replace with correct template
          await testFile.writeAsString(
            '''import 'package:flutter_test/flutter_test.dart';

import 'package:${data.name}/main.dart';

void main() {
  testWidgets('MainApp builds and settles', (WidgetTester tester) async {
    // Build the application and ensure it boots without throwing.
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    // Basic sanity: MainApp is present in the widget tree.
    expect(find.byType(MainApp), findsOneWidget);
  });
}
''',
          );
          logger.detail(
            '✓ test/widget_test.dart corrected with proper template',
          );
        } else {
          logger.detail('✓ test/widget_test.dart created and processed');
        }
      }

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
    logger.info('📚 Documentation: ${MainConstants.packageDocumentation}');
    logger.info('💡 Need help? Visit our docs for guides and examples!');
    logger.info('');
  }
}
