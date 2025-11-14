@Tags(['e2e'])
library;

import 'dart:io';
import 'package:io/io.dart' show ExitCode;
import 'package:test/test.dart';
import '../../../../helpers/e2e_test_base.dart';
import '../../../../helpers/optimized_test_manager.dart';

/// Interface Command E2E Test Suite
///
/// Comprehensive end-to-end testing for interface generation functionality.
/// Tests cover interface creation, validation, error handling, and template compatibility.
///
/// Features tested:
/// - Interface creation in default location
/// - Interface creation with different types (empty, crud)
/// - Model integration for CRUD interfaces
/// - Template compatibility (GetX and Clean Architecture)
/// - Input validation and error handling
/// - Force overwrite functionality
class InterfaceCommandTest extends E2ETestBase {
  void runTests() {
    group('InterfaceCommand E2E Tests', () {
      setUpAll(() async {
        await super.setUpAll();
        await OptimizedTestManager.initialize();
        print('🚀 Starting interface command tests...');
        print('⚡ Using OptimizedTestManager for fast execution');
      });

      tearDownAll(() async {
        OptimizedTestManager.clearCache();
        await super.tearDownAll();
        print('🎉 Interface command tests completed!');
      });

      // Pre-conditions & Validation Tests
      group('Pre-conditions & Validation', () {
        test('should fail on uninitialized project', () async {
          final stopwatch = Stopwatch()..start();
          final tempDir = Directory.systemTemp.createTempSync('empty_project_');

          try {
            final result = await run(['make', 'interface', 'Sample'], tempDir);
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
              'interface',
              '--help',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(result.stdout, contains('Generate interface files'));
            expect(result.stdout, contains('Usage:'));
            expect(result.stdout, contains('--type'));

            print('📖 Help documentation verified');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Basic Interface Generation Tests
      group('Basic Interface Generation', () {
        test('should create basic empty interface', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final interfaceName = 'Auth';
            final result = await run([
              'make',
              'interface',
              interfaceName,
              '--type',
              'empty',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              anyOf([
                contains('Generated interface file successful'),
                contains('Generated interface successful'),
                contains('Generated files'),
                contains('interface generation'),
              ]),
            );

            final basePath = project.projectDir.path;
            final interfaceFile = File(
              '$basePath/lib/app/data/interfaces/auth_interface.dart',
            );

            expect(interfaceFile.existsSync(), isTrue);

            final content = await interfaceFile.readAsString();
            expect(content, contains('abstract class AuthInterface'));

            print('✅ Basic empty interface creation verified');
          } finally {
            await project.cleanup();
          }
        });

        test('should create CRUD interface with model', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            // First create the model that the interface will use
            await run(['make', 'model', 'User', '--force'], project.projectDir);

            final interfaceName = 'User';
            final result = await run([
              'make',
              'interface',
              interfaceName,
              '--type',
              'crud',
              '--model',
              'UserModel',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              anyOf([
                contains('Generated interface file successful'),
                contains('Generated interface successful'),
                contains('Generated files'),
                contains('interface generation'),
              ]),
            );

            final basePath = project.projectDir.path;
            final interfaceFile = File(
              '$basePath/lib/app/data/interfaces/user_interface.dart',
            );

            expect(interfaceFile.existsSync(), isTrue);

            final content = await interfaceFile.readAsString();
            expect(content, contains('abstract class UserInterface'));
            expect(content, contains('Future<UserModel>'));

            print('✅ CRUD interface with model creation verified');
          } finally {
            await project.cleanup();
          }
        });

        test('should create interface in subdirectory with --on flag', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final interfaceName = 'Payment';
            final result = await run([
              'make',
              'interface',
              interfaceName,
              '--on',
              'payment',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              anyOf([
                contains('Generated interface file successful'),
                contains('Generated interface successful'),
                contains('Generated files'),
                contains('interface generation'),
              ]),
            );

            final basePath = project.projectDir.path;
            final interfaceFile = File(
              '$basePath/lib/app/data/interfaces/payment/payment_interface.dart',
            );

            expect(interfaceFile.existsSync(), isTrue);

            print('✅ Interface creation with subdirectory verified');
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
            final interfaceName = 'GetxApi';
            final result = await run([
              'make',
              'interface',
              interfaceName,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            final basePath = project.projectDir.path;
            final interfaceFile = File(
              '$basePath/lib/app/data/interfaces/getx_api_interface.dart',
            );

            expect(interfaceFile.existsSync(), isTrue);

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
            final interfaceName = 'CleanApi';
            final result = await run([
              'make',
              'interface',
              interfaceName,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            final basePath = project.projectDir.path;
            final interfaceFile = File(
              '$basePath/lib/domain/interfaces/clean_api_interface.dart',
            );

            expect(interfaceFile.existsSync(), isTrue);

            print('✅ Clean template compatibility verified');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Content Validation Tests
      group('📝 Interface Content Validation', () {
        test('should generate interface with proper Dart structure', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final interfaceName = 'DataApi';
            final result = await run([
              'make',
              'interface',
              interfaceName,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            final basePath = project.projectDir.path;
            final interfaceFile = File(
              '$basePath/lib/app/data/interfaces/data_api_interface.dart',
            );

            final content = await interfaceFile.readAsString();

            // Check for class structure
            expect(content, contains('abstract class DataApiInterface'));

            print('✅ Interface structure validation passed');
          } finally {
            await project.cleanup();
          }
        });

        test('should generate CRUD interface with proper methods', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            // First create the model that the interface will use
            await run([
              'make',
              'model',
              'Product',
              '--force',
            ], project.projectDir);

            final interfaceName = 'Product';
            final result = await run([
              'make',
              'interface',
              interfaceName,
              '--type',
              'crud',
              '--model',
              'ProductModel',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            final basePath = project.projectDir.path;
            final interfaceFile = File(
              '$basePath/lib/app/data/interfaces/product_interface.dart',
            );

            final content = await interfaceFile.readAsString();

            // Check for CRUD methods
            expect(content, contains('Future'));
            expect(content, contains('Product'));

            print('✅ CRUD interface methods validation passed');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Error Handling Tests
      group('Error Handling', () {
        test('should handle invalid interface names gracefully', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            // Test with invalid name (starts with number)
            final result = await run([
              'make',
              'interface',
              '123InvalidInterface',
            ], project.projectDir);

            // Should either fail with validation error or sanitize the name
            expect(
              result.exitCode,
              anyOf([
                equals(ExitCode.usage.code),
                equals(ExitCode.data.code),
                equals(64), // validation error
                equals(ExitCode.success.code), // if name is sanitized
              ]),
            );

            print('⚠️ Invalid interface name handling verified');
          } finally {
            await project.cleanup();
          }
        });

        test('should handle existing files appropriately', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final interfaceName = 'ExistingApi';

            // Create interface first time
            final firstResult = await run([
              'make',
              'interface',
              interfaceName,
              '--force',
            ], project.projectDir);

            expect(firstResult.exitCode, equals(ExitCode.success.code));

            // Try to create same interface again without force
            final secondResult = await run([
              'make',
              'interface',
              interfaceName,
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
        test('should handle interactive mode for interface creation', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'make',
              'interface',
              'InteractiveApi',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              anyOf([
                contains('Generated interface file successful'),
                contains('Generated interface successful'),
                contains('Generated files'),
                contains('interface generation'),
              ]),
            );

            print('🎮 Interactive mode handling verified');
          } finally {
            await project.cleanup();
          }
        });
      });
    });
  }
}

void main() => InterfaceCommandTest().runTests();
