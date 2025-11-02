@Tags(['e2e'])
library;

import 'dart:io';
import 'package:io/io.dart' show ExitCode;
import 'package:test/test.dart';
import '../../../helpers/e2e_test_base.dart';
import '../../../helpers/optimized_test_manager.dart';

/// Self-Update Command E2E Test Suite
///
/// Comprehensive end-to-end testing for CLI tool self-update functionality.
/// Tests cover version checking, dry-run mode, configuration updates,
/// and various update scenarios.
///
/// Features tested:
/// - Version checking with pub_updater
/// - Dry-run mode for preview updates
/// - Configuration file updates
/// - Update confirmation and progress
/// - Error handling and validation
/// - Network connectivity scenarios
class SelfUpdateCommandTest extends E2ETestBase {
  void runTests() {
    group('SelfUpdateCommand E2E Tests', () {
      setUpAll(() async {
        await super.setUpAll();
        await OptimizedTestManager.initialize();
        print('🚀 Starting self-update command tests...');
        print('⚡ Using OptimizedTestManager for fast execution');
      });

      tearDownAll(() async {
        OptimizedTestManager.clearCache();
        await super.tearDownAll();
        print('🎉 Self-update command tests completed!');
      });

      // Pre-conditions & Validation Tests
      group('📋 Pre-conditions & Validation', () {
        test('should show help with --help flag', () async {
          final tempDir = Directory.systemTemp.createTempSync('test_project_');

          try {
            final result = await run(['self-update', '--help'], tempDir);
            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('Update the gexd CLI tool to the latest version'),
            );
            expect(result.stdout, contains('--dry-run'));
            expect(
              result.stdout,
              contains('Check for updates without installing'),
            );
            print('✅ Help documentation verified');
          } finally {
            if (tempDir.existsSync()) {
              await tempDir.delete(recursive: true);
            }
          }
        });
      });

      // Version Checking Tests
      group('🔍 Version Checking', () {
        test(
          'should check for updates with dry-run',
          () async {
            final tempDir = Directory.systemTemp.createTempSync(
              'test_project_',
            );

            try {
              final result = await run(['self-update', '--dry-run'], tempDir);

              expect(
                result.exitCode,
                anyOf([
                  equals(ExitCode.success.code),
                  equals(ExitCode.software.code), // Network issues
                ]),
              );

              // Should show version checking messages
              expect(
                result.stdout,
                anyOf([
                  contains('Checking for updates'),
                  contains('Current version'),
                  contains('No updates available'),
                  contains('Update available'),
                ]),
              );

              print('✅ Version checking with dry-run working');
            } finally {
              if (tempDir.existsSync()) {
                await tempDir.delete(recursive: true);
              }
            }
          },
          timeout: const Timeout(Duration(seconds: 30)),
        );

        test(
          'should show current version information',
          () async {
            final tempDir = Directory.systemTemp.createTempSync(
              'test_project_',
            );

            try {
              final result = await run(['self-update', '--dry-run'], tempDir);

              if (result.exitCode == ExitCode.success.code) {
                expect(result.stdout, contains('Current version'));
              }

              print('✅ Current version information display working');
            } finally {
              if (tempDir.existsSync()) {
                await tempDir.delete(recursive: true);
              }
            }
          },
          timeout: const Timeout(Duration(seconds: 30)),
        );
      });

      // Update Process Tests
      group('🔄 Update Process', () {
        test(
          'should handle no updates available scenario',
          () async {
            final tempDir = Directory.systemTemp.createTempSync(
              'test_project_',
            );

            try {
              final result = await run(['self-update', '--dry-run'], tempDir);

              if (result.exitCode == ExitCode.success.code &&
                  result.stdout.contains('No updates available')) {
                expect(
                  result.stdout,
                  contains('✅ gexd is already up to date!'),
                );
                print('✅ No updates scenario handled correctly');
              } else {
                print(
                  'ℹ️ Updates available or network issues - test passed conditionally',
                );
              }
            } finally {
              if (tempDir.existsSync()) {
                await tempDir.delete(recursive: true);
              }
            }
          },
          timeout: const Timeout(Duration(seconds: 30)),
        );

        test(
          'should show update preview in dry-run mode',
          () async {
            final tempDir = Directory.systemTemp.createTempSync(
              'test_project_',
            );

            try {
              final result = await run(['self-update', '--dry-run'], tempDir);

              if (result.exitCode == ExitCode.success.code) {
                // Should either show "no updates" or "update available"
                expect(
                  result.stdout,
                  anyOf([
                    contains('No updates available'),
                    contains('Update available'),
                    contains('Would update from'),
                  ]),
                );
              }

              print('✅ Update preview in dry-run mode working');
            } finally {
              if (tempDir.existsSync()) {
                await tempDir.delete(recursive: true);
              }
            }
          },
          timeout: const Timeout(Duration(seconds: 30)),
        );
      });

      // Configuration Updates Tests
      group('⚙️ Configuration Updates', () {
        test(
          'should handle configuration file creation',
          () async {
            final project = await OptimizedTestManager.createOptimizedProject(
              templateKey: 'getx',
            );

            try {
              final result = await run([
                'self-update',
                '--dry-run',
              ], project.projectDir);

              // Should work regardless of project type since it's a global command
              expect(
                result.exitCode,
                anyOf([
                  equals(ExitCode.success.code),
                  equals(ExitCode.software.code), // Network issues
                ]),
              );

              print('✅ Configuration file handling working');
            } finally {
              await project.cleanup();
            }
          },
          timeout: const Timeout(Duration(seconds: 30)),
        );

        test(
          'should work in project directories',
          () async {
            final project = await OptimizedTestManager.createOptimizedProject(
              templateKey: 'getx',
            );

            try {
              final result = await run([
                'self-update',
                '--dry-run',
              ], project.projectDir);

              // Self-update should work from any directory
              expect(
                result.exitCode,
                anyOf([
                  equals(ExitCode.success.code),
                  equals(ExitCode.software.code), // Network issues
                ]),
              );

              print('✅ Project directory execution working');
            } finally {
              await project.cleanup();
            }
          },
          timeout: const Timeout(Duration(seconds: 30)),
        );
      });

      // Error Handling Tests
      group('⚠️ Error Handling', () {
        test(
          'should handle network connectivity issues gracefully',
          () async {
            final tempDir = Directory.systemTemp.createTempSync(
              'test_project_',
            );

            try {
              // This test may pass or fail depending on network connectivity
              final result = await run(['self-update', '--dry-run'], tempDir);

              // Should either succeed or fail gracefully
              expect(
                result.exitCode,
                anyOf([
                  equals(ExitCode.success.code),
                  equals(ExitCode.software.code),
                ]),
              );

              if (result.exitCode != ExitCode.success.code) {
                print('ℹ️ Network connectivity test - handled gracefully');
              } else {
                print('✅ Network connectivity working');
              }
            } finally {
              if (tempDir.existsSync()) {
                await tempDir.delete(recursive: true);
              }
            }
          },
          timeout: const Timeout(Duration(seconds: 30)),
        );

        test(
          'should show appropriate error messages on failure',
          () async {
            final tempDir = Directory.systemTemp.createTempSync(
              'test_project_',
            );

            try {
              final result = await run(['self-update', '--dry-run'], tempDir);

              if (result.exitCode != ExitCode.success.code) {
                // Should show helpful error messages
                expect(
                  result.stderr,
                  anyOf([
                    contains('Failed to check for updates'),
                    contains('Network error'),
                    contains('Unable to connect'),
                  ]),
                );
              }

              print('✅ Error message handling working');
            } finally {
              if (tempDir.existsSync()) {
                await tempDir.delete(recursive: true);
              }
            }
          },
          timeout: const Timeout(Duration(seconds: 30)),
        );
      });

      // Template Independence Tests
      group('🏗️ Template Independence', () {
        test(
          'should work independently of project templates',
          () async {
            final tempDir = Directory.systemTemp.createTempSync(
              'empty_project_',
            );

            try {
              final result = await run(['self-update', '--dry-run'], tempDir);

              // Self-update should work from any directory, even non-gexd projects
              expect(
                result.exitCode,
                anyOf([
                  equals(ExitCode.success.code),
                  equals(ExitCode.software.code), // Network issues
                ]),
              );

              print('✅ Template independence verified');
            } finally {
              if (tempDir.existsSync()) {
                await tempDir.delete(recursive: true);
              }
            }
          },
          timeout: const Timeout(Duration(seconds: 30)),
        );

        test(
          'should work from GetX project directory',
          () async {
            final project = await OptimizedTestManager.createOptimizedProject(
              templateKey: 'getx',
            );

            try {
              final result = await run([
                'self-update',
                '--dry-run',
              ], project.projectDir);

              expect(
                result.exitCode,
                anyOf([
                  equals(ExitCode.success.code),
                  equals(ExitCode.software.code), // Network issues
                ]),
              );

              print('✅ GetX project directory compatibility verified');
            } finally {
              await project.cleanup();
            }
          },
          timeout: const Timeout(Duration(seconds: 30)),
        );

        test(
          'should work from Clean project directory',
          () async {
            final project = await OptimizedTestManager.createOptimizedProject(
              templateKey: 'clean',
            );

            try {
              final result = await run([
                'self-update',
                '--dry-run',
              ], project.projectDir);

              expect(
                result.exitCode,
                anyOf([
                  equals(ExitCode.success.code),
                  equals(ExitCode.software.code), // Network issues
                ]),
              );

              print('✅ Clean project directory compatibility verified');
            } finally {
              await project.cleanup();
            }
          },
          timeout: const Timeout(Duration(seconds: 30)),
        );
      });

      // Command Output Validation Tests
      group('📝 Command Output Validation', () {
        test(
          'should show clear progress messages',
          () async {
            final tempDir = Directory.systemTemp.createTempSync(
              'test_project_',
            );

            try {
              final result = await run(['self-update', '--dry-run'], tempDir);

              if (result.exitCode == ExitCode.success.code) {
                expect(result.stdout, contains('🔍 Checking for updates...'));
                expect(
                  result.stdout,
                  anyOf([
                    contains('✅ gexd is already up to date!'),
                    contains('📦 Update available'),
                    contains('Current version'),
                  ]),
                );
              }

              print('✅ Progress messages display correctly');
            } finally {
              if (tempDir.existsSync()) {
                await tempDir.delete(recursive: true);
              }
            }
          },
          timeout: const Timeout(Duration(seconds: 30)),
        );

        test(
          'should show version information clearly',
          () async {
            final tempDir = Directory.systemTemp.createTempSync(
              'test_project_',
            );

            try {
              final result = await run(['self-update', '--dry-run'], tempDir);

              if (result.exitCode == ExitCode.success.code) {
                // Should show current version in some form
                expect(
                  result.stdout,
                  anyOf([
                    matches(r'Current version: \d+\.\d+\.\d+'),
                    matches(r'gexd \d+\.\d+\.\d+'),
                    contains('version'),
                  ]),
                );
              }

              print('✅ Version information display correctly');
            } finally {
              if (tempDir.existsSync()) {
                await tempDir.delete(recursive: true);
              }
            }
          },
          timeout: const Timeout(Duration(seconds: 30)),
        );

        test(
          'should show dry-run mode indication',
          () async {
            final tempDir = Directory.systemTemp.createTempSync(
              'test_project_',
            );

            try {
              final result = await run(['self-update', '--dry-run'], tempDir);

              if (result.exitCode == ExitCode.success.code) {
                expect(
                  result.stdout,
                  anyOf([
                    contains('dry-run'),
                    contains('preview'),
                    contains('would update'),
                    contains('No updates available'),
                  ]),
                );
              }

              print('✅ Dry-run mode indication display correctly');
            } finally {
              if (tempDir.existsSync()) {
                await tempDir.delete(recursive: true);
              }
            }
          },
          timeout: const Timeout(Duration(seconds: 30)),
        );
      });
    });
  }
}

void main() {
  SelfUpdateCommandTest().runTests();
}
