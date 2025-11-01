@Tags(['e2e'])
library;

import 'dart:io';
import 'package:io/io.dart' show ExitCode;
import 'package:test/test.dart';
import '../../../../helpers/e2e_test_base.dart';
import '../../../../helpers/optimized_test_manager.dart';

/// Middleware Command E2E Test Suite
///
/// Comprehensive end-to-end testing for middleware generation functionality.
/// Tests cover middleware creation, validation, error handling, and template compatibility.
///
/// Features tested:
/// - Middleware creation in default location
/// - Middleware creation with subdirectories (--on flag)
/// - Template compatibility (GetX and Clean Architecture)
/// - Input validation and error handling
/// - Force overwrite functionality
/// - Interactive mode handling
class MiddlewareCommandTest extends E2ETestBase {
  void runTests() {
    group('MiddlewareCommand E2E Tests', () {
      setUpAll(() async {
        await super.setUpAll();
        await OptimizedTestManager.initialize();
        print('🚀 Starting middleware command tests...');
        print('⚡ Using OptimizedTestManager for fast execution');
      });

      tearDownAll(() async {
        OptimizedTestManager.clearCache();
        await super.tearDownAll();
        print('🎉 Middleware command tests completed!');
      });

      // Pre-conditions & Validation Tests
      group('📋 Pre-conditions & Validation', () {
        test('should fail on uninitialized project', () async {
          final stopwatch = Stopwatch()..start();
          final tempDir = Directory.systemTemp.createTempSync('empty_project_');

          try {
            final result = await run(['make', 'middleware', 'Sample'], tempDir);
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
              'middleware',
              '--help',
            ], project.projectDir);
            expect(result.exitCode, equals(ExitCode.success.code));
            expect(result.stdout, contains('Generate middleware files'));
            expect(result.stdout, contains('--on'));
            expect(result.stdout, contains('--force'));
            expect(result.stdout, contains('Examples:'));
            print('✅ Help documentation verified');
          } finally {
            await project.cleanup();
          }
        });

        test('should validate middleware name format', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );
          try {
            final result = await run([
              'make',
              'middleware',
              'invalidname',
              '--force',
            ], project.projectDir);
            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(result.stderr, contains('invalid format'));
            print('✅ Middleware name validation working correctly');
          } finally {
            await project.cleanup();
          }
        });

        test('should reject middleware names ending with "Middleware"', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );
          try {
            final result = await run([
              'make',
              'middleware',
              'AuthMiddleware',
              '--force',
            ], project.projectDir);
            // Now middleware names ending with "Middleware" should be rejected as reserved words
            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(result.stderr, contains('should not end with "middleware"'));
            print('✅ Middleware suffix validation working correctly');
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
              'middleware',
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

      // Basic Middleware Creation Tests
      group('🎯 Basic Middleware Creation', () {
        test(
          'should create middleware in default location - GetX template',
          () async {
            final project = await OptimizedTestManager.createOptimizedProject(
              templateKey: 'getx',
            );

            try {
              final middlewareName = 'Auth';
              final result = await run([
                'make',
                'middleware',
                middlewareName,
                '--force',
              ], project.projectDir);

              expect(result.exitCode, equals(ExitCode.success.code));
              expect(
                result.stdout,
                contains('Generated middleware files successful'),
              );

              // Check for middleware file in GetX template structure
              final basePath = project.projectDir.path;
              final middlewareFile = File(
                '$basePath/lib/app/core/middleware/auth_middleware.dart',
              );

              expect(middlewareFile.existsSync(), isTrue);

              // Check middleware content
              final middlewareContent = await middlewareFile.readAsString();
              expect(middlewareContent, contains('class AuthMiddleware'));
              expect(middlewareContent, contains('extends GetMiddleware'));
              expect(middlewareContent, contains('final int _priority'));
              expect(middlewareContent, contains('RouteSettings? redirect'));
              expect(
                middlewareContent,
                contains('GetPageBuilder? onPageBuildStart'),
              );
              expect(middlewareContent, contains('Widget onPageBuilt'));
              expect(middlewareContent, contains('void onPageDispose'));

              print('✅ Middleware created successfully in GetX template');
            } finally {
              await project.cleanup();
            }
          },
        );

        test(
          'should create middleware in default location - Clean template',
          () async {
            final project = await OptimizedTestManager.createOptimizedProject(
              templateKey: 'clean',
            );

            try {
              final middlewareName = 'Security';
              final result = await run([
                'make',
                'middleware',
                middlewareName,
                '--force',
              ], project.projectDir);

              expect(result.exitCode, equals(ExitCode.success.code));

              // Check for middleware file in Clean template structure
              final basePath = project.projectDir.path;
              final middlewareFile = File(
                '$basePath/lib/core/middleware/security_middleware.dart',
              );

              expect(middlewareFile.existsSync(), isTrue);

              // Check middleware content
              final middlewareContent = await middlewareFile.readAsString();
              expect(middlewareContent, contains('class SecurityMiddleware'));
              expect(middlewareContent, contains('extends GetMiddleware'));

              print('✅ Middleware created successfully in Clean template');
            } finally {
              await project.cleanup();
            }
          },
        );
      });

      // Middleware Creation with Subdirectories
      group('📁 Middleware Creation with Subdirectories', () {
        test('should create middleware in single subdirectory', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final middlewareName = 'Login';
            final subdirectory = 'auth';
            final result = await run([
              'make',
              'middleware',
              middlewareName,
              '--on',
              subdirectory,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Check for middleware file in subdirectory
            final basePath = project.projectDir.path;
            final middlewareFile = File(
              '$basePath/lib/app/core/middleware/auth/login_middleware.dart',
            );

            expect(middlewareFile.existsSync(), isTrue);

            // Check middleware content
            final middlewareContent = await middlewareFile.readAsString();
            expect(middlewareContent, contains('class LoginMiddleware'));
            expect(middlewareContent, contains('extends GetMiddleware'));

            print('✅ Middleware created successfully in subdirectory');
          } finally {
            await project.cleanup();
          }
        });

        test('should create middleware in nested subdirectories', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final middlewareName = 'Permission';
            final subdirectory = 'auth/guards';
            final result = await run([
              'make',
              'middleware',
              middlewareName,
              '--on',
              subdirectory,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Check for middleware file in nested subdirectory
            final basePath = project.projectDir.path;
            final middlewareFile = File(
              '$basePath/lib/app/core/middleware/auth/guards/permission_middleware.dart',
            );

            expect(middlewareFile.existsSync(), isTrue);

            // Check middleware content
            final middlewareContent = await middlewareFile.readAsString();
            expect(middlewareContent, contains('class PermissionMiddleware'));
            expect(middlewareContent, contains('extends GetMiddleware'));

            print('✅ Middleware created successfully in nested subdirectories');
          } finally {
            await project.cleanup();
          }
        });

        test('should handle maximum subdirectory depth', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final middlewareName = 'Deep';
            final subdirectory = 'level1/level2/level3';
            final result = await run([
              'make',
              'middleware',
              middlewareName,
              '--on',
              subdirectory,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Check for middleware file at maximum depth
            final basePath = project.projectDir.path;
            final middlewareFile = File(
              '$basePath/lib/app/core/middleware/level1/level2/level3/deep_middleware.dart',
            );

            expect(middlewareFile.existsSync(), isTrue);

            print('✅ Middleware created at maximum subdirectory depth');
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
            final middlewareName = 'Existing';

            // Create middleware first time
            var result = await run([
              'make',
              'middleware',
              middlewareName,
              '--force',
            ], project.projectDir);
            expect(result.exitCode, equals(ExitCode.success.code));

            // Try to create same middleware without --force
            result = await run([
              'make',
              'middleware',
              middlewareName,
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
            final middlewareName = 'Overwrite';

            // Create middleware first time
            var result = await run([
              'make',
              'middleware',
              middlewareName,
              '--force',
            ], project.projectDir);
            expect(result.exitCode, equals(ExitCode.success.code));

            // Overwrite with --force flag
            result = await run([
              'make',
              'middleware',
              middlewareName,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('Generated middleware files successful'),
            );

            print('✅ Force overwrite working correctly');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Edge Cases & Error Handling
      group('⚠️ Edge Cases & Error Handling', () {
        test('should handle special characters in middleware name', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'make',
              'middleware',
              'Test-Middleware',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(result.stderr, contains('invalid format'));

            print('✅ Special character validation working correctly');
          } finally {
            await project.cleanup();
          }
        });

        test('should handle whitespace-only middleware name', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'make',
              'middleware',
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
              'middleware',
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

      // Middleware Content Validation
      group('📝 Middleware Content Validation', () {
        test(
          'should generate middleware with proper GetMiddleware methods',
          () async {
            final project = await OptimizedTestManager.createOptimizedProject(
              templateKey: 'getx',
            );

            try {
              final middlewareName = 'Route';
              final result = await run([
                'make',
                'middleware',
                middlewareName,
                '--force',
              ], project.projectDir);

              expect(result.exitCode, equals(ExitCode.success.code));

              final basePath = project.projectDir.path;
              final middlewareFile = File(
                '$basePath/lib/app/core/middleware/route_middleware.dart',
              );

              final middlewareContent = await middlewareFile.readAsString();

              // Check for class structure
              expect(
                middlewareContent,
                contains('class RouteMiddleware extends GetMiddleware'),
              );

              // Check for priority property
              expect(middlewareContent, contains('final int _priority'));

              // Check for middleware methods
              expect(middlewareContent, contains('RouteSettings? redirect'));
              expect(
                middlewareContent,
                contains('GetPageBuilder? onPageBuildStart'),
              );
              expect(middlewareContent, contains('Widget onPageBuilt'));
              expect(middlewareContent, contains('void onPageDispose'));

              // Check for constructor with priority parameter
              expect(
                middlewareContent,
                contains(
                  'RouteMiddleware({int priority = 1}) : _priority = priority;',
                ),
              );

              // Check for super method calls
              expect(
                middlewareContent,
                contains('super.onPageBuildStart(page)'),
              );
              expect(middlewareContent, contains('super.onPageDispose()'));

              print('✅ Middleware methods generated correctly');
            } finally {
              await project.cleanup();
            }
          },
        );

        test(
          'should generate middleware with proper naming conventions',
          () async {
            final project = await OptimizedTestManager.createOptimizedProject(
              templateKey: 'getx',
            );

            try {
              final middlewareName = 'Navigation';
              final result = await run([
                'make',
                'middleware',
                middlewareName,
                '--force',
              ], project.projectDir);

              expect(result.exitCode, equals(ExitCode.success.code));

              final basePath = project.projectDir.path;
              final middlewareFile = File(
                '$basePath/lib/app/core/middleware/navigation_middleware.dart',
              );

              final middlewareContent = await middlewareFile.readAsString();

              // Check for proper class naming
              expect(middlewareContent, contains('class NavigationMiddleware'));

              // Check for proper file naming (snake_case)
              expect(
                middlewareFile.path,
                contains('navigation_middleware.dart'),
              );

              print('✅ Middleware naming conventions working correctly');
            } finally {
              await project.cleanup();
            }
          },
        );

        test('should generate middleware with proper documentation', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final middlewareName = 'Documented';
            final result = await run([
              'make',
              'middleware',
              middlewareName,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            final basePath = project.projectDir.path;
            final middlewareFile = File(
              '$basePath/lib/app/core/middleware/documented_middleware.dart',
            );

            final middlewareContent = await middlewareFile.readAsString();

            // Check for documentation comments
            expect(middlewareContent, contains('/// DocumentedMiddleware'));
            expect(
              middlewareContent,
              contains('Middleware class for route interception'),
            );
            expect(
              middlewareContent,
              contains('You can use priority to control the execution order'),
            );
            expect(
              middlewareContent,
              contains('The lower the priority number, the earlier it runs'),
            );

            print('✅ Middleware documentation generated correctly');
          } finally {
            await project.cleanup();
          }
        });

        test(
          'should generate middleware with example redirect logic',
          () async {
            final project = await OptimizedTestManager.createOptimizedProject(
              templateKey: 'getx',
            );

            try {
              final middlewareName = 'Guard';
              final result = await run([
                'make',
                'middleware',
                middlewareName,
                '--force',
              ], project.projectDir);

              expect(result.exitCode, equals(ExitCode.success.code));

              final basePath = project.projectDir.path;
              final middlewareFile = File(
                '$basePath/lib/app/core/middleware/guard_middleware.dart',
              );

              final middlewareContent = await middlewareFile.readAsString();

              // Check for example redirect logic in comments
              expect(middlewareContent, contains('// Example:'));
              expect(
                middlewareContent,
                contains('// if (!AuthService.to.isLoggedIn)'),
              );
              expect(
                middlewareContent,
                contains("//   return const RouteSettings(name: '/login');"),
              );

              // Check for example logging comments
              expect(
                middlewareContent,
                contains("// print('Building page for \$route');"),
              );
              expect(
                middlewareContent,
                contains("// print('Disposed middleware for \$route');"),
              );

              // Check for example wrapper comment
              expect(
                middlewareContent,
                contains('// Add wrappers or decorations if needed'),
              );

              print('✅ Middleware example code generated correctly');
            } finally {
              await project.cleanup();
            }
          },
        );
      });

      // Template-Specific Tests
      group('🏗️ Template-Specific Tests', () {
        test('should handle GetX template structure correctly', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final middlewareName = 'Api';
            final result = await run([
              'make',
              'middleware',
              middlewareName,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Verify GetX-specific path structure
            final basePath = project.projectDir.path;
            final middlewareFile = File(
              '$basePath/lib/app/core/middleware/api_middleware.dart',
            );

            expect(middlewareFile.existsSync(), isTrue);

            // Verify directory structure exists
            final middlewareDir = Directory(
              '$basePath/lib/app/core/middleware',
            );
            expect(middlewareDir.existsSync(), isTrue);

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
            final middlewareName = 'Cache';
            final result = await run([
              'make',
              'middleware',
              middlewareName,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Verify Clean-specific path structure
            final basePath = project.projectDir.path;
            final middlewareFile = File(
              '$basePath/lib/core/middleware/cache_middleware.dart',
            );

            expect(middlewareFile.existsSync(), isTrue);

            // Verify directory structure exists
            final middlewareDir = Directory('$basePath/lib/core/middleware');
            expect(middlewareDir.existsSync(), isTrue);

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
            final result = await run([
              'make',
              'middleware',
            ], project.projectDir);

            // Interactive mode should either succeed or gracefully handle the absence of input
            // Interactive mode might fail with different exit codes depending on input handling
            expect(
              result.exitCode,
              anyOf([
                equals(ExitCode.success.code),
                equals(ExitCode.usage.code),
                equals(70), // Specific exit code for interactive prompt errors
              ]),
            );

            print('✅ Interactive mode handled gracefully');
          } finally {
            await project.cleanup();
          }
        });
      });
    });
  }
}

void main() {
  MiddlewareCommandTest().runTests();
}
