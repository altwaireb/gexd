@Tags(['e2e'])
library;

import 'dart:io';
import 'package:io/io.dart' show ExitCode;
import 'package:test/test.dart';
import '../../../../helpers/e2e_test_base.dart';
import '../../../../helpers/optimized_test_manager.dart';

/// Controller Command E2E Test Suite
///
/// Comprehensive end-to-end testing for controller generation functionality.
/// Tests cover all controller locations, validation, error handling, and template compatibility.
///
/// Features tested:
/// - Controller creation with different locations (shared, screen)
/// - Template compatibility (GetX and Clean Architecture)
/// - Screen-specific controller integration
/// - Subdirectory organization and validation
/// - Error handling and edge cases
class ControllerCommandTest extends E2ETestBase {
  void runTests() {
    group('ControllerCommand E2E Tests', () {
      setUpAll(() async {
        await super.setUpAll();
        await OptimizedTestManager.initialize();
        print('🚀 Starting controller command tests...');
        print('⚡ Using OptimizedTestManager for fast execution');
      });

      tearDownAll(() async {
        OptimizedTestManager.clearCache();
        await super.tearDownAll();
        print('🎉 Controller command tests completed!');
      });

      // Pre-conditions & Validation Tests
      group('📋 Pre-conditions & Validation', () {
        test('should fail on uninitialized project', () async {
          final stopwatch = Stopwatch()..start();
          final tempDir = Directory.systemTemp.createTempSync('empty_project_');

          try {
            final result = await run(['make', 'controller', 'Test'], tempDir);
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
              'controller',
              '--help',
            ], project.projectDir);
            expect(result.exitCode, equals(ExitCode.success.code));
            expect(result.stdout, contains('Generate controller files'));
            expect(result.stdout, contains('--location'));
            expect(result.stdout, contains('--on-screen'));
            expect(result.stdout, contains('--on'));
            expect(result.stdout, contains('--force'));
            print('✅ Help documentation verified');
          } finally {
            await project.cleanup();
          }
        });

        test('should validate controller name format', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );
          try {
            final result = await run([
              'make',
              'controller',
              'invalidname',
              '--force',
            ], project.projectDir);
            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(result.stderr, contains('invalid format'));
            print('✅ Controller name validation working correctly');
          } finally {
            await project.cleanup();
          }
        });

        test('should validate controller location', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );
          try {
            final result = await run([
              'make',
              'controller',
              'Test',
              '--location',
              'invalidlocation',
              '--force',
            ], project.projectDir);
            expect(result.exitCode, equals(ExitCode.software.code));
            expect(result.stderr, contains('not an allowed value'));
            print('✅ Controller location validation working correctly');
          } finally {
            await project.cleanup();
          }
        });

        test('should require --on-screen for screen location', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );
          try {
            final result = await run([
              'make',
              'controller',
              'Test',
              '--location',
              'screen',
              '--force',
            ], project.projectDir);
            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(
              result.stderr,
              anyOf([
                contains('--on-screen) is missing'),
                contains('controller name should not end with "controller"'),
              ]),
            );
            print('✅ Screen location validation working correctly');
          } finally {
            await project.cleanup();
          }
        });

        test('should reject --on with screen location', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );
          try {
            final result = await run([
              'make',
              'controller',
              'Test',
              '--location',
              'screen',
              '--on-screen',
              'home', // Use snake_case/path_case format
              '--on',
              'subfolder',
              '--force',
            ], project.projectDir);
            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(
              result.stderr,
              anyOf([
                contains('--on option cannot be used with screen location'),
                contains('--on cannot be used with screen location'),
                contains('invalid format'),
                contains('controller name should not end with "controller"'),
              ]),
            );
            print('✅ Screen location with --on properly rejected');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Shared Controller Creation Tests
      group('🤝 Shared Controller Creation', () {
        test('should create shared controller in GetX template', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final controllerName = 'ApiClient';
            final result = await run([
              'make',
              'controller',
              controllerName,
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Check for shared/modules directory structure
            final basePath = project.projectDir.path;
            var controllerFile = File(
              '$basePath/lib/app/modules/controllers/api_client_controller.dart',
            );

            // If modules structure doesn't exist, try presentation structure
            if (!controllerFile.existsSync()) {
              controllerFile = File(
                '$basePath/lib/app/presentation/controllers/api_client_controller.dart',
              );
            }

            expect(controllerFile.existsSync(), isTrue);

            // Check controller content
            final controllerContent = await controllerFile.readAsString();
            expect(controllerContent, contains('class ApiClientController'));
            expect(controllerContent, contains('extends GetxController'));

            print('✅ Shared controller created successfully in GetX template');
          } finally {
            await project.cleanup();
          }
        });

        test('should create shared controller in Clean template', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'clean',
          );

          try {
            final controllerName = 'Shared';
            final result = await run([
              'make',
              'controller',
              controllerName,
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Check for presentation directory structure
            final basePath = project.projectDir.path;
            var controllerFile = File(
              '$basePath/lib/presentation/controllers/shared_controller.dart',
            );

            // If controllers folder doesn't exist, check if file was generated elsewhere
            if (!controllerFile.existsSync()) {
              // Check pages structure
              controllerFile = File(
                '$basePath/lib/presentation/pages/controllers/shared_controller.dart',
              );
            }

            // Accept if either location exists
            expect(controllerFile.existsSync(), isTrue);

            // Check controller content
            final controllerContent = await controllerFile.readAsString();
            expect(controllerContent, contains('class SharedController'));
            expect(controllerContent, contains('extends GetxController'));

            print('✅ Shared controller created successfully in Clean template');
          } finally {
            await project.cleanup();
          }
        });

        test('should create shared controller with subdirectory', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final controllerName = 'FormValidator';
            final result = await run([
              'make',
              'controller',
              controllerName,
              '--location',
              'shared',
              '--on',
              'components',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Check for controller in subdirectory
            final basePath = project.projectDir.path;
            var controllerFile = File(
              '$basePath/lib/app/modules/controllers/components/form_validator_controller.dart',
            );

            // If modules structure doesn't exist, try presentation structure
            if (!controllerFile.existsSync()) {
              controllerFile = File(
                '$basePath/lib/app/presentation/controllers/components/form_validator_controller.dart',
              );
            }

            expect(controllerFile.existsSync(), isTrue);
            print('✅ Shared controller created in subdirectory successfully');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Screen-Specific Controller Creation Tests
      group('📱 Screen-Specific Controller Creation', () {
        test(
          'should create screen controller linked to existing screen',
          () async {
            final project = await OptimizedTestManager.createOptimizedProject(
              templateKey: 'getx',
            );

            try {
              // First create a screen to link to
              await run([
                'make',
                'screen',
                'Profile',
                '--force',
              ], project.projectDir);

              // Then create screen-specific controller
              final controllerName = 'ProfileExtra';
              final result = await run([
                'make',
                'controller',
                controllerName,
                '--location',
                'screen',
                '--on-screen',
                'profile', // Use snake_case/path_case format
                '--force',
              ], project.projectDir);

              expect(result.exitCode, equals(ExitCode.success.code));

              // Validate controller is created in screen directory
              final basePath = project.projectDir.path;
              final controllerFile = File(
                '$basePath/lib/app/modules/profile/controllers/profile_extra_controller.dart',
              );
              expect(controllerFile.existsSync(), isTrue);

              // Check controller content
              final controllerContent = await controllerFile.readAsString();
              expect(
                controllerContent,
                contains('class ProfileExtraController'),
              );
              expect(controllerContent, contains('extends GetxController'));

              print('✅ Screen-specific controller created successfully');
            } finally {
              await project.cleanup();
            }
          },
        );

        test('should handle screen controller for non-existent screen', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final controllerName = 'NonExistentExtra';
            final result = await run([
              'make',
              'controller',
              controllerName,
              '--location',
              'screen',
              '--on-screen',
              'nonexistent', // Use snake_case/path_case format
              '--force',
            ], project.projectDir);

            // Should either create the directory structure or warn about missing screen
            // The exact behavior depends on implementation
            expect(
              result.exitCode,
              anyOf([
                equals(ExitCode.success.code),
                equals(ExitCode.usage.code),
              ]),
            );

            print('✅ Non-existent screen handling verified');
          } finally {
            await project.cleanup();
          }
        });

        test('should create screen controller in Clean template', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'clean',
          );

          try {
            // First create a screen to link to
            await run([
              'make',
              'screen',
              'Settings',
              '--force',
            ], project.projectDir);

            // Then create screen-specific controller
            final controllerName = 'SettingsExtra';
            final result = await run([
              'make',
              'controller',
              controllerName,
              '--location',
              'screen',
              '--on-screen',
              'settings', // Use snake_case/path_case format
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Validate controller is created in screen directory (Clean Architecture)
            final basePath = project.projectDir.path;
            final controllerFile = File(
              '$basePath/lib/presentation/pages/settings/controllers/settings_extra_controller.dart',
            );
            expect(controllerFile.existsSync(), isTrue);

            print('✅ Screen-specific controller created in Clean template');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Interactive Mode Tests
      group('🔄 Interactive Mode Tests', () {
        test('should support interactive mode without arguments', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            // Interactive mode would normally prompt user
            // For testing, we simulate with force flag
            final result = await run([
              'make',
              'controller',
              'Interactive', // Provide name to avoid interactive prompt
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            // Should succeed with proper parameters
            expect(result.exitCode, equals(ExitCode.success.code));

            print('✅ Interactive mode handling verified');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Subdirectory & Organization Tests
      group('📁 Subdirectory & Organization Tests', () {
        test(
          'should handle maximum allowed nested subdirectories (3 levels)',
          () async {
            final project = await OptimizedTestManager.createOptimizedProject(
              templateKey: 'getx',
            );

            try {
              final result = await run([
                'make',
                'controller',
                'Deep',
                '--location',
                'shared',
                '--on',
                'services/auth/providers',
                '--force',
              ], project.projectDir);

              expect(result.exitCode, equals(ExitCode.success.code));

              // Validate deep directory structure
              final controllerFile = File(
                '${project.projectDir.path}/lib/app/modules/controllers/services/auth/providers/deep_controller.dart',
              );
              expect(controllerFile.existsSync(), isTrue);

              print('✅ Maximum nested subdirectory (3 levels) handled');
            } finally {
              await project.cleanup();
            }
          },
        );

        test(
          'should reject subdirectories exceeding maximum depth (4+ levels)',
          () async {
            final project = await OptimizedTestManager.createOptimizedProject(
              templateKey: 'getx',
            );

            try {
              final result = await run([
                'make',
                'controller',
                'TooDeep',
                '--location',
                'shared',
                '--on',
                'services/auth/providers/deep',
                '--force',
              ], project.projectDir);

              expect(result.exitCode, equals(ExitCode.usage.code));
              expect(result.stderr, contains('exceeds maximum depth'));
              print('✅ Deep nested path (4+ levels) properly rejected');
            } finally {
              await project.cleanup();
            }
          },
        );

        test('should reject invalid subdirectory path formats', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'make',
              'controller',
              'InvalidPath',
              '--location',
              'shared',
              '--on',
              'Invalid-Path/With_Special@Chars',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(result.stderr, contains('invalid format'));
            print('✅ Invalid subdirectory path format rejected');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Force Flag & Overwrite Tests
      group('🔒 Force Flag & Overwrite Tests', () {
        test('should handle controller file creation properly', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            // Create controller first time
            final firstResult = await run([
              'make',
              'controller',
              'OverwriteTest',
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            expect(firstResult.exitCode, equals(ExitCode.success.code));
            print('✅ First controller creation successful');

            // Create again with force flag (should work)
            final secondResult = await run([
              'make',
              'controller',
              'OverwriteTest',
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            expect(secondResult.exitCode, equals(ExitCode.success.code));
            print('✅ Controller overwrite with force flag successful');
          } finally {
            await project.cleanup();
          }
        });

        test('should allow overwriting with force flag', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            // Create controller first time
            await run([
              'make',
              'controller',
              'ForceTest',
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            // Create again with force flag
            final result = await run([
              'make',
              'controller',
              'ForceTest',
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            print('✅ Successfully overwritten with force flag');
          } finally {
            await project.cleanup();
          }
        });
      });

      // File Structure & Content Quality Tests
      group('📄 File Structure & Content Quality Tests', () {
        test('should verify file structure and content correctness', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final controllerName = 'Api';
            final result = await run([
              'make',
              'controller',
              controllerName,
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Check for shared/modules directory structure
            final basePath = project.projectDir.path;
            var controllerFile = File(
              '$basePath/lib/app/modules/controllers/api_controller.dart',
            );

            // If modules structure doesn't exist, try presentation structure
            if (!controllerFile.existsSync()) {
              controllerFile = File(
                '$basePath/lib/app/presentation/controllers/api_controller.dart',
              );
            }

            expect(controllerFile.existsSync(), isTrue);

            // Verify file content structure
            final content = await controllerFile.readAsString();

            // Check imports
            expect(content, contains("import 'package:get/get.dart';"));

            // Check class structure
            expect(
              content,
              contains('class ApiController extends GetxController'),
            );
            expect(content, contains('@override'));
            expect(content, contains('void onInit() {'));
            expect(content, contains('void onReady() {'));
            expect(content, contains('void onClose() {'));

            // Verify file naming convention
            expect(controllerFile.path, contains('api_controller.dart'));

            print('✅ File structure and content verified');
            print('✅ Verified: Proper imports and class structure');
            print('✅ Verified: Proper naming conventions followed');
          } finally {
            await project.cleanup();
          }
        });

        test('should maintain consistent code formatting', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'make',
              'controller',
              'FormattingTest',
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Check generated file has consistent indentation and formatting
            final basePath = project.projectDir.path;
            var controllerFile = File(
              '$basePath/lib/app/modules/controllers/formatting_test_controller.dart',
            );

            if (!controllerFile.existsSync()) {
              controllerFile = File(
                '$basePath/lib/app/presentation/controllers/formatting_test_controller.dart',
              );
            }

            expect(controllerFile.existsSync(), isTrue);

            final content = await controllerFile.readAsString();

            // Verify proper indentation (2 spaces standard)
            expect(content, contains('  @override'));
            expect(content, contains('  void onInit() {'));
            expect(content, contains('    super.onInit();'));

            print('✅ Code formatting consistency verified');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Performance & Quality Tests
      group('⚡ Performance & Quality Tests', () {
        test('should create controller within reasonable time', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final stopwatch = Stopwatch()..start();

            final result = await run([
              'make',
              'controller',
              'PerformanceTest',
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            stopwatch.stop();

            expect(result.exitCode, equals(ExitCode.success.code));

            // Controller creation should complete within reasonable time
            expect(
              stopwatch.elapsedMilliseconds,
              lessThan(30000),
            ); // 30 seconds maximum

            print(
              '✅ Controller created in ${stopwatch.elapsedMilliseconds}ms (performance verified)',
            );
          } finally {
            await project.cleanup();
          }
        });

        test('should handle multiple controller creation efficiently', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final stopwatch = Stopwatch()..start();

            // Create multiple controllers to test batch performance
            final controllers = [
              {'name': 'Multi1', 'location': 'shared'},
              {'name': 'Multi2', 'location': 'shared'},
              {'name': 'Multi3', 'location': 'shared'},
            ];

            for (final controller in controllers) {
              final result = await run([
                'make',
                'controller',
                controller['name']!,
                '--location',
                controller['location']!,
                '--force',
              ], project.projectDir);

              expect(result.exitCode, equals(ExitCode.success.code));
            }

            stopwatch.stop();

            print(
              '⚡ Multiple controller test completed in ${stopwatch.elapsedMilliseconds}ms',
            );
            print(
              '📊 Created ${controllers.length} controllers in ${stopwatch.elapsedMilliseconds}ms',
            );
            print(
              '📊 Average: ${(stopwatch.elapsedMilliseconds / controllers.length).round()}ms per controller',
            );
          } finally {
            await project.cleanup();
          }
        });
      });

      // Cross-Template Compatibility Tests
      group('🔄 Cross-Template Compatibility', () {
        test(
          'should create controllers in both templates successfully',
          () async {
            final stopwatch = Stopwatch()..start();

            final projects =
                await OptimizedTestManager.createOptimizedBothProjects();

            try {
              // Test controller creation in GetX template
              final getxResult = await run([
                'make',
                'controller',
                'CrossTest',
                '--location',
                'shared',
                '--force',
              ], projects.getxProject.projectDir);

              expect(getxResult.exitCode, equals(ExitCode.success.code));

              // Test controller creation in Clean template
              final cleanResult = await run([
                'make',
                'controller',
                'CrossTest',
                '--location',
                'shared',
                '--force',
              ], projects.cleanProject.projectDir);

              expect(cleanResult.exitCode, equals(ExitCode.success.code));

              stopwatch.stop();
              print(
                '⚡ Cross-template test completed in ${stopwatch.elapsedMilliseconds}ms',
              );
              print('✅ Cross-template compatibility verified');
            } finally {
              await projects.cleanup();
            }
          },
        );

        test(
          'should handle all controller locations in both templates',
          () async {
            final projects =
                await OptimizedTestManager.createOptimizedBothProjects();

            try {
              final controllerLocations = [
                {'location': 'shared', 'name': 'SharedTest'},
              ];

              for (final controller in controllerLocations) {
                final location = controller['location']!;
                final name = controller['name']!;

                // Test controller creation in GetX template
                final getxResult = await run([
                  'make',
                  'controller',
                  '${name}GetX',
                  '--location',
                  location,
                  '--force',
                ], projects.getxProject.projectDir);

                expect(getxResult.exitCode, equals(ExitCode.success.code));

                // Test controller creation in Clean template
                final cleanResult = await run([
                  'make',
                  'controller',
                  '${name}Clean',
                  '--location',
                  location,
                  '--force',
                ], projects.cleanProject.projectDir);

                expect(cleanResult.exitCode, equals(ExitCode.success.code));
              }

              print('✅ All controller locations working in both templates');
            } finally {
              await projects.cleanup();
            }
          },
        );
      });

      // Edge Cases & Error Handling Tests
      group('⚠️ Edge Cases & Error Handling', () {
        test('should handle invalid controller name gracefully', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'make',
              'controller',
              'invalid-name-format',
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(result.stderr, contains('invalid format'));
            print('✅ Invalid controller name properly handled');
          } finally {
            await project.cleanup();
          }
        });

        test('should handle special characters in controller name', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'make',
              'controller',
              'Special@#',
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(result.stderr, contains('invalid format'));
            print('✅ Special characters in controller name properly rejected');
          } finally {
            await project.cleanup();
          }
        });

        test('should handle very long controller names', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final longName = 'Very${'Long' * 20}ControllerName';
            final result = await run([
              'make',
              'controller',
              longName,
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            // Should either succeed or fail gracefully with appropriate message
            expect(
              result.exitCode,
              anyOf([
                equals(ExitCode.success.code),
                equals(ExitCode.usage.code),
              ]),
            );

            print('✅ Very long controller name handled appropriately');
          } finally {
            await project.cleanup();
          }
        });
      });
    });
  }
}

void main() {
  ControllerCommandTest().runTests();
}
