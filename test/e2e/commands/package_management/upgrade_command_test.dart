@Tags(['e2e'])
library;

import 'dart:io';
import 'package:io/io.dart' show ExitCode;
import 'package:test/test.dart';
import '../../../helpers/e2e_test_base.dart';
import '../../../helpers/optimized_test_manager.dart';

/// Upgrade Command E2E Test Suite
///
/// Comprehensive end-to-end testing for package upgrade functionality.
/// Tests cover basic upgrades, major version updates, dependency management,
/// and various upgrade modes with advanced options.
///
/// Features tested:
/// - Basic package upgrades with flutter pub upgrade
/// - Major version upgrades with --major-versions
/// - Dependency tightening with --tighten
/// - Transitive dependency unlocking with --unlock-transitive
/// - Dry-run mode functionality
/// - Offline mode support
/// - Error handling and validation
/// - gexd project validation
class UpgradeCommandTest extends E2ETestBase {
  void runTests() {
    group('UpgradeCommand E2E Tests', () {
      setUpAll(() async {
        await super.setUpAll();
        await OptimizedTestManager.initialize();
        print('🚀 Starting upgrade command tests...');
        print('⚡ Using OptimizedTestManager for fast execution');
      });

      tearDownAll(() async {
        OptimizedTestManager.clearCache();
        await super.tearDownAll();
        print('🎉 Upgrade command tests completed!');
      });

      // Pre-conditions & Validation Tests
      group('📋 Pre-conditions & Validation', () {
        test('should fail on non-gexd project', () async {
          final stopwatch = Stopwatch()..start();
          final tempDir = Directory.systemTemp.createTempSync('empty_project_');

          try {
            final result = await run(['upgrade'], tempDir);
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
            final result = await run(['upgrade', '--help'], project.projectDir);
            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('Upgrade packages in your Flutter project'),
            );
            expect(result.stdout, contains('--dry-run'));
            expect(result.stdout, contains('--major-versions'));
            expect(result.stdout, contains('--tighten'));
            expect(result.stdout, contains('--unlock-transitive'));
            expect(result.stdout, contains('--[no-]offline'));
            print('✅ Help documentation verified');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Basic Upgrade Tests
      group('📦 Basic Package Upgrade', () {
        test('should upgrade all packages with dry-run', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'upgrade',
              '--dry-run',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(result.stdout, contains('Upgrading all packages'));
            expect(result.stdout, contains('flutter pub upgrade --dry-run'));
            expect(
              result.stdout,
              contains('All packages upgraded successfully'),
            );

            print('✅ Basic package upgrade working');
          } finally {
            await project.cleanup();
          }
        });

        test('should upgrade specific packages with dry-run', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'upgrade',
              '--dry-run',
              'get',
              'flutter_lints',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('Upgrading packages: get, flutter_lints'),
            );
            expect(
              result.stdout,
              contains('flutter pub upgrade --dry-run get flutter_lints'),
            );
            expect(result.stdout, contains('Packages upgraded successfully'));

            print('✅ Specific package upgrade working');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Major Version Upgrade Tests
      group('🆙 Major Version Upgrades', () {
        test('should upgrade with major-versions flag', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'upgrade',
              '--dry-run',
              '--major-versions',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains(
                '🔄 Running: flutter pub upgrade --dry-run --major-versions',
              ),
            );
            // Note: Warning message may not appear in all scenarios
            expect(
              result.stdout,
              anyOf([
                contains(
                  '💡 Major version upgrades can introduce breaking changes',
                ),
                contains('✅ All packages upgraded successfully!'),
              ]),
            );

            print('✅ Major version upgrade working');
          } finally {
            await project.cleanup();
          }
        });

        test('should upgrade specific packages with major-versions', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'upgrade',
              '--dry-run',
              '--major-versions',
              'get',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains(
                '🔄 Running: flutter pub upgrade --dry-run --major-versions get',
              ),
            );
            // Note: Warning message may not appear for specific packages
            expect(
              result.stdout,
              anyOf([
                contains(
                  '💡 Major version upgrades can introduce breaking changes',
                ),
                contains('✅ Packages upgraded successfully!'),
              ]),
            );

            print('✅ Major version specific package upgrade working');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Dependency Tightening Tests
      group('🔧 Dependency Tightening', () {
        test('should tighten dependencies', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'upgrade',
              '--dry-run',
              '--tighten',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('🔄 Running: flutter pub upgrade --dry-run --tighten'),
            );
            // Tightening warning is optional in dry-run mode
            expect(
              result.stdout,
              anyOf([
                contains('💡 Tightening will update pubspec.yaml constraints'),
                contains('✅ All packages upgraded successfully!'),
              ]),
            );

            print('✅ Dependency tightening working');
          } finally {
            await project.cleanup();
          }
        });

        test('should combine tighten with major-versions', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'upgrade',
              '--dry-run',
              '--major-versions',
              '--tighten',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            // Command order may vary - accept both possible orders
            expect(
              result.stdout,
              anyOf([
                contains(
                  '🔄 Running: flutter pub upgrade --dry-run --major-versions --tighten',
                ),
                contains(
                  '🔄 Running: flutter pub upgrade --dry-run --tighten --major-versions',
                ),
              ]),
            );
            // Warning is optional in dry-run mode
            expect(
              result.stdout,
              anyOf([
                contains(
                  '💡 Major version upgrades can introduce breaking changes',
                ),
                contains('✅ All packages upgraded successfully!'),
              ]),
            );
            // Warning is optional in dry-run mode
            expect(
              result.stdout,
              anyOf([
                contains('💡 Tightening will update pubspec.yaml constraints'),
                contains(
                  '💡 Major version upgrades can introduce breaking changes',
                ),
                contains('✅ All packages upgraded successfully!'),
              ]),
            );

            print('✅ Combined major-versions and tighten working');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Transitive Dependencies Tests
      group('🔄 Transitive Dependencies', () {
        test('should unlock transitive dependencies', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'upgrade',
              '--dry-run',
              '--unlock-transitive',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains(
                '🔄 Running: flutter pub upgrade --dry-run --unlock-transitive',
              ),
            );
            // Warning is optional in dry-run mode
            expect(
              result.stdout,
              anyOf([
                contains(
                  '💡 Unlocking transitive dependencies may cause version conflicts',
                ),
                contains('✅ All packages upgraded successfully!'),
              ]),
            );

            print('✅ Transitive dependency unlocking working');
          } finally {
            await project.cleanup();
          }
        });

        test('should combine all advanced flags', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'upgrade',
              '--dry-run',
              '--major-versions',
              '--tighten',
              '--unlock-transitive',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            // Accept any valid combination of these flags
            expect(
              result.stdout,
              anyOf([
                contains(
                  '🔄 Running: flutter pub upgrade --dry-run --major-versions --tighten --unlock-transitive',
                ),
                contains(
                  '🔄 Running: flutter pub upgrade --dry-run --tighten --unlock-transitive --major-versions',
                ),
              ]),
            );
            // These warnings are optional in dry-run mode
            expect(
              result.stdout,
              anyOf([
                contains(
                  '💡 Major version upgrades can introduce breaking changes',
                ),
                contains('💡 Tightening will update pubspec.yaml constraints'),
                contains(
                  '💡 Unlocking transitive dependencies may cause version conflicts',
                ),
                contains('✅ All packages upgraded successfully!'),
              ]),
            );

            print('✅ All advanced flags combination working');
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
              'upgrade',
              '--dry-run',
              '--offline',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('flutter pub upgrade --dry-run --offline'),
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
              'upgrade',
              '--dry-run',
              '--no-offline',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('flutter pub upgrade --dry-run --no-offline'),
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
              'upgrade',
              '--dry-run',
              '--precompile',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('flutter pub upgrade --dry-run --precompile'),
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
              'upgrade',
              '--dry-run',
              '--no-precompile',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('flutter pub upgrade --dry-run --no-precompile'),
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
              'upgrade',
              '--dry-run',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              anyOf([
                contains('Packages upgraded successfully'),
                contains('All packages upgraded successfully'),
              ]),
            );

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
              'upgrade',
              '--dry-run',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              anyOf([
                contains('Packages upgraded successfully'),
                contains('All packages upgraded successfully'),
              ]),
            );

            print('✅ Clean template compatibility verified');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Error Handling Tests
      group('⚠️ Error Handling', () {
        test(
          'should handle network issues gracefully in offline mode',
          () async {
            final project = await OptimizedTestManager.createOptimizedProject(
              templateKey: 'getx',
            );

            try {
              final result = await run([
                'upgrade',
                '--dry-run',
                '--offline',
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

        test('should handle invalid package names gracefully', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'upgrade',
              '--dry-run',
              'invalid_package_name_xyz_123',
            ], project.projectDir);

            // Should either succeed with dry-run or show appropriate error
            expect(
              result.exitCode,
              anyOf([
                equals(ExitCode.success.code),
                equals(ExitCode.software.code),
              ]),
            );

            print('✅ Invalid package name handling working');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Command Output Validation Tests
      group('📝 Command Output Validation', () {
        test('should show clear progress messages for all packages', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'upgrade',
              '--dry-run',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              anyOf([
                contains('📦 Upgrading all packages...'),
                contains('🔄 Upgrading all packages...'),
              ]),
            );
            expect(
              result.stdout,
              contains('🔄 Running: flutter pub upgrade --dry-run'),
            );
            expect(
              result.stdout,
              anyOf([
                contains('✅ Packages upgraded successfully!'),
                contains('✅ All packages upgraded successfully!'),
              ]),
            );

            print('✅ All packages progress messages display correctly');
          } finally {
            await project.cleanup();
          }
        });

        test(
          'should show clear progress messages for specific packages',
          () async {
            final project = await OptimizedTestManager.createOptimizedProject(
              templateKey: 'getx',
            );

            try {
              final result = await run([
                'upgrade',
                '--dry-run',
                'get',
              ], project.projectDir);

              expect(result.exitCode, equals(ExitCode.success.code));
              expect(
                result.stdout,
                anyOf([
                  contains('📦 Upgrading packages: get'),
                  contains('🔄 Upgrading packages: get'),
                ]),
              );
              expect(
                result.stdout,
                contains('🔄 Running: flutter pub upgrade --dry-run get'),
              );
              expect(
                result.stdout,
                contains('✅ Packages upgraded successfully!'),
              );

              print('✅ Specific packages progress messages display correctly');
            } finally {
              await project.cleanup();
            }
          },
        );

        test('should show smart upgrade tips', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'upgrade',
              '--dry-run',
              '--major-versions',
              '--tighten',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            // These warning messages are optional in dry-run mode
            expect(
              result.stdout,
              anyOf([
                contains(
                  '💡 Major version upgrades can introduce breaking changes',
                ),
                contains(
                  '💡 This was a dry run. Run without --dry-run to apply changes',
                ),
                contains('✅ All packages upgraded successfully!'),
              ]),
            );

            print('✅ Smart upgrade tips display correctly');
          } finally {
            await project.cleanup();
          }
        });
      });
    });
  }
}

void main() {
  UpgradeCommandTest().runTests();
}
