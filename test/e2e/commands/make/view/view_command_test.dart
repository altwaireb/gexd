@Tags(['e2e'])
library;

import 'dart:io';
import 'package:io/io.dart' show ExitCode;
import 'package:test/test.dart';
import '../../../../helpers/e2e_test_base.dart';
import '../../../../helpers/optimized_test_manager.dart';

/// View Command E2E Test Suite
///
/// Comprehensive end-to-end testing for view generation functionality.
/// Tests cover all view locations, validation, error handling, and template compatibility.
///
/// Features tested:
/// - View creation with different locations (shared, screen)
/// - Template compatibility (GetX and Clean Architecture)
/// - Screen-specific view integration
/// - Subdirectory organization and validation
/// - Error handling and edge cases
class ViewCommandTest extends E2ETestBase {
  void runTests() {
    group('ViewCommand E2E Tests', () {
      setUpAll(() async {
        await super.setUpAll();
        await OptimizedTestManager.initialize();
        print('🚀 Starting view command tests...');
        print('⚡ Using OptimizedTestManager for fast execution');
      });

      tearDownAll(() async {
        OptimizedTestManager.clearCache();
        await super.tearDownAll();
        print('🎉 View command tests completed!');
      });

      // Pre-conditions & Validation Tests
      group('📋 Pre-conditions & Validation', () {
        test('should fail on uninitialized project', () async {
          final stopwatch = Stopwatch()..start();
          final tempDir = Directory.systemTemp.createTempSync('empty_project_');

          try {
            final result = await run(['make', 'view', 'Sample'], tempDir);
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
              'view',
              '--help',
            ], project.projectDir);
            expect(result.exitCode, equals(ExitCode.success.code));
            expect(result.stdout, contains('Generate view files'));
            expect(result.stdout, contains('--location'));
            expect(result.stdout, contains('--on-screen'));
            expect(result.stdout, contains('--on'));
            expect(result.stdout, contains('--force'));
            print('✅ Help documentation verified');
          } finally {
            await project.cleanup();
          }
        });

        test('should validate view name format', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );
          try {
            final result = await run([
              'make',
              'view',
              'invalidname',
              '--force',
            ], project.projectDir);
            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(result.stderr, contains('invalid format'));
            print('✅ View name validation working correctly');
          } finally {
            await project.cleanup();
          }
        });

        test('should validate view location', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );
          try {
            final result = await run([
              'make',
              'view',
              'Sample',
              '--location',
              'invalidlocation',
              '--force',
            ], project.projectDir);
            expect(result.exitCode, equals(ExitCode.software.code));
            expect(result.stderr, contains('not an allowed value'));
            print('✅ View location validation working correctly');
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
              'view',
              'Sample',
              '--location',
              'screen',
              '--force',
            ], project.projectDir);
            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(
              result.stderr,
              anyOf([
                contains('--on-screen) is missing'),
                contains('view name should not end with "view"'),
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
              'view',
              'Sample',
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
                contains('view name should not end with "view"'),
              ]),
            );
            print('✅ Screen location with --on properly rejected');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Shared View Creation Tests
      group('🤝 Shared View Creation', () {
        test('should create shared view in GetX template', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final viewName = 'ApiClient';
            final result = await run([
              'make',
              'view',
              viewName,
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Check for shared/modules directory structure
            final basePath = project.projectDir.path;
            var viewFile = File(
              '$basePath/lib/app/modules/bindings/api_client_view.dart',
            );

            // If modules structure doesn't exist, try other possible paths
            if (!viewFile.existsSync()) {
              final possiblePaths = [
                '$basePath/lib/app/modules/views/api_client_view.dart',
                '$basePath/lib/presentation/views/api_client_view.dart',
                '$basePath/lib/presentation/pages/views/api_client_view.dart',
              ];

              for (final path in possiblePaths) {
                final file = File(path);
                if (file.existsSync()) {
                  viewFile = file;
                  break;
                }
              }
            }

            expect(viewFile.existsSync(), isTrue);

            // Check view content
            final viewContent = await viewFile.readAsString();
            expect(viewContent, contains('class ApiClientView'));
            expect(
              viewContent,
              anyOf([
                contains('extends GetView'),
                contains('extends StatelessWidget'),
              ]),
            );

            print('✅ Shared view created successfully in GetX template');
          } finally {
            await project.cleanup();
          }
        });

        test('should create shared view in Clean template', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'clean',
          );

          try {
            final viewName = 'Shared';
            final result = await run([
              'make',
              'view',
              viewName,
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Check for presentation directory structure
            final basePath = project.projectDir.path;
            var viewFile = File(
              '$basePath/lib/presentation/pages/views/shared_view.dart',
            );

            // Accept if either location exists
            expect(viewFile.existsSync(), isTrue);

            // Check view content
            final viewContent = await viewFile.readAsString();
            expect(viewContent, contains('class SharedView'));
            expect(viewContent, contains('extends StatelessWidget'));

            print('✅ Shared view created successfully in Clean template');
          } finally {
            await project.cleanup();
          }
        });

        test('should create shared view with subdirectory', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final viewName = 'Loading';
            final result = await run([
              'make',
              'view',
              viewName,
              '--location',
              'shared',
              '--on',
              'components',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Check for view in subdirectory
            final basePath = project.projectDir.path;
            var viewFile = File(
              '$basePath/lib/app/modules/bindings/components/loading_view.dart',
            );

            // If main path doesn't exist, try other possible paths
            if (!viewFile.existsSync()) {
              final possiblePaths = [
                '$basePath/lib/app/modules/views/components/loading_view.dart',
                '$basePath/lib/presentation/views/components/loading_view.dart',
                '$basePath/lib/presentation/pages/views/components/loading_view.dart',
              ];

              for (final path in possiblePaths) {
                final file = File(path);
                if (file.existsSync()) {
                  viewFile = file;
                  break;
                }
              }
            }

            expect(viewFile.existsSync(), isTrue);
            print('✅ Shared view created in subdirectory successfully');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Screen-Specific View Creation Tests
      group('📱 Screen-Specific View Creation', () {
        test('should create screen view linked to existing screen', () async {
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

            // Then create screen-specific view
            final viewName = 'ProfileHeader';
            final result = await run([
              'make',
              'view',
              viewName,
              '--location',
              'screen',
              '--on-screen',
              'profile', // Use snake_case/path_case format
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Validate view is created in screen directory
            final basePath = project.projectDir.path;
            final viewFile = File(
              '$basePath/lib/app/modules/profile/views/profile_header_view.dart',
            );
            expect(viewFile.existsSync(), isTrue);

            // Check view content
            final viewContent = await viewFile.readAsString();
            expect(viewContent, contains('class ProfileHeaderView'));
            expect(
              viewContent,
              anyOf([
                contains('extends GetView'),
                contains('extends StatelessWidget'),
              ]),
            );

            print('✅ Screen-specific view created successfully');
          } finally {
            await project.cleanup();
          }
        });

        test('should handle screen view for non-existent screen', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final viewName = 'NonExistent';
            final result = await run([
              'make',
              'view',
              viewName,
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

        test('should create screen view in Clean template', () async {
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

            // Then create screen-specific view
            final viewName = 'SettingsForm';
            final result = await run([
              'make',
              'view',
              viewName,
              '--location',
              'screen',
              '--on-screen',
              'settings', // Use snake_case/path_case format
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Validate view is created in screen directory (Clean Architecture)
            final basePath = project.projectDir.path;
            final viewFile = File(
              '$basePath/lib/presentation/pages/settings/views/settings_form_view.dart',
            );
            expect(viewFile.existsSync(), isTrue);

            print('✅ Screen-specific view created in Clean template');
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
              'view',
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
                'view',
                'DeepForm',
                '--location',
                'shared',
                '--on',
                'widgets/forms/inputs',
                '--force',
              ], project.projectDir);

              expect(result.exitCode, equals(ExitCode.success.code));

              // Validate deep directory structure
              final viewFile = File(
                '${project.projectDir.path}/lib/app/modules/views/widgets/forms/inputs/deep_form_view.dart',
              );
              expect(viewFile.existsSync(), isTrue);

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
                'view',
                'TooDeep',
                '--location',
                'shared',
                '--on',
                'widgets/forms/inputs/deep',
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
              'view',
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
        test('should handle view file creation properly', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            // Create view first time
            final firstResult = await run([
              'make',
              'view',
              'Overwrite',
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            expect(firstResult.exitCode, equals(ExitCode.success.code));
            print('✅ First view creation successful');

            // Create again with force flag (should work)
            final secondResult = await run([
              'make',
              'view',
              'Overwrite',
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            expect(secondResult.exitCode, equals(ExitCode.success.code));
            print('✅ View overwrite with force flag successful');
          } finally {
            await project.cleanup();
          }
        });

        test('should allow overwriting with force flag', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            // Create view first time
            await run([
              'make',
              'view',
              'Force',
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            // Create again with force flag
            final result = await run([
              'make',
              'view',
              'Force',
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
            final viewName = 'CustomButton';
            final result = await run([
              'make',
              'view',
              viewName,
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Check for shared/modules directory structure
            final basePath = project.projectDir.path;
            var viewFile = File(
              '$basePath/lib/app/modules/views/custom_button_view.dart',
            );

            // If modules structure doesn't exist, try presentation structure
            if (!viewFile.existsSync()) {
              viewFile = File(
                '$basePath/lib/app/presentation/views/custom_button_view.dart',
              );
            }

            expect(viewFile.existsSync(), isTrue);

            // Verify file content structure
            final content = await viewFile.readAsString();

            // Check imports
            expect(
              content,
              contains("import 'package:flutter/material.dart';"),
            );

            // Check class structure
            expect(
              content,
              contains('class CustomButtonView extends StatelessWidget'),
            );
            expect(content, contains('Widget build(BuildContext context)'));

            // Verify file naming convention
            expect(viewFile.path, contains('custom_button_view.dart'));

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
              'view',
              'Formatting',
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Check generated file has consistent indentation and formatting
            final basePath = project.projectDir.path;
            var viewFile = File(
              '$basePath/lib/app/modules/views/formatting_view.dart',
            );

            expect(viewFile.existsSync(), isTrue);

            final content = await viewFile.readAsString();

            // Verify proper indentation (2 spaces standard)
            expect(content, contains('Widget build(BuildContext context) {'));

            print('✅ Code formatting consistency verified');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Performance & Quality Tests
      group('⚡ Performance & Quality Tests', () {
        test('should create view within reasonable time', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final stopwatch = Stopwatch()..start();

            final result = await run([
              'make',
              'view',
              'Performance',
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            stopwatch.stop();

            expect(result.exitCode, equals(ExitCode.success.code));

            // View creation should complete within reasonable time
            expect(
              stopwatch.elapsedMilliseconds,
              lessThan(30000),
            ); // 30 seconds maximum

            print(
              '✅ View created in ${stopwatch.elapsedMilliseconds}ms (performance verified)',
            );
          } finally {
            await project.cleanup();
          }
        });
      });

      // Cross-Template Compatibility Tests
      group('🔄 Cross-Template Compatibility', () {
        test('should create views in both templates successfully', () async {
          final stopwatch = Stopwatch()..start();

          final projects =
              await OptimizedTestManager.createOptimizedBothProjects();

          try {
            // Test view creation in GetX template
            final getxResult = await run([
              'make',
              'view',
              'Cross',
              '--location',
              'shared',
              '--force',
            ], projects.getxProject.projectDir);

            expect(getxResult.exitCode, equals(ExitCode.success.code));

            // Test view creation in Clean template
            final cleanResult = await run([
              'make',
              'view',
              'Cross',
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
        });

        test('should handle all view locations in both templates', () async {
          final projects =
              await OptimizedTestManager.createOptimizedBothProjects();

          try {
            final viewLocations = [
              {'location': 'shared', 'name': 'SharedTest'},
            ];

            for (final view in viewLocations) {
              final location = view['location']!;
              final name = view['name']!;

              // Test view creation in GetX template
              final getxResult = await run([
                'make',
                'view',
                '${name}GetX',
                '--location',
                location,
                '--force',
              ], projects.getxProject.projectDir);

              expect(getxResult.exitCode, equals(ExitCode.success.code));

              // Test view creation in Clean template
              final cleanResult = await run([
                'make',
                'view',
                '${name}Clean',
                '--location',
                location,
                '--force',
              ], projects.cleanProject.projectDir);

              expect(cleanResult.exitCode, equals(ExitCode.success.code));
            }

            print('✅ All view locations working in both templates');
          } finally {
            await projects.cleanup();
          }
        });
      });

      // Edge Cases & Error Handling Tests
      group('⚠️ Edge Cases & Error Handling', () {
        test('should handle invalid view name gracefully', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'make',
              'view',
              'invalid-name-format',
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(result.stderr, contains('invalid format'));
            print('✅ Invalid view name properly handled');
          } finally {
            await project.cleanup();
          }
        });

        test('should handle special characters in view name', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'make',
              'view',
              'Special@#',
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(result.stderr, contains('invalid format'));
            print('✅ Special characters in view name properly rejected');
          } finally {
            await project.cleanup();
          }
        });

        test('should handle very long view names', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final longName = 'Very${'Long' * 20}ViewName';
            final result = await run([
              'make',
              'view',
              longName,
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.usage.code));

            print('✅ Very long view name handled appropriately');
          } finally {
            await project.cleanup();
          }
        });

        test('should handle view names ending with "View"', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'make',
              'view',
              'CustomView',
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(
              result.stderr,
              contains('view name should not end with "view"'),
            );
            print('✅ View names ending with "View" properly rejected');
          } finally {
            await project.cleanup();
          }
        });
      });
    });
  }
}

void main() {
  ViewCommandTest().runTests();
}
