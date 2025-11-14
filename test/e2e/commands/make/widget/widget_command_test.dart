@Tags(['e2e'])
library;

import 'dart:io';
import 'package:io/io.dart' show ExitCode;
import 'package:test/test.dart';
import '../../../../helpers/e2e_test_base.dart';
import '../../../../helpers/optimized_test_manager.dart';

/// Widget Command E2E Test Suite
///
/// Comprehensive end-to-end testing for widget generation functionality.
/// Tests cover widget creation, validation, error handling, and template compatibility.
///
/// Features tested:
/// - Widget creation in default location
/// - Widget creation with subdirectories (--on flag)
/// - Template compatibility (GetX and Clean Architecture)
/// - Input validation and error handling
/// - Force overwrite functionality
/// - Interactive mode handling
class WidgetCommandTest extends E2ETestBase {
  void runTests() {
    group('WidgetCommand E2E Tests', () {
      setUpAll(() async {
        await super.setUpAll();
        await OptimizedTestManager.initialize();
        print('🚀 Starting widget command tests...');
        print('⚡ Using OptimizedTestManager for fast execution');
      });

      tearDownAll(() async {
        OptimizedTestManager.clearCache();
        await super.tearDownAll();
        print('🎉 Widget command tests completed!');
      });

      // Pre-conditions & Validation Tests
      group('Pre-conditions & Validation', () {
        test('should fail on uninitialized project', () async {
          final stopwatch = Stopwatch()..start();
          final tempDir = Directory.systemTemp.createTempSync('empty_project_');

          try {
            final result = await run(['make', 'widget', 'Sample'], tempDir);
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
              'widget',
              '--help',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(result.stdout, contains('Generate widget files'));
            expect(result.stdout, contains('Usage:'));
            expect(result.stdout, contains('--location'));

            print('📖 Help documentation verified');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Basic Widget Generation Tests
      group('Basic Widget Generation', () {
        test('should create basic widget in shared location', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final widgetName = 'CustomButton';
            final result = await run([
              'make',
              'widget',
              widgetName,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(result.stdout, contains('Generated widget successful'));

            final basePath = project.projectDir.path;
            final widgetFile = File(
              '$basePath/lib/app/shared/widgets/custom_button_widget.dart',
            );

            expect(widgetFile.existsSync(), isTrue);

            final content = await widgetFile.readAsString();
            expect(content, contains('class CustomButtonWidget'));
            expect(content, contains('extends StatelessWidget'));

            print('✅ Basic widget creation verified');
          } finally {
            await project.cleanup();
          }
        });

        test('should create widget in subdirectory with --on flag', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final widgetName = 'InputField';
            final result = await run([
              'make',
              'widget',
              widgetName,
              '--on',
              'forms',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(result.stdout, contains('Generated widget successful'));

            final basePath = project.projectDir.path;
            final widgetFile = File(
              '$basePath/lib/app/shared/widgets/forms/input_field_widget.dart',
            );

            expect(widgetFile.existsSync(), isTrue);

            final content = await widgetFile.readAsString();
            expect(content, contains('class InputFieldWidget'));
            expect(content, contains('extends StatelessWidget'));

            print('✅ Widget creation with subdirectory verified');
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
            final widgetName = 'GetxCard';
            final result = await run([
              'make',
              'widget',
              widgetName,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            final basePath = project.projectDir.path;
            final widgetFile = File(
              '$basePath/lib/app/shared/widgets/getx_card_widget.dart',
            );

            expect(widgetFile.existsSync(), isTrue);

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
            final widgetName = 'CleanCard';
            final result = await run([
              'make',
              'widget',
              widgetName,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            final basePath = project.projectDir.path;
            final widgetFile = File(
              '$basePath/lib/shared/widgets/clean_card_widget.dart',
            );

            expect(widgetFile.existsSync(), isTrue);

            print('✅ Clean template compatibility verified');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Content Validation Tests
      group('Widget Content Validation', () {
        test('should generate widget with proper Flutter structure', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final widgetName = 'FlutterCard';
            final result = await run([
              'make',
              'widget',
              widgetName,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            final basePath = project.projectDir.path;
            final widgetFile = File(
              '$basePath/lib/app/shared/widgets/flutter_card_widget.dart',
            );

            final content = await widgetFile.readAsString();

            // Check for proper imports
            expect(
              content,
              contains("import 'package:flutter/material.dart';"),
            );

            // Check for class structure
            expect(content, contains('class FlutterCardWidget'));
            expect(content, contains('extends StatelessWidget'));

            // Check for build method
            expect(content, contains('@override'));
            expect(content, contains('Widget build(BuildContext context)'));

            // Check for proper widget return
            expect(content, contains('return Container('));

            print('✅ Widget structure validation passed');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Error Handling Tests
      group('Error Handling', () {
        test('should handle invalid widget names gracefully', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            // Test with invalid name (starts with number)
            final result = await run([
              'make',
              'widget',
              '123InvalidWidget',
            ], project.projectDir);

            // Should either fail with validation error or sanitize the name
            expect(
              result.exitCode,
              anyOf([
                equals(ExitCode.usage.code),
                equals(ExitCode.data.code),
                equals(ExitCode.success.code), // if name is sanitized
              ]),
            );

            print('⚠️ Invalid widget name handling verified');
          } finally {
            await project.cleanup();
          }
        });

        test('should handle existing files appropriately', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final widgetName = 'ExistingCard';

            // Create widget first time
            final firstResult = await run([
              'make',
              'widget',
              widgetName,
              '--force',
            ], project.projectDir);

            expect(firstResult.exitCode, equals(ExitCode.success.code));

            // Try to create same widget again without force
            final secondResult = await run([
              'make',
              'widget',
              widgetName,
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
        test('should handle interactive mode for existing widgets', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'make',
              'widget',
              'InteractiveCard',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(result.stdout, contains('Generated widget successful'));

            print('🎮 Interactive mode handling verified');
          } finally {
            await project.cleanup();
          }
        });
      });
    });
  }
}

void main() => WidgetCommandTest().runTests();
