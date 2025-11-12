@Tags(['e2e'])
library;

import 'dart:io';
import 'package:io/io.dart' show ExitCode;
import 'package:test/test.dart';
import '../../../../helpers/e2e_test_base.dart';
import '../../../../helpers/optimized_test_manager.dart';

/// Repository Command E2E Test Suite
///
/// Simple end-to-end testing for repository generation functionality.
class RepositoryCommandTest extends E2ETestBase {
  void runTests() {
    group('RepositoryCommand E2E Tests', () {
      setUpAll(() async {
        await super.setUpAll();
        await OptimizedTestManager.initialize();
        print('Starting repository command tests...');
        print('Using OptimizedTestManager for fast execution');
      });

      tearDownAll(() async {
        OptimizedTestManager.clearCache();
        await super.tearDownAll();
        print('Repository command tests completed!');
      });

      // Pre-conditions & Validation Tests
      group('Pre-conditions & Validation', () {
        test('should fail on uninitialized project', () async {
          final tempDir = Directory.systemTemp.createTempSync('empty_project_');

          try {
            final result = await run(['make', 'repository', 'Sample'], tempDir);
            expect(result.exitCode, equals(ExitCode.config.code));
            expect(result.stderr, contains('Not inside a valid Gexd project'));

            print('⚡ Pre-condition validation passed');
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
              'repository',
              '--help',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(result.stdout, contains('Generate repository files'));

            print('📖 Help documentation verified');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Basic Repository Generation Tests
      group('Basic Repository Generation', () {
        test('should create basic repository file', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'make',
              'repository',
              'Auth',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            print('✅ Basic repository creation verified');
          } finally {
            await project.cleanup();
          }
        });

        test('should create repository in subdirectory', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'make',
              'repository',
              'User',
              '--on',
              'data',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            print('✅ Repository creation with subdirectory verified');
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
            final result = await run([
              'make',
              'repository',
              'Product',
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
            final result = await run([
              'make',
              'repository',
              'Order',
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
        test('should handle invalid repository names gracefully', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'make',
              'repository',
              '123Invalid',
            ], project.projectDir);

            expect(
              result.exitCode,
              anyOf([
                equals(ExitCode.usage.code),
                equals(ExitCode.data.code),
                equals(64), // validation error
                equals(ExitCode.success.code), // if name is sanitized
              ]),
            );

            print('Invalid repository name handling verified');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Simple Integration Tests
      group('Integration Tests', () {
        test('should create multiple repositories successfully', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final repositories = ['Local', 'Remote', 'Cache'];

            for (final repo in repositories) {
              final result = await run([
                'make',
                'repository',
                repo,
                '--force',
              ], project.projectDir);

              expect(result.exitCode, equals(ExitCode.success.code));
            }

            print('Multiple repositories creation verified');
          } finally {
            await project.cleanup();
          }
        });
      });
    });
  }
}

void main() => RepositoryCommandTest().runTests();
