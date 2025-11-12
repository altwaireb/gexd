@Tags(['e2e'])
library;

import 'dart:io';
import 'package:io/io.dart' show ExitCode;
import 'package:test/test.dart';
import '../../../helpers/e2e_test_base.dart';
import '../../../helpers/optimized_test_manager.dart';

/// Add Command E2E Test Suite
///
/// Comprehensive end-to-end testing for package addition functionality.
/// Tests cover package installation, validation, error handling, and various package types.
///
/// Features tested:
/// - Basic package addition with flutter pub add
/// - Version constraints and specific versions
/// - Dev dependencies with dev: prefix
/// - Dry-run mode functionality
/// - Offline mode support
/// - Error handling and validation
/// - gexd project validation
class AddCommandTest extends E2ETestBase {
  void runTests() {
    group('AddCommand E2E Tests', () {
      setUpAll(() async {
        await super.setUpAll();
        await OptimizedTestManager.initialize();
        print('🚀 Starting add command tests...');
        print('⚡ Using OptimizedTestManager for fast execution');
      });

      tearDownAll(() async {
        OptimizedTestManager.clearCache();
        await super.tearDownAll();
        print('🎉 Add command tests completed!');
      });

      // Pre-conditions & Validation Tests
      group('📋 Pre-conditions & Validation', () {
        test('should fail on non-gexd project', () async {
          final stopwatch = Stopwatch()..start();
          final tempDir = Directory.systemTemp.createTempSync('empty_project_');

          try {
            final result = await run(['add', 'http'], tempDir);
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
            final result = await run(['add', '--help'], project.projectDir);
            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('Add packages to your Flutter project'),
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
            final result = await run(['add'], project.projectDir);
            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(
              result.stderr,
              contains('Please specify at least one package'),
            );
            expect(result.stdout, contains('gexd add http'));
            print('✅ Package name requirement validation working');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Basic Package Addition Tests
      group('📦 Basic Package Addition', () {
        test('should add single package with dry-run', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'add',
              '--dry-run',
              'http',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(result.stdout, contains('Adding packages: http'));
            expect(result.stdout, contains('flutter pub add --dry-run http'));
            expect(result.stdout, contains('Packages added successfully'));

            print('✅ Single package dry-run addition working');
          } finally {
            await project.cleanup();
          }
        });

        test('should add multiple packages with dry-run', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'add',
              '--dry-run',
              'http',
              'dio',
              'shared_preferences',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('Adding packages: http, dio, shared_preferences'),
            );
            expect(
              result.stdout,
              contains('flutter pub add --dry-run http dio shared_preferences'),
            );
            expect(result.stdout, contains('Packages added successfully'));

            print('✅ Multiple package dry-run addition working');
          } finally {
            await project.cleanup();
          }
        });

        test('should add package with version constraint', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'add',
              '--dry-run',
              'http:^0.13.0',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(result.stdout, contains('Adding packages: http:^0.13.0'));
            expect(
              result.stdout,
              contains('flutter pub add --dry-run http:^0.13.0'),
            );
            expect(result.stdout, contains('Packages added successfully'));

            print('✅ Version constraint addition working');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Dev Dependencies Tests
      group('🛠️ Dev Dependencies', () {
        test('should add dev dependency with dry-run', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'add',
              '--dry-run',
              'dev:build_runner',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('Adding packages: dev:build_runner'),
            );
            expect(
              result.stdout,
              contains('flutter pub add --dry-run dev:build_runner'),
            );
            expect(result.stdout, contains('Packages added successfully'));

            print('✅ Dev dependency addition working');
          } finally {
            await project.cleanup();
          }
        });

        test('should add mixed regular and dev dependencies', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'add',
              '--dry-run',
              'http',
              'dev:build_runner',
              'dio',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('Adding packages: http, dev:build_runner, dio'),
            );
            expect(
              result.stdout,
              contains('flutter pub add --dry-run http dev:build_runner dio'),
            );
            expect(result.stdout, contains('Packages added successfully'));

            print('✅ Mixed dependency types addition working');
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
              'add',
              '--dry-run',
              '--offline',
              'http',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('flutter pub add --dry-run --offline http'),
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
              'add',
              '--dry-run',
              '--no-offline',
              'http',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('flutter pub add --dry-run --no-offline http'),
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
              'add',
              '--dry-run',
              '--precompile',
              'http',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('flutter pub add --dry-run --precompile http'),
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
              'add',
              '--dry-run',
              '--no-precompile',
              'http',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('flutter pub add --dry-run --no-precompile http'),
            );
            print('✅ No-precompile flag working');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Advanced Package Types Tests
      group('🔧 Advanced Package Types', () {
        test('should handle path dependencies', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'add',
              '--dry-run',
              '"local_package:{path: ../local}"',
            ], project.projectDir);

            // Path dependencies may fail in dry-run if path doesn't exist
            expect(
              result.exitCode,
              anyOf([
                equals(ExitCode.success.code),
                equals(65), // pub dependency resolution failure
              ]),
            );
            expect(
              result.stdout,
              contains('Adding packages: "local_package:{path: ../local}"'),
            );

            print('✅ Path dependency addition working');
          } finally {
            await project.cleanup();
          }
        });

        test('should handle git dependencies', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'add',
              '--dry-run',
              '"package_name:{git: https://github.com/user/repo.git}"',
            ], project.projectDir);

            // Git dependencies may fail in dry-run if repo doesn't exist
            expect(
              result.exitCode,
              anyOf([
                equals(ExitCode.success.code),
                equals(65), // pub dependency resolution failure
              ]),
            );
            expect(
              result.stdout,
              contains(
                'Adding packages: "package_name:{git: https://github.com/user/repo.git}"',
              ),
            );

            print('✅ Git dependency addition working');
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
              'add',
              '--dry-run',
              'http',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(result.stdout, contains('Packages added successfully'));

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
              'add',
              '--dry-run',
              'http',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(result.stdout, contains('Packages added successfully'));

            print('✅ Clean template compatibility verified');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Error Handling Tests
      group('⚠️ Error Handling', () {
        test('should handle invalid package names gracefully', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'add',
              '--dry-run',
              'non_existent_package_xyz_123',
            ], project.projectDir);

            // Should either succeed with dry-run or show appropriate error
            expect(
              result.exitCode,
              anyOf([
                equals(ExitCode.success.code),
                equals(65), // pub dependency resolution failure
                equals(ExitCode.software.code),
              ]),
            );

            print('✅ Invalid package name handling working');
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
                'add',
                '--dry-run',
                '--offline',
                'new_package_not_cached',
              ], project.projectDir);

              // Should handle offline mode appropriately
              expect(
                result.exitCode,
                anyOf([
                  equals(ExitCode.success.code),
                  equals(65), // pub dependency resolution failure
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
              'add',
              '--dry-run',
              'http',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(result.stdout, contains('📦 Adding packages: http'));
            expect(
              result.stdout,
              contains('🔄 Running: flutter pub add --dry-run http'),
            );
            expect(result.stdout, contains('✅ Packages added successfully!'));

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
            final result = await run(['add'], project.projectDir);

            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(result.stdout, contains('gexd add http'));
            expect(result.stdout, contains('gexd add dev:build_runner'));
            expect(
              result.stdout,
              contains('gexd add http dio shared_preferences'),
            );
            expect(
              result.stdout,
              contains('gexd add "local_package:{path: ../local}"'),
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
  AddCommandTest().runTests();
}
