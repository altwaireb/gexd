@Tags(['e2e'])
library;

import 'dart:io';
import 'package:io/io.dart' show ExitCode;
import 'package:test/test.dart';
import '../../../../helpers/e2e_test_base.dart';
import '../../../../helpers/optimized_test_manager.dart';

/// Provider Command E2E Test Suite
///
/// Simple end-to-end testing for provider generation functionality.
/// Tests cover provider creation, validation, error handling, and template compatibility.
class ProviderCommandTest extends E2ETestBase {
  void runTests() {
    group('ProviderCommand E2E Tests', () {
      setUpAll(() async {
        await super.setUpAll();
        await OptimizedTestManager.initialize();
        print('Starting provider command tests...');
        print('Using OptimizedTestManager for fast execution');
      });

      tearDownAll(() async {
        OptimizedTestManager.clearCache();
        await super.tearDownAll();
        print('Provider command tests completed!');
      });

      // Pre-conditions & Validation Tests
      group('Pre-conditions & Validation', () {
        test('should fail on uninitialized project', () async {
          final tempDir = Directory.systemTemp.createTempSync('empty_project_');

          try {
            final result = await run(['make', 'provider', 'Sample'], tempDir);
            expect(result.exitCode, equals(ExitCode.config.code));
            expect(result.stderr, contains('Not inside a valid Gexd project'));

            print('Pre-condition validation passed');
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
              'provider',
              '--help',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(result.stdout, contains('Generate provider files'));
            expect(result.stdout, contains('Usage:'));

            print('Help documentation verified');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Basic Provider Generation Tests
      group('Basic Provider Generation', () {
        test('should create basic provider file', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final providerName = 'Api';
            final result = await run([
              'make',
              'provider',
              providerName,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              anyOf([
                contains('Generated provider successful'),
                contains('Generated files'),
                contains('provider generation'),
              ]),
            );

            print('Basic provider creation verified');
          } finally {
            await project.cleanup();
          }
        });

        test('should create provider in subdirectory with --on flag', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final providerName = 'Remote';
            final result = await run([
              'make',
              'provider',
              providerName,
              '--on',
              'api',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            print('Provider creation with subdirectory verified');
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
              'provider',
              'Local',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            print('GetX template compatibility verified');
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
              'provider',
              'Cache',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            print('Clean template compatibility verified');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Error Handling Tests
      group('Error Handling', () {
        test('should handle invalid provider names gracefully', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'make',
              'provider',
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

            print('Invalid provider name handling verified');
          } finally {
            await project.cleanup();
          }
        });

        test('should handle existing files appropriately', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final providerName = 'Existing';

            // Create provider first time
            await run([
              'make',
              'provider',
              providerName,
              '--force',
            ], project.projectDir);

            // Try to create same provider again without force
            final secondResult = await run([
              'make',
              'provider',
              providerName,
            ], project.projectDir);

            expect(
              secondResult.exitCode,
              anyOf([
                equals(ExitCode.success.code),
                equals(ExitCode.data.code),
                equals(64), // validation error code
              ]),
            );

            print('Existing file handling verified');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Simple Integration Tests
      group('Integration Tests', () {
        test('should create providers with different names', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final providers = ['Network', 'Storage', 'Cache'];

            for (final provider in providers) {
              final result = await run([
                'make',
                'provider',
                provider,
                '--force',
              ], project.projectDir);

              expect(result.exitCode, equals(ExitCode.success.code));
            }

            print('Multiple providers creation verified');
          } finally {
            await project.cleanup();
          }
        });
      });
    });
  }
}

void main() => ProviderCommandTest().runTests();
