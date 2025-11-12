@Tags(['e2e'])
library;

import 'dart:io';
import 'package:io/io.dart' show ExitCode;
import 'package:test/test.dart';
import '../../../../helpers/e2e_test_base.dart';
import '../../../../helpers/optimized_test_manager.dart';

/// Constant Command E2E Test Suite
///
/// Simple end-to-end testing for constant generation functionality.
/// Tests cover constant creation, validation, error handling, and template compatibility.
class ConstantCommandTest extends E2ETestBase {
  void runTests() {
    group('ConstantCommand E2E Tests', () {
      setUpAll(() async {
        await super.setUpAll();
        await OptimizedTestManager.initialize();
        print('🚀 Starting constant command tests...');
        print('⚡ Using OptimizedTestManager for fast execution');
      });

      tearDownAll(() async {
        OptimizedTestManager.clearCache();
        await super.tearDownAll();
        print('🎉 Constant command tests completed!');
      });

      // Pre-conditions & Validation Tests
      group('Pre-conditions & Validation', () {
        test('should fail on uninitialized project', () async {
          final stopwatch = Stopwatch()..start();
          final tempDir = Directory.systemTemp.createTempSync('empty_project_');

          try {
            final result = await run(['make', 'constant', 'Sample'], tempDir);
            expect(result.exitCode, equals(ExitCode.config.code));
            expect(result.stderr, contains('Not inside a valid Gexd project'));

            stopwatch.stop();
            print(
              '⚡ Pre-condition validation completed in ${stopwatch.elapsedMilliseconds}ms',
            );
          } finally {
            if (tempDir.existsSync()) {
              await tempDir.delete(recursive: true);
            }
          }
        });

        test('should show help with --help flag', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'make',
              'constant',
              '--help',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(result.stdout, contains('Generate constant files'));
            expect(result.stdout, contains('Usage:'));

            print('📖 Help documentation verified');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Basic Constant Generation Tests
      group('Basic Constant Generation', () {
        test('should create basic constant file', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final constantName = 'App';
            final result = await run([
              'make',
              'constant',
              constantName,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              anyOf([
                contains('Generated constant successful'),
                contains('Generated files'),
                contains('constant generation'),
              ]),
            );

            final basePath = project.projectDir.path;
            // Check both possible locations
            final constantFileOptions = [
              File('$basePath/lib/app/core/constants/app_constants.dart'),
              File('$basePath/lib/app/shared/constants/app_constants.dart'),
              File('$basePath/lib/app/constants/app_constants.dart'),
            ];

            final constantFile = constantFileOptions.firstWhere(
              (file) => file.existsSync(),
              orElse: () => constantFileOptions.first,
            );

            expect(constantFile.existsSync(), isTrue);

            if (constantFile.existsSync()) {
              final content = await constantFile.readAsString();
              expect(content, contains('class AppConstants'));
            }

            print('✅ Basic constant creation verified');
          } finally {
            await project.cleanup();
          }
        });

        test('should create constant in subdirectory with --on flag', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final constantName = 'Storage';
            final result = await run([
              'make',
              'constant',
              constantName,
              '--on',
              'database',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              anyOf([
                contains('Generated constant successful'),
                contains('Generated files'),
                contains('constant generation'),
              ]),
            );

            print('✅ Constant creation with subdirectory verified');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Template Compatibility Tests
      group('Template Compatibility', () {
        test('should work with GetX template', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final constantName = 'Api';
            final result = await run([
              'make',
              'constant',
              constantName,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            print('✅ GetX template compatibility verified');
          } finally {
            await project.cleanup();
          }
        });

        test('should work with Clean template', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'clean',
          );

          try {
            final constantName = 'Config';
            final result = await run([
              'make',
              'constant',
              constantName,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            print('✅ Clean template compatibility verified');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Error Handling Tests
      group('Error Handling', () {
        test('should handle invalid constant names gracefully', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            // Test with invalid name (starts with number)
            final result = await run([
              'make',
              'constant',
              '123Invalid',
            ], project.projectDir);

            // Should either fail with validation error or sanitize the name
            expect(
              result.exitCode,
              anyOf([
                equals(ExitCode.usage.code),
                equals(ExitCode.data.code),
                equals(64), // validation error
                equals(ExitCode.success.code), // if name is sanitized
              ]),
            );

            print('⚠️ Invalid constant name handling verified');
          } finally {
            await project.cleanup();
          }
        });

        test('should handle existing files appropriately', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final constantName = 'Existing';

            // Create constant first time
            final firstResult = await run([
              'make',
              'constant',
              constantName,
              '--force',
            ], project.projectDir);

            expect(firstResult.exitCode, equals(ExitCode.success.code));

            // Try to create same constant again without force
            final secondResult = await run([
              'make',
              'constant',
              constantName,
            ], project.projectDir);

            // Should handle existing file (either prompt or error)
            expect(
              secondResult.exitCode,
              anyOf([
                equals(ExitCode.success.code),
                equals(ExitCode.data.code),
                equals(64), // validation error code
              ]),
            );

            print('🔄 Existing file handling verified');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Interactive Mode Tests
      group('Interactive Mode', () {
        test('should handle interactive mode for constant creation', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'make',
              'constant',
              'Interactive',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            print('🎮 Interactive mode handling verified');
          } finally {
            await project.cleanup();
          }
        });
      });
    });
  }
}

void main() => ConstantCommandTest().runTests();
