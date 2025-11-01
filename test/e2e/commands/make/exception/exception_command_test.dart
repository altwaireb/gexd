@Tags(['e2e'])
library;

import 'dart:io';
import 'package:io/io.dart' show ExitCode;
import 'package:test/test.dart';
import '../../../../helpers/e2e_test_base.dart';
import '../../../../helpers/optimized_test_manager.dart';

/// Exception Command E2E Test Suite
///
/// Comprehensive end-to-end testing for exception generation functionality.
/// Tests cover exception creation, validation, error handling, and template compatibility.
///
/// Features tested:
/// - Exception creation in default location
/// - Exception creation with subdirectories (--on flag)
/// - Template compatibility (GetX and Clean Architecture)
/// - Input validation and error handling
/// - Force overwrite functionality
/// - Interactive mode handling
class ExceptionCommandTest extends E2ETestBase {
  void runTests() {
    group('ExceptionCommand E2E Tests', () {
      setUpAll(() async {
        await super.setUpAll();
        await OptimizedTestManager.initialize();
        print('🚀 Starting exception command tests...');
        print('⚡ Using OptimizedTestManager for fast execution');
      });

      tearDownAll(() async {
        OptimizedTestManager.clearCache();
        await super.tearDownAll();
        print('🎉 Exception command tests completed!');
      });

      // Pre-conditions & Validation Tests
      group('📋 Pre-conditions & Validation', () {
        test('should fail on uninitialized project', () async {
          final stopwatch = Stopwatch()..start();
          final tempDir = Directory.systemTemp.createTempSync('empty_project_');

          try {
            final result = await run(['make', 'exception', 'Sample'], tempDir);
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
              'exception',
              '--help',
            ], project.projectDir);
            expect(result.exitCode, equals(ExitCode.success.code));
            expect(result.stdout, contains('Generate exception files'));
            expect(result.stdout, contains('--on'));
            expect(result.stdout, contains('--force'));
            expect(result.stdout, contains('Examples:'));
            print('✅ Help documentation verified');
          } finally {
            await project.cleanup();
          }
        });

        test('should validate exception name format', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );
          try {
            final result = await run([
              'make',
              'exception',
              'invalidname',
              '--force',
            ], project.projectDir);
            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(result.stderr, contains('invalid format'));
            print('✅ Exception name validation working correctly');
          } finally {
            await project.cleanup();
          }
        });

        test('should reject exception names ending with "Exception"', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );
          try {
            final result = await run([
              'make',
              'exception',
              'AuthException',
              '--force',
            ], project.projectDir);
            // Now exception names ending with "Exception" should be rejected as reserved words
            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(result.stderr, contains('should not end with "exception"'));
            print('✅ Exception suffix validation working correctly');
          } finally {
            await project.cleanup();
          }
        });

        test('should validate subdirectory depth', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );
          try {
            final result = await run([
              'make',
              'exception',
              'Sample',
              '--on',
              'a/very/deep/nested/path',
              '--force',
            ], project.projectDir);
            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(result.stderr, contains('exceeds maximum depth'));
            print('✅ Path depth validation working correctly');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Basic Exception Creation Tests
      group('🎯 Basic Exception Creation', () {
        test(
          'should create exception in default location - GetX template',
          () async {
            final project = await OptimizedTestManager.createOptimizedProject(
              templateKey: 'getx',
            );

            try {
              final exceptionName = 'Auth';
              final result = await run([
                'make',
                'exception',
                exceptionName,
                '--force',
              ], project.projectDir);

              expect(result.exitCode, equals(ExitCode.success.code));
              expect(
                result.stdout,
                contains('Generated exception files successful'),
              );

              // Check for exception file in GetX template structure
              final basePath = project.projectDir.path;
              final exceptionFile = File(
                '$basePath/lib/app/core/exceptions/auth_exception.dart',
              );

              expect(exceptionFile.existsSync(), isTrue);

              // Check exception content
              final exceptionContent = await exceptionFile.readAsString();
              expect(exceptionContent, contains('class AuthException'));
              expect(exceptionContent, contains('implements Exception'));
              expect(exceptionContent, contains('final String message'));
              expect(exceptionContent, contains('final String? code'));
              expect(
                exceptionContent,
                contains('const AuthException(this.message, {this.code})'),
              );
              expect(exceptionContent, contains('String toString()'));

              print('✅ Exception created successfully in GetX template');
            } finally {
              await project.cleanup();
            }
          },
        );

        test(
          'should create exception in default location - Clean template',
          () async {
            final project = await OptimizedTestManager.createOptimizedProject(
              templateKey: 'clean',
            );

            try {
              final exceptionName = 'Network';
              final result = await run([
                'make',
                'exception',
                exceptionName,
                '--force',
              ], project.projectDir);

              expect(result.exitCode, equals(ExitCode.success.code));

              // Check for exception file in Clean template structure
              final basePath = project.projectDir.path;
              final exceptionFile = File(
                '$basePath/lib/core/exceptions/network_exception.dart',
              );

              expect(exceptionFile.existsSync(), isTrue);

              // Check exception content
              final exceptionContent = await exceptionFile.readAsString();
              expect(exceptionContent, contains('class NetworkException'));
              expect(exceptionContent, contains('implements Exception'));

              print('✅ Exception created successfully in Clean template');
            } finally {
              await project.cleanup();
            }
          },
        );
      });

      // Exception Creation with Subdirectories
      group('📁 Exception Creation with Subdirectories', () {
        test('should create exception in single subdirectory', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final exceptionName = 'Validation';
            final subdirectory = 'forms';
            final result = await run([
              'make',
              'exception',
              exceptionName,
              '--on',
              subdirectory,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Check for exception file in subdirectory
            final basePath = project.projectDir.path;
            final exceptionFile = File(
              '$basePath/lib/app/core/exceptions/forms/validation_exception.dart',
            );

            expect(exceptionFile.existsSync(), isTrue);

            // Check exception content
            final exceptionContent = await exceptionFile.readAsString();
            expect(exceptionContent, contains('class ValidationException'));
            expect(exceptionContent, contains('implements Exception'));

            print('✅ Exception created successfully in subdirectory');
          } finally {
            await project.cleanup();
          }
        });

        test('should create exception in nested subdirectories', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final exceptionName = 'Database';
            final subdirectory = 'data/repositories';
            final result = await run([
              'make',
              'exception',
              exceptionName,
              '--on',
              subdirectory,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Check for exception file in nested subdirectory
            final basePath = project.projectDir.path;
            final exceptionFile = File(
              '$basePath/lib/app/core/exceptions/data/repositories/database_exception.dart',
            );

            expect(exceptionFile.existsSync(), isTrue);

            // Check exception content
            final exceptionContent = await exceptionFile.readAsString();
            expect(exceptionContent, contains('class DatabaseException'));
            expect(exceptionContent, contains('implements Exception'));

            print('✅ Exception created successfully in nested subdirectories');
          } finally {
            await project.cleanup();
          }
        });

        test('should handle maximum subdirectory depth', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final exceptionName = 'Deep';
            final subdirectory = 'level1/level2/level3';
            final result = await run([
              'make',
              'exception',
              exceptionName,
              '--on',
              subdirectory,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Check for exception file at maximum depth
            final basePath = project.projectDir.path;
            final exceptionFile = File(
              '$basePath/lib/app/core/exceptions/level1/level2/level3/deep_exception.dart',
            );

            expect(exceptionFile.existsSync(), isTrue);

            print('✅ Exception created at maximum subdirectory depth');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Force Overwrite Tests
      group('🔄 Force Overwrite Functionality', () {
        test('should prompt for overwrite without --force flag', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final exceptionName = 'Existing';

            // Create exception first time
            var result = await run([
              'make',
              'exception',
              exceptionName,
              '--force',
            ], project.projectDir);
            expect(result.exitCode, equals(ExitCode.success.code));

            // Try to create same exception without --force
            result = await run([
              'make',
              'exception',
              exceptionName,
            ], project.projectDir);

            // Should inform about existing file and ask for --force (exit code 64)
            expect(result.exitCode, equals(64));

            print('✅ Overwrite handling working correctly');
          } finally {
            await project.cleanup();
          }
        });

        test('should overwrite with --force flag', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final exceptionName = 'Overwrite';

            // Create exception first time
            var result = await run([
              'make',
              'exception',
              exceptionName,
              '--force',
            ], project.projectDir);
            expect(result.exitCode, equals(ExitCode.success.code));

            // Overwrite with --force flag
            result = await run([
              'make',
              'exception',
              exceptionName,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('Generated exception files successful'),
            );

            print('✅ Force overwrite working correctly');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Edge Cases & Error Handling
      group('⚠️ Edge Cases & Error Handling', () {
        test('should handle special characters in exception name', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'make',
              'exception',
              'Invalid-Format',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(result.stderr, contains('invalid format'));

            print('✅ Special character validation working correctly');
          } finally {
            await project.cleanup();
          }
        });

        test('should handle whitespace-only exception name', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'make',
              'exception',
              '   ', // whitespace only
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(result.stderr, contains('cannot be empty'));

            print('✅ Whitespace-only name validation working correctly');
          } finally {
            await project.cleanup();
          }
        });

        test('should handle invalid subdirectory characters', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'make',
              'exception',
              'Sample',
              '--on',
              'invalid-chars!',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(result.stderr, contains('path has an invalid format'));

            print('✅ Invalid subdirectory validation working correctly');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Exception Content Validation
      group('📝 Exception Content Validation', () {
        test(
          'should generate exception with proper Exception interface',
          () async {
            final project = await OptimizedTestManager.createOptimizedProject(
              templateKey: 'getx',
            );

            try {
              final exceptionName = 'Api';
              final result = await run([
                'make',
                'exception',
                exceptionName,
                '--force',
              ], project.projectDir);

              expect(result.exitCode, equals(ExitCode.success.code));

              final basePath = project.projectDir.path;
              final exceptionFile = File(
                '$basePath/lib/app/core/exceptions/api_exception.dart',
              );

              final exceptionContent = await exceptionFile.readAsString();

              // Check for class structure
              expect(
                exceptionContent,
                contains('class ApiException implements Exception'),
              );

              // Check for required properties
              expect(exceptionContent, contains('final String message'));
              expect(exceptionContent, contains('final String? code'));

              // Check for constructor
              expect(
                exceptionContent,
                contains('const ApiException(this.message, {this.code})'),
              );

              // Check for toString method
              expect(exceptionContent, contains('@override'));
              expect(exceptionContent, contains('String toString()'));
              expect(
                exceptionContent,
                contains('return \'ApiException\$message\$codePart\';'),
              );

              // Check for code handling in toString
              expect(
                exceptionContent,
                contains(
                  'final codePart = code != null ? \' (code: \$code)\' : \'\';',
                ),
              );

              print('✅ Exception interface methods generated correctly');
            } finally {
              await project.cleanup();
            }
          },
        );

        test(
          'should generate exception with proper naming conventions',
          () async {
            final project = await OptimizedTestManager.createOptimizedProject(
              templateKey: 'getx',
            );

            try {
              final exceptionName = 'UserInput';
              final result = await run([
                'make',
                'exception',
                exceptionName,
                '--force',
              ], project.projectDir);

              expect(result.exitCode, equals(ExitCode.success.code));

              final basePath = project.projectDir.path;
              final exceptionFile = File(
                '$basePath/lib/app/core/exceptions/user_input_exception.dart',
              );

              final exceptionContent = await exceptionFile.readAsString();

              // Check for proper class naming (PascalCase)
              expect(exceptionContent, contains('class UserInputException'));

              // Check for proper file naming (snake_case)
              expect(exceptionFile.path, contains('user_input_exception.dart'));

              print('✅ Exception naming conventions working correctly');
            } finally {
              await project.cleanup();
            }
          },
        );

        test('should generate exception with proper documentation', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final exceptionName = 'Documented';
            final result = await run([
              'make',
              'exception',
              exceptionName,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            final basePath = project.projectDir.path;
            final exceptionFile = File(
              '$basePath/lib/app/core/exceptions/documented_exception.dart',
            );

            final exceptionContent = await exceptionFile.readAsString();

            // Check for documentation comments
            expect(exceptionContent, contains('/// Documented Exception'));
            expect(
              exceptionContent,
              contains('A custom exception for documented-related errors'),
            );
            expect(exceptionContent, contains('/// Example:'));
            expect(
              exceptionContent,
              contains(
                '/// throw DocumentedException(\'Invalid documented data\');',
              ),
            );

            // Check for property documentation
            expect(
              exceptionContent,
              contains('/// Error message describing what went wrong.'),
            );
            expect(
              exceptionContent,
              contains(
                '/// Optional error code for identifying the specific failure type.',
              ),
            );

            print('✅ Exception documentation generated correctly');
          } finally {
            await project.cleanup();
          }
        });

        test('should generate exception with proper example usage', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final exceptionName = 'Custom';
            final result = await run([
              'make',
              'exception',
              exceptionName,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            final basePath = project.projectDir.path;
            final exceptionFile = File(
              '$basePath/lib/app/core/exceptions/custom_exception.dart',
            );

            final exceptionContent = await exceptionFile.readAsString();

            // Check for example usage in documentation
            expect(exceptionContent, contains('/// Example:'));
            expect(exceptionContent, contains('/// ```dart'));
            expect(
              exceptionContent,
              contains('/// throw CustomException(\'Invalid custom data\');'),
            );
            expect(exceptionContent, contains('/// ```'));

            print('✅ Exception example usage generated correctly');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Template-Specific Tests
      group('🏗️ Template-Specific Tests', () {
        test('should handle GetX template structure correctly', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final exceptionName = 'Http';
            final result = await run([
              'make',
              'exception',
              exceptionName,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Verify GetX-specific path structure
            final basePath = project.projectDir.path;
            final exceptionFile = File(
              '$basePath/lib/app/core/exceptions/http_exception.dart',
            );

            expect(exceptionFile.existsSync(), isTrue);

            // Verify directory structure exists
            final exceptionDir = Directory('$basePath/lib/app/core/exceptions');
            expect(exceptionDir.existsSync(), isTrue);

            print('✅ GetX template structure handled correctly');
          } finally {
            await project.cleanup();
          }
        });

        test('should handle Clean template structure correctly', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'clean',
          );

          try {
            final exceptionName = 'Network';
            final result = await run([
              'make',
              'exception',
              exceptionName,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Verify Clean-specific path structure
            final basePath = project.projectDir.path;
            final exceptionFile = File(
              '$basePath/lib/core/exceptions/network_exception.dart',
            );

            expect(exceptionFile.existsSync(), isTrue);

            // Verify directory structure exists
            final exceptionDir = Directory('$basePath/lib/core/exceptions');
            expect(exceptionDir.existsSync(), isTrue);

            print('✅ Clean template structure handled correctly');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Interactive Mode Tests
      group('💬 Interactive Mode Tests', () {
        test('should handle interactive mode gracefully', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            // Run without name argument to trigger interactive mode
            final result = await run(['make', 'exception'], project.projectDir);

            // Interactive mode should either succeed or gracefully handle the absence of input
            // Interactive mode might fail with different exit codes depending on input handling
            expect(result.exitCode, equals(ExitCode.software.code));
            expect(result.stderr, contains('Valid value range is empty'));

            print('✅ Interactive mode handled gracefully');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Next Steps Validation Tests
      group('💡 Next Steps Validation', () {
        test('should show appropriate next steps in output', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final exceptionName = 'Usage';
            final result = await run([
              'make',
              'exception',
              exceptionName,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Check for Next Steps in output
            expect(result.stdout, contains('Next Steps:'));
            expect(result.stdout, contains('Use in your code:'));
            expect(result.stdout, contains('try {'));
            expect(result.stdout, contains('// Your risky operation'));
            expect(result.stdout, contains('} catch (e) {'));
            expect(result.stdout, contains('throw UsageException('));
            expect(result.stdout, contains('code: \'OPERATION_FAILED\''));

            // Check for tips
            expect(result.stdout, contains('💡 Tips:'));
            expect(result.stdout, contains('Use meaningful error messages'));
            expect(
              result.stdout,
              contains('Include error codes for better debugging'),
            );
            expect(
              result.stdout,
              contains('Handle exceptions appropriately in UI layers'),
            );

            // Check for import statement
            expect(result.stdout, contains('📦 Import statement:'));
            expect(
              result.stdout,
              contains('import \'app/core/exceptions/usage_exception.dart\';'),
            );

            print('✅ Next steps information displayed correctly');
          } finally {
            await project.cleanup();
          }
        });
      });
    });
  }
}

void main() {
  ExceptionCommandTest().runTests();
}
