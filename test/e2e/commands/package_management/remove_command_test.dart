@Tags(['e2e'])
library;

import 'dart:io';
import 'package:io/io.dart' show ExitCode;
import 'package:test/test.dart';
import '../../../helpers/e2e_test_base.dart';
import '../../../helpers/optimized_test_manager.dart';

/// Remove Command E2E Test Suite
///
/// Comprehensive end-to-end testing for package removal functionality.
/// Tests cover package removal, validation, error handling, and various package types.
///
/// Features tested:
/// - Basic package removal with flutter pub remove
/// - Multiple package removal
/// - Dry-run mode functionality
/// - Offline mode support
/// - Error handling and validation
/// - gexd project validation
class RemoveCommandTest extends E2ETestBase {
  void runTests() {
    group('RemoveCommand E2E Tests', () {
      setUpAll(() async {
        await super.setUpAll();
        await OptimizedTestManager.initialize();
        print('🚀 Starting remove command tests...');
        print('⚡ Using OptimizedTestManager for fast execution');
      });

      tearDownAll(() async {
        OptimizedTestManager.clearCache();
        await super.tearDownAll();
        print('🎉 Remove command tests completed!');
      });

      // Pre-conditions & Validation Tests
      group('📋 Pre-conditions & Validation', () {
        test('should fail on non-gexd project', () async {
          final stopwatch = Stopwatch()..start();
          final tempDir = Directory.systemTemp.createTempSync('empty_project_');

          try {
            final result = await run(['remove', 'http'], tempDir);
            expect(result.exitCode, equals(ExitCode.config.code));
            expect(result.stderr, contains('Not inside a valid gexd project'));

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
            final result = await run(['remove', '--help'], project.projectDir);
            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('Remove packages from your Flutter project'),
            );
            expect(result.stdout, contains('--dry-run'));
            expect(result.stdout, contains('--[no-]offline'));
            expect(result.stdout, contains('--[no-]precompile'));
            print('✅ Help documentation verified');
          } finally {
            await project.cleanup();
          }
        });

        test('should require at least one package name', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );
          try {
            final result = await run(['remove'], project.projectDir);
            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(
              result.stderr,
              contains('Please specify at least one package'),
            );
            expect(result.stdout, contains('gexd remove http'));
            print('✅ Package name requirement validation working');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Basic Package Removal Tests
      group('📦 Basic Package Removal', () {
        test('should remove single package with dry-run', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'remove',
              '--dry-run',
              'get',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(result.stdout, contains('Removing packages: get'));
            expect(result.stdout, contains('flutter pub remove --dry-run get'));
            expect(result.stdout, contains('Packages removed successfully'));

            print('✅ Single package dry-run removal working');
          } finally {
            await project.cleanup();
          }
        });

        test('should remove multiple packages with dry-run', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'remove',
              '--dry-run',
              'get',
              'flutter_lints',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('Removing packages: get, flutter_lints'),
            );
            expect(
              result.stdout,
              contains('flutter pub remove --dry-run get flutter_lints'),
            );
            expect(result.stdout, contains('Packages removed successfully'));

            print('✅ Multiple package dry-run removal working');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Override Dependencies Tests
      group('🔧 Override Dependencies', () {
        test('should remove override dependency with dry-run', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'remove',
              '--dry-run',
              'override:some_package',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('Removing packages: override:some_package'),
            );
            expect(
              result.stdout,
              contains('flutter pub remove --dry-run override:some_package'),
            );

            print('✅ Override dependency removal working');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Flags and Options Tests
      group('🎛️ Flags and Options', () {
        test('should support offline flag', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'remove',
              '--dry-run',
              '--offline',
              'get',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('flutter pub remove --dry-run --offline get'),
            );
            print('✅ Offline flag working');
          } finally {
            await project.cleanup();
          }
        });

        test('should support no-offline flag', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'remove',
              '--dry-run',
              '--no-offline',
              'get',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('flutter pub remove --dry-run --no-offline get'),
            );
            print('✅ No-offline flag working');
          } finally {
            await project.cleanup();
          }
        });

        test('should support precompile flag', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'remove',
              '--dry-run',
              '--precompile',
              'get',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('flutter pub remove --dry-run --precompile get'),
            );
            print('✅ Precompile flag working');
          } finally {
            await project.cleanup();
          }
        });

        test('should support no-precompile flag', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'remove',
              '--dry-run',
              '--no-precompile',
              'get',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('flutter pub remove --dry-run --no-precompile get'),
            );
            print('✅ No-precompile flag working');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Template Compatibility Tests
      group('🏗️ Template Compatibility', () {
        test('should work with GetX template', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'remove',
              '--dry-run',
              'get',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(result.stdout, contains('Packages removed successfully'));

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
              'remove',
              '--dry-run',
              'get',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(result.stdout, contains('Packages removed successfully'));

            print('✅ Clean template compatibility verified');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Error Handling Tests
      group('⚠️ Error Handling', () {
        test('should handle non-existent package removal gracefully', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'remove',
              '--dry-run',
              'non_existent_package_xyz_123',
            ], project.projectDir);

            // Should either succeed with dry-run or show appropriate error
            expect(
              result.exitCode,
              anyOf([
                equals(ExitCode.success.code),
                equals(ExitCode.software.code),
              ]),
            );

            print('✅ Non-existent package removal handling working');
          } finally {
            await project.cleanup();
          }
        });

        test(
          'should handle network issues gracefully in offline mode',
          () async {
            final project = await OptimizedTestManager.createOptimizedProject(
              templateKey: 'getx',
            );

            try {
              final result = await run([
                'remove',
                '--dry-run',
                '--offline',
                'some_package',
              ], project.projectDir);

              // Should handle offline mode appropriately
              expect(
                result.exitCode,
                anyOf([
                  equals(ExitCode.success.code),
                  equals(ExitCode.software.code),
                ]),
              );

              print('✅ Offline mode error handling working');
            } finally {
              await project.cleanup();
            }
          },
        );
      });

      // Command Output Validation Tests
      group('📝 Command Output Validation', () {
        test('should show clear progress messages', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'remove',
              '--dry-run',
              'get',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(result.stdout, contains('📦 Removing packages: get'));
            expect(
              result.stdout,
              contains('🔄 Running: flutter pub remove --dry-run get'),
            );
            expect(result.stdout, contains('✅ Packages removed successfully!'));

            print('✅ Progress messages display correctly');
          } finally {
            await project.cleanup();
          }
        });

        test('should show usage examples on error', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run(['remove'], project.projectDir);

            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(result.stdout, contains('gexd remove http'));
            expect(
              result.stdout,
              contains('gexd remove http dio shared_preferences'),
            );
            expect(
              result.stdout,
              contains('gexd remove override:package_name'),
            );

            print('✅ Usage examples display correctly');
          } finally {
            await project.cleanup();
          }
        });
      });
    });
  }
}

void main() {
  RemoveCommandTest().runTests();
}
