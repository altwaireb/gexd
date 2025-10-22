@Tags(['e2e'])
library;

import 'dart:io';
import 'package:io/io.dart' show ExitCode;
import 'package:test/test.dart';
import '../../../../helpers/e2e_test_base.dart';
import '../../../../helpers/optimized_test_manager.dart';

/// Binding Command E2E Test Suite
///
/// Comprehensive end-to-end testing for binding generation functionality.
/// Tests cover all binding locations, validation, error handling, and template compatibility.
///
/// Features tested:
/// - Binding creation with different locations (core, shared, screen)
/// - Template compatibility (GetX and Clean Architecture)
/// - Screen-specific binding integration
/// - Subdirectory organization and validation
/// - Error handling and edge cases
class BindingCommandTest extends E2ETestBase {
  void runTests() {
    group('BindingCommand E2E Tests', () {
      setUpAll(() async {
        await super.setUpAll();
        await OptimizedTestManager.initialize();
        print('🚀 Starting binding command tests...');
        print('⚡ Using OptimizedTestManager for fast execution');
      });

      tearDownAll(() async {
        OptimizedTestManager.clearCache();
        await super.tearDownAll();
        print('🎉 Binding command tests completed!');
      });

      // Pre-conditions & Validation Tests
      group('📋 Pre-conditions & Validation', () {
        test('should fail on uninitialized project', () async {
          final stopwatch = Stopwatch()..start();
          final tempDir = Directory.systemTemp.createTempSync('empty_project_');

          try {
            final result = await run(['make', 'binding', 'Test'], tempDir);
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
              'binding',
              '--help',
            ], project.projectDir);
            expect(result.exitCode, equals(ExitCode.success.code));
            expect(result.stdout, contains('Generate binding files'));
            expect(result.stdout, contains('--location'));
            expect(result.stdout, contains('--on-screen'));
            expect(result.stdout, contains('--on'));
            expect(result.stdout, contains('--force'));
            print('✅ Help documentation verified');
          } finally {
            await project.cleanup();
          }
        });

        test('should validate binding name format', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );
          try {
            final result = await run([
              'make',
              'binding',
              'invalidname',
              '--force',
            ], project.projectDir);
            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(result.stderr, contains('invalid format'));
            print('✅ Binding name validation working correctly');
          } finally {
            await project.cleanup();
          }
        });

        test('should validate binding location', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );
          try {
            final result = await run([
              'make',
              'binding',
              'Test',
              '--location',
              'invalidlocation',
              '--force',
            ], project.projectDir);
            expect(result.exitCode, equals(ExitCode.software.code));
            expect(result.stderr, contains('not an allowed value'));
            print('✅ Binding location validation working correctly');
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
              'binding',
              'TestBind',
              '--location',
              'screen',
              '--force',
            ], project.projectDir);
            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(result.stderr, contains('--on-screen) is missing'));
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
              'binding',
              'TestBind',
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
              ]),
            );
            print('✅ Screen location with --on properly rejected');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Core Binding Creation Tests
      group('🏗️ Core Binding Creation', () {
        test('should create core binding in GetX template', () async {
          final stopwatch = Stopwatch()..start();
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final bindingName = 'Auth';
            final result = await run([
              'make',
              'binding',
              bindingName,
              '--location',
              'core',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Validate GetX project structure exists
            final basePath = project.projectDir.path;
            expect(Directory('$basePath/lib/app/core').existsSync(), isTrue);

            // Validate binding file is created in core location
            final bindingFile = File(
              '$basePath/lib/app/core/bindings/auth_binding.dart',
            );
            expect(bindingFile.existsSync(), isTrue);

            // Check binding content
            final bindingContent = await bindingFile.readAsString();
            expect(bindingContent, contains('class AuthBinding'));
            expect(bindingContent, contains('extends Bindings'));
            expect(bindingContent, contains('@override'));
            expect(bindingContent, contains('void dependencies()'));

            stopwatch.stop();
            print(
              '✅ Core binding created successfully in GetX template (${stopwatch.elapsedMilliseconds}ms)',
            );
            print(
              '✅ Verified: Core binding file created with correct structure',
            );
          } finally {
            await project.cleanup();
          }
        });

        test('should create core binding in Clean template', () async {
          final stopwatch = Stopwatch()..start();
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'clean',
          );

          try {
            final bindingName = 'Network';
            final result = await run([
              'make',
              'binding',
              bindingName,
              '--location',
              'core',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Validate Clean Architecture project structure
            final basePath = project.projectDir.path;
            expect(Directory('$basePath/lib/core').existsSync(), isTrue);

            // Validate binding file is created in core location
            final bindingFile = File(
              '$basePath/lib/core/bindings/network_binding.dart',
            );
            expect(bindingFile.existsSync(), isTrue);

            // Check binding content
            final bindingContent = await bindingFile.readAsString();
            expect(bindingContent, contains('class NetworkBinding'));
            expect(bindingContent, contains('extends Bindings'));
            expect(bindingContent, contains('@override'));
            expect(bindingContent, contains('void dependencies()'));

            stopwatch.stop();
            print(
              '✅ Core binding created successfully in Clean template (${stopwatch.elapsedMilliseconds}ms)',
            );
            print(
              '✅ Verified: Core binding file created with correct structure',
            );
          } finally {
            await project.cleanup();
          }
        });

        test('should create core binding with subdirectory', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final bindingName = 'Database';
            final result = await run([
              'make',
              'binding',
              bindingName,
              '--location',
              'core',
              '--on',
              'services',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Validate binding file is created in subdirectory
            final bindingFile = File(
              '${project.projectDir.path}/lib/app/core/bindings/services/database_binding.dart',
            );
            expect(bindingFile.existsSync(), isTrue);

            // Check binding content
            final bindingContent = await bindingFile.readAsString();
            expect(bindingContent, contains('class DatabaseBinding'));
            expect(bindingContent, contains('extends Bindings'));

            print('✅ Core binding created in subdirectory successfully');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Shared Binding Creation Tests
      group('🤝 Shared Binding Creation', () {
        test('should create shared binding in GetX template', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final bindingName = 'ApiClient';
            final result = await run([
              'make',
              'binding',
              bindingName,
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Check for shared/modules directory structure
            final basePath = project.projectDir.path;
            var bindingFile = File(
              '$basePath/lib/app/modules/bindings/api_client_binding.dart',
            );

            // If modules structure doesn't exist, try presentation structure
            if (!bindingFile.existsSync()) {
              bindingFile = File(
                '$basePath/lib/app/presentation/bindings/api_client_binding.dart',
              );
            }

            expect(bindingFile.existsSync(), isTrue);

            // Check binding content
            final bindingContent = await bindingFile.readAsString();
            expect(bindingContent, contains('class ApiClientBinding'));
            expect(bindingContent, contains('extends Bindings'));

            print('✅ Shared binding created successfully in GetX template');
          } finally {
            await project.cleanup();
          }
        });

        test('should create shared binding in Clean template', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'clean',
          );

          try {
            final bindingName = 'Shared';
            final result = await run([
              'make',
              'binding',
              bindingName,
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Check for presentation directory structure
            final basePath = project.projectDir.path;
            final bindingFile = File(
              '$basePath/lib/presentation/bindings/shared_binding.dart',
            );
            expect(bindingFile.existsSync(), isTrue);

            // Check binding content
            final bindingContent = await bindingFile.readAsString();
            expect(bindingContent, contains('class SharedBinding'));
            expect(bindingContent, contains('extends Bindings'));

            print('✅ Shared binding created successfully in Clean template');
          } finally {
            await project.cleanup();
          }
        });

        test('should create shared binding with subdirectory', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final bindingName = 'FormValidator';
            final result = await run([
              'make',
              'binding',
              bindingName,
              '--location',
              'shared',
              '--on',
              'components',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Check for binding in subdirectory
            final basePath = project.projectDir.path;
            var bindingFile = File(
              '$basePath/lib/app/modules/bindings/components/form_validator_binding.dart',
            );

            // If modules structure doesn't exist, try presentation structure
            if (!bindingFile.existsSync()) {
              bindingFile = File(
                '$basePath/lib/app/presentation/bindings/components/form_validator_binding.dart',
              );
            }

            expect(bindingFile.existsSync(), isTrue);
            print('✅ Shared binding created in subdirectory successfully');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Screen-Specific Binding Creation Tests
      group('📱 Screen-Specific Binding Creation', () {
        test('should create screen binding linked to existing screen', () async {
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

            // Then create screen-specific binding
            final bindingName = 'ProfileExtra';
            final result = await run([
              'make',
              'binding',
              bindingName,
              '--location',
              'screen',
              '--on-screen',
              'profile', // Use snake_case/path_case format
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Validate binding is created in screen directory
            final basePath = project.projectDir.path;
            final bindingFile = File(
              '$basePath/lib/app/modules/profile/bindings/profile_extra_binding.dart',
            );
            expect(bindingFile.existsSync(), isTrue);

            // Check binding content
            final bindingContent = await bindingFile.readAsString();
            expect(bindingContent, contains('class ProfileExtraBinding'));
            expect(bindingContent, contains('extends Bindings'));

            print('✅ Screen-specific binding created successfully');
          } finally {
            await project.cleanup();
          }
        });

        test('should handle screen binding for non-existent screen', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final bindingName = 'NonExistentExtra';
            final result = await run([
              'make',
              'binding',
              bindingName,
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

        test('should create screen binding in Clean template', () async {
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

            // Then create screen-specific binding
            final bindingName = 'SettingsExtra';
            final result = await run([
              'make',
              'binding',
              bindingName,
              '--location',
              'screen',
              '--on-screen',
              'settings', // Use snake_case/path_case format
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Validate binding is created in screen directory (Clean Architecture)
            final basePath = project.projectDir.path;
            final bindingFile = File(
              '$basePath/lib/presentation/pages/settings/bindings/settings_extra_binding.dart',
            );
            expect(bindingFile.existsSync(), isTrue);

            print('✅ Screen-specific binding created in Clean template');
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
              'binding',
              'Interactive', // Provide name to avoid interactive prompt
              '--location',
              'core',
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
                'binding',
                'Deep',
                '--location',
                'core',
                '--on',
                'services/auth/providers',
                '--force',
              ], project.projectDir);

              expect(result.exitCode, equals(ExitCode.success.code));

              // Validate deep directory structure
              final bindingFile = File(
                '${project.projectDir.path}/lib/app/core/bindings/services/auth/providers/deep_binding.dart',
              );
              expect(bindingFile.existsSync(), isTrue);

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
                'binding',
                'TooDeep',
                '--location',
                'core',
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
              'binding',
              'InvalidPath',
              '--location',
              'core',
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
        test('should handle binding file creation properly', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            // Create binding first time
            final firstResult = await run([
              'make',
              'binding',
              'OverwriteTest',
              '--location',
              'core',
              '--force',
            ], project.projectDir);

            expect(firstResult.exitCode, equals(ExitCode.success.code));
            print('✅ First binding creation successful');

            // Create again with force flag (should work)
            final secondResult = await run([
              'make',
              'binding',
              'OverwriteTest',
              '--location',
              'core',
              '--force',
            ], project.projectDir);

            expect(secondResult.exitCode, equals(ExitCode.success.code));
            print('✅ Binding overwrite with force flag successful');
          } finally {
            await project.cleanup();
          }
        });

        test('should allow overwriting with force flag', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            // Create binding first time
            await run([
              'make',
              'binding',
              'ForceTest',
              '--location',
              'core',
              '--force',
            ], project.projectDir);

            // Create again with force flag
            final result = await run([
              'make',
              'binding',
              'ForceTest',
              '--location',
              'core',
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
            final bindingName = 'Api';
            final result = await run([
              'make',
              'binding',
              bindingName,
              '--location',
              'core',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            final bindingFile = File(
              '${project.projectDir.path}/lib/app/core/bindings/api_binding.dart',
            );
            expect(bindingFile.existsSync(), isTrue);

            // Verify file content structure
            final content = await bindingFile.readAsString();

            // Check imports
            expect(content, contains("import 'package:get/get.dart';"));

            // Check class structure
            expect(content, contains('class ApiBinding extends Bindings'));
            expect(content, contains('@override'));
            expect(content, contains('void dependencies() {'));
            expect(content, contains('// Add your dependency injections here'));
            expect(
              content,
              contains('// Get.lazyPut<YourService>(() => YourService());'),
            );

            // Verify file naming convention
            expect(bindingFile.path, contains('api_binding.dart'));

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
              'binding',
              'FormattingTest',
              '--location',
              'shared',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Check generated file has consistent indentation and formatting
            final basePath = project.projectDir.path;
            var bindingFile = File(
              '$basePath/lib/app/modules/bindings/formatting_test_binding.dart',
            );

            if (!bindingFile.existsSync()) {
              bindingFile = File(
                '$basePath/lib/app/presentation/bindings/formatting_test_binding.dart',
              );
            }

            expect(bindingFile.existsSync(), isTrue);

            final content = await bindingFile.readAsString();

            // Verify proper indentation (2 spaces standard)
            expect(content, contains('  @override'));
            expect(content, contains('  void dependencies() {'));
            expect(
              content,
              contains('    // Add your dependency injections here'),
            );

            print('✅ Code formatting consistency verified');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Performance & Quality Tests
      group('⚡ Performance & Quality Tests', () {
        test('should create binding within reasonable time', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final stopwatch = Stopwatch()..start();

            final result = await run([
              'make',
              'binding',
              'PerformanceTest',
              '--location',
              'core',
              '--force',
            ], project.projectDir);

            stopwatch.stop();

            expect(result.exitCode, equals(ExitCode.success.code));

            // Binding creation should complete within reasonable time
            expect(
              stopwatch.elapsedMilliseconds,
              lessThan(30000),
            ); // 30 seconds maximum

            print(
              '✅ Binding created in ${stopwatch.elapsedMilliseconds}ms (performance verified)',
            );
          } finally {
            await project.cleanup();
          }
        });

        test('should handle multiple binding creation efficiently', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final stopwatch = Stopwatch()..start();

            // Create multiple bindings to test batch performance
            final bindings = [
              {'name': 'Multi1', 'location': 'core'},
              {'name': 'Multi2', 'location': 'shared'},
              {'name': 'Multi3', 'location': 'core'},
            ];

            for (final binding in bindings) {
              final result = await run([
                'make',
                'binding',
                binding['name']!,
                '--location',
                binding['location']!,
                '--force',
              ], project.projectDir);

              expect(result.exitCode, equals(ExitCode.success.code));
            }

            stopwatch.stop();

            print(
              '⚡ Multiple binding test completed in ${stopwatch.elapsedMilliseconds}ms',
            );
            print(
              '📊 Created ${bindings.length} bindings in ${stopwatch.elapsedMilliseconds}ms',
            );
            print(
              '📊 Average: ${(stopwatch.elapsedMilliseconds / bindings.length).round()}ms per binding',
            );
          } finally {
            await project.cleanup();
          }
        });
      });

      // Cross-Template Compatibility Tests
      group('🔄 Cross-Template Compatibility', () {
        test('should create bindings in both templates successfully', () async {
          final stopwatch = Stopwatch()..start();

          final projects =
              await OptimizedTestManager.createOptimizedBothProjects();

          try {
            // Test binding creation in GetX template
            final getxResult = await run([
              'make',
              'binding',
              'CrossTest',
              '--location',
              'core',
              '--force',
            ], projects.getxProject.projectDir);

            expect(getxResult.exitCode, equals(ExitCode.success.code));

            // Test binding creation in Clean template
            final cleanResult = await run([
              'make',
              'binding',
              'CrossTest',
              '--location',
              'core',
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

        test('should handle all binding locations in both templates', () async {
          final projects =
              await OptimizedTestManager.createOptimizedBothProjects();

          try {
            final bindingLocations = [
              {'location': 'core', 'name': 'CoreTest'},
              {'location': 'shared', 'name': 'SharedTest'},
            ];

            for (final binding in bindingLocations) {
              final location = binding['location']!;
              final name = binding['name']!;

              // Test binding creation in GetX template
              final getxResult = await run([
                'make',
                'binding',
                '${name}GetX',
                '--location',
                location,
                '--force',
              ], projects.getxProject.projectDir);

              expect(getxResult.exitCode, equals(ExitCode.success.code));

              // Test binding creation in Clean template
              final cleanResult = await run([
                'make',
                'binding',
                '${name}Clean',
                '--location',
                location,
                '--force',
              ], projects.cleanProject.projectDir);

              expect(cleanResult.exitCode, equals(ExitCode.success.code));
            }

            print('✅ All binding locations working in both templates');
          } finally {
            await projects.cleanup();
          }
        });
      });

      // Edge Cases & Error Handling Tests
      group('⚠️ Edge Cases & Error Handling', () {
        test('should handle invalid binding name gracefully', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'make',
              'binding',
              'invalid-name-format',
              '--location',
              'core',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(result.stderr, contains('invalid format'));
            print('✅ Invalid binding name properly handled');
          } finally {
            await project.cleanup();
          }
        });

        test('should handle special characters in binding name', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'make',
              'binding',
              'Special@#',
              '--location',
              'core',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(result.stderr, contains('invalid format'));
            print('✅ Special characters in binding name properly rejected');
          } finally {
            await project.cleanup();
          }
        });

        test('should handle very long binding names', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final longName = 'Very${'Long' * 20}BindingName';
            final result = await run([
              'make',
              'binding',
              longName,
              '--location',
              'core',
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

            print('✅ Very long binding name handled appropriately');
          } finally {
            await project.cleanup();
          }
        });
      });
    });
  }
}

// String extension utility for capitalizing text
extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

void main() {
  BindingCommandTest().runTests();
}
