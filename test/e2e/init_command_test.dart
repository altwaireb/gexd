@Tags(['e2e'])
library;

import 'dart:io';
import 'package:io/io.dart' show ExitCode;
import 'package:test/test.dart';
import 'package:path/path.dart' as p;
import '../helpers/e2e_helpers.dart';

void main() {
  group('🔧 InitCommand E2E Tests', () {
    late Directory tempDir;

    setUpAll(() async {
      print('🧪 Setting up InitCommand E2E tests...');
      print(
        '📋 Testing with real Flutter project creation and modern CLI improvements',
      );
    });

    setUp(() async {
      tempDir = await E2EHelpers.createTemp();
    });

    tearDown(() async {
      await E2EHelpers.cleanupDir(tempDir);
    });

    tearDownAll(() async {
      print('🧹 InitCommand E2E tests completed successfully!');
    });

    test(
      'should initialize existing Flutter project with GetX template',
      () async {
        // Step 1: Create a basic Flutter project
        final projectName = 'test_getx_init';
        final projectPath = p.join(tempDir.path, projectName);

        final createResult = await Process.run('flutter', [
          'create',
          projectName,
          '--no-pub',
        ], workingDirectory: tempDir.path);

        expect(
          createResult.exitCode,
          equals(0),
          reason: 'Flutter create should succeed',
        );

        // Verify basic Flutter project was created
        expect(Directory(projectPath).existsSync(), isTrue);
        expect(File(p.join(projectPath, 'pubspec.yaml')).existsSync(), isTrue);
        expect(
          File(p.join(projectPath, 'lib', 'main.dart')).existsSync(),
          isTrue,
        );

        // Step 2: Initialize with gexd using optimized command runner
        final result = await E2EHelpers.runGexd([
          'init',
          '--template',
          'getx',
        ], workingDir: projectPath);

        // Verify init command succeeded
        expect(
          result.exitCode,
          equals(0),
          reason:
              'gexd init should succeed\nstderr: ${result.stderr}\nstdout: ${result.stdout}',
        );

        // Step 3: Verify GetX structure was added
        expect(
          E2EHelpers.validateGetXStructure(projectPath),
          isTrue,
          reason: 'Project should have GetX architecture structure after init',
        );

        // Verify GetX dependencies were added
        final pubspecPath = p.join(projectPath, 'pubspec.yaml');
        final pubspecContent = await File(pubspecPath).readAsString();
        expect(
          pubspecContent.contains('get:'),
          isTrue,
          reason: 'pubspec.yaml should contain GetX dependency after init',
        );

        // Verify main.dart was updated
        final mainPath = p.join(projectPath, 'lib', 'main.dart');
        final mainContent = await File(mainPath).readAsString();
        expect(
          mainContent.contains('GetMaterialApp'),
          isTrue,
          reason: 'main.dart should use GetMaterialApp after init',
        );
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );

    test(
      'should initialize existing Flutter project with Clean Architecture template',
      () async {
        // Step 1: Create a basic Flutter project
        final projectName = 'test_clean_init';
        final projectPath = p.join(tempDir.path, projectName);

        final createResult = await Process.run('flutter', [
          'create',
          projectName,
          '--no-pub',
        ], workingDirectory: tempDir.path);

        expect(
          createResult.exitCode,
          equals(0),
          reason: 'Flutter create should succeed',
        );

        // Step 2: Initialize with gexd clean template using optimized command runner
        final result = await E2EHelpers.runGexd([
          'init',
          '--template',
          'clean',
          '--full',
        ], workingDir: projectPath);

        // Verify init command succeeded
        expect(
          result.exitCode,
          equals(0),
          reason:
              'gexd init should succeed\nstderr: ${result.stderr}\nstdout: ${result.stdout}',
        );

        // Step 3: Verify Clean Architecture structure was added
        expect(
          E2EHelpers.validateCleanStructure(projectPath),
          isTrue,
          reason: 'Project should have Clean Architecture structure after init',
        );

        // Verify dependencies were added
        final pubspecPath = p.join(projectPath, 'pubspec.yaml');
        final pubspecContent = await File(pubspecPath).readAsString();
        expect(
          pubspecContent.contains('get:'),
          isTrue,
          reason: 'pubspec.yaml should contain GetX dependency after init',
        );
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );

    test('should handle invalid Flutter projects gracefully', () async {
      // Create empty directory (not a Flutter project)
      final emptyPath = p.join(tempDir.path, 'empty_project');
      await Directory(emptyPath).create();

      final result = await E2EHelpers.runGexd([
        'init',
        '--template',
        'getx',
      ], workingDir: emptyPath);

      // Should fail with appropriate error
      expect(
        result.exitCode,
        isNot(0),
        reason: 'gexd init should fail for non-Flutter projects',
      );

      // Should contain validation error message with new exception format
      final errorOutput = '${result.stderr}${result.stdout}'.toLowerCase();
      expect(
        errorOutput.contains('pubspec.yaml') ||
            errorOutput.contains('configprojectexception') ||
            errorOutput.contains('missing required configuration'),
        isTrue,
        reason: 'Should provide clear error message for non-Flutter project',
      );
    });

    test('should handle invalid templates gracefully in init', () async {
      // Step 1: Create a basic Flutter project
      final projectName = 'test_invalid_template_init';
      final projectPath = p.join(tempDir.path, projectName);

      final createResult = await Process.run('flutter', [
        'create',
        projectName,
        '--no-pub',
      ], workingDirectory: tempDir.path);

      expect(createResult.exitCode, equals(ExitCode.success.code));

      // Step 2: Try to init with invalid template
      final result = await E2EHelpers.runGexd([
        'init',
        '--template',
        'invalid_template',
      ], workingDir: projectPath);

      // Should fail with appropriate error
      expect(
        result.exitCode,
        isNot(0),
        reason: 'gexd init should reject invalid templates',
      );

      // Should contain template error message
      final errorOutput = '${result.stderr}${result.stdout}'.toLowerCase();
      expect(
        errorOutput.contains('template') ||
            errorOutput.contains('invalid') ||
            errorOutput.contains('not an allowed value'),
        isTrue,
        reason: 'Should provide clear error message for invalid template',
      );
    });

    test(
      'should handle performance efficiently with smart project detection',
      () async {
        // This test demonstrates the performance improvements from optimized CLI execution
        final stopwatch = Stopwatch()..start();

        // Step 1: Create a basic Flutter project
        final projectName = 'test_performance_init';
        final projectPath = p.join(tempDir.path, projectName);

        final createResult = await Process.run('flutter', [
          'create',
          projectName,
          '--no-pub',
        ], workingDirectory: tempDir.path);

        expect(createResult.exitCode, equals(ExitCode.success.code));

        // Step 2: Initialize with gexd using optimized execution
        final result = await E2EHelpers.runGexd([
          'init',
          '--template',
          'getx',
        ], workingDir: projectPath);

        stopwatch.stop();
        final duration = stopwatch.elapsedMilliseconds;

        // Verify success
        expect(result.exitCode, equals(ExitCode.success.code));

        // Verify structure
        expect(E2EHelpers.validateGetXStructure(projectPath), isTrue);

        // Performance expectation - should complete within reasonable time
        // Real environment: usually ~5-15 seconds, optimized should be similar
        expect(
          duration,
          lessThan(60000), // 60 seconds max
          reason: 'Init should complete within reasonable time: ${duration}ms',
        );

        print('⚡ Init performance: ${duration}ms');
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );

    test(
      'should verify project integrity after initialization',
      () async {
        // Create Flutter project and init with GetX
        final projectName = 'test_integrity_check';
        final projectPath = p.join(tempDir.path, projectName);

        final createResult = await Process.run('flutter', [
          'create',
          projectName,
          '--no-pub',
        ], workingDirectory: tempDir.path);

        expect(createResult.exitCode, equals(ExitCode.success.code));

        final result = await E2EHelpers.runGexd([
          'init',
          '--template',
          'getx',
          '--full',
        ], workingDir: projectPath);

        expect(result.exitCode, equals(ExitCode.success.code));

        // Verify comprehensive GetX structure
        final expectedFiles = [
          'lib/app/core/bindings/initial_binding.dart',
          'lib/app/core/themes/app_theme.dart',
          'lib/app/core/routes/app_routes.dart',
          'lib/app/core/routes/app_pages.dart',
          'lib/app/modules/home/controllers/home_controller.dart',
          'lib/app/modules/home/views/home_view.dart',
          'lib/app/modules/home/bindings/home_binding.dart',
        ];

        var foundFiles = 0;
        for (final file in expectedFiles) {
          if (File(p.join(projectPath, file)).existsSync()) {
            foundFiles++;
          }
        }

        // Should have most of the expected structure
        expect(
          foundFiles,
          greaterThanOrEqualTo(4),
          reason:
              'Should have substantial GetX structure ($foundFiles/${expectedFiles.length} files found)',
        );

        // Verify .gexd config was created
        expect(
          File(p.join(projectPath, '.gexd', 'config.yaml')).existsSync(),
          isTrue,
          reason: 'Should create .gexd/config.yaml configuration',
        );

        print(
          '✅ Project integrity verified: $foundFiles/${expectedFiles.length} files found',
        );
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );

    test(
      'should handle modern exception handling correctly',
      () async {
        // Test the new semantic exception system in init command
        final emptyPath = p.join(tempDir.path, 'semantic_exception_test');
        await Directory(emptyPath).create();

        final result = await E2EHelpers.runGexd([
          'init',
          '--template',
          'getx',
        ], workingDir: emptyPath);

        // Verify semantic exception handling
        expect(
          result.exitCode,
          equals(ExitCode.config.code),
        ); // ConfigProjectException exit code

        final errorOutput = result.stderr as String;

        // Should contain configuration error details
        expect(errorOutput.contains('Configuration error'), isTrue);
        expect(errorOutput.contains('pubspec.yaml'), isTrue);
        expect(errorOutput.contains('Missing required configuration'), isTrue);

        print('✅ Semantic exception handling verified');
        print('   Exception type: ConfigProjectException');
        print('   Error code: 78 (config)');
        print('   Message: Configuration error');
        print('   Field: pubspec.yaml');
      },
      timeout: const Timeout(Duration(minutes: 1)),
    );

    test(
      'should demonstrate optimized CLI execution performance',
      () async {
        // Test performance improvements from enhanced E2EHelpers
        final stopwatch = Stopwatch()..start();

        // Create a basic Flutter project
        final projectName = 'test_optimized_performance';
        final projectPath = p.join(tempDir.path, projectName);

        final createResult = await Process.run('flutter', [
          'create',
          projectName,
          '--no-pub',
        ], workingDirectory: tempDir.path);

        expect(createResult.exitCode, equals(ExitCode.success.code));

        final flutterCreateTime = stopwatch.elapsedMilliseconds;

        // Initialize with optimized gexd execution
        final result = await E2EHelpers.runGexd([
          'init',
          '--template',
          'getx',
        ], workingDir: projectPath);

        stopwatch.stop();
        final totalTime = stopwatch.elapsedMilliseconds;
        final initTime = totalTime - flutterCreateTime;

        expect(result.exitCode, equals(ExitCode.success.code));
        expect(E2EHelpers.validateGetXStructure(projectPath), isTrue);

        print('⚡ Optimized Init Performance:');
        print('   Flutter create: ${flutterCreateTime}ms');
        print('   Gexd init (optimized): ${initTime}ms');
        print('   Total: ${totalTime}ms');
        print('🚀 Using enhanced CLI execution with dynamic path discovery');

        // Should complete within reasonable time
        expect(
          totalTime,
          lessThan(120000), // 2 minutes
          reason: 'Optimized init should complete efficiently: ${totalTime}ms',
        );
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );
  });
}
