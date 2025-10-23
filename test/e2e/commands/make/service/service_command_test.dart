@Tags(['e2e'])
library;

import 'dart:io';
import 'package:io/io.dart' show ExitCode;
import 'package:test/test.dart';
import '../../../../helpers/e2e_test_base.dart';
import '../../../../helpers/optimized_test_manager.dart';

/// Service Command E2E Test Suite
///
/// Comprehensive end-to-end testing for service generation functionality.
/// Tests cover service creation, validation, error handling, and template compatibility.
///
/// Features tested:
/// - Service creation in default location
/// - Service creation with subdirectories (--on flag)
/// - Template compatibility (GetX and Clean Architecture)
/// - Input validation and error handling
/// - Force overwrite functionality
/// - Interactive mode handling
class ServiceCommandTest extends E2ETestBase {
  void runTests() {
    group('ServiceCommand E2E Tests', () {
      setUpAll(() async {
        await super.setUpAll();
        await OptimizedTestManager.initialize();
        print('🚀 Starting service command tests...');
        print('⚡ Using OptimizedTestManager for fast execution');
      });

      tearDownAll(() async {
        OptimizedTestManager.clearCache();
        await super.tearDownAll();
        print('🎉 Service command tests completed!');
      });

      // Pre-conditions & Validation Tests
      group('📋 Pre-conditions & Validation', () {
        test('should fail on uninitialized project', () async {
          final stopwatch = Stopwatch()..start();
          final tempDir = Directory.systemTemp.createTempSync('empty_project_');

          try {
            final result = await run(['make', 'service', 'Test'], tempDir);
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
              'service',
              '--help',
            ], project.projectDir);
            expect(result.exitCode, equals(ExitCode.success.code));
            expect(result.stdout, contains('Generate service files'));
            expect(result.stdout, contains('--on'));
            expect(result.stdout, contains('--force'));
            expect(result.stdout, contains('Examples:'));
            print('✅ Help documentation verified');
          } finally {
            await project.cleanup();
          }
        });

        test('should validate service name format', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );
          try {
            final result = await run([
              'make',
              'service',
              'invalidname',
              '--force',
            ], project.projectDir);
            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(result.stderr, contains('invalid format'));
            print('✅ Service name validation working correctly');
          } finally {
            await project.cleanup();
          }
        });

        test('should reject service names ending with "Service"', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );
          try {
            final result = await run([
              'make',
              'service',
              'ApiService',
              '--force',
            ], project.projectDir);
            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(result.stderr, contains('should not end with "service"'));
            print('✅ Service suffix validation working correctly');
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
              'service',
              'Test',
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

      // Basic Service Creation Tests
      group('🎯 Basic Service Creation', () {
        test(
          'should create service in default location - GetX template',
          () async {
            final project = await OptimizedTestManager.createOptimizedProject(
              templateKey: 'getx',
            );

            try {
              final serviceName = 'Api';
              final result = await run([
                'make',
                'service',
                serviceName,
                '--force',
              ], project.projectDir);

              expect(result.exitCode, equals(ExitCode.success.code));
              expect(
                result.stdout,
                contains('Generated service files successful'),
              );

              // Check for service file in GetX template structure
              final basePath = project.projectDir.path;
              final serviceFile = File(
                '$basePath/lib/app/data/services/api_service.dart',
              );

              expect(serviceFile.existsSync(), isTrue);

              // Check service content
              final serviceContent = await serviceFile.readAsString();
              expect(serviceContent, contains('class ApiService'));
              expect(serviceContent, contains('extends GetxService'));
              expect(serviceContent, contains('onInit()'));
              expect(serviceContent, contains('onReady()'));
              expect(serviceContent, contains('onClose()'));

              print('✅ Service created successfully in GetX template');
            } finally {
              await project.cleanup();
            }
          },
        );

        test(
          'should create service in default location - Clean template',
          () async {
            final project = await OptimizedTestManager.createOptimizedProject(
              templateKey: 'clean',
            );

            try {
              final serviceName = 'Storage';
              final result = await run([
                'make',
                'service',
                serviceName,
                '--force',
              ], project.projectDir);

              expect(result.exitCode, equals(ExitCode.success.code));

              // Check for service file in Clean template structure (should be in infrastructure/services)
              final basePath = project.projectDir.path;
              final serviceFile = File(
                '$basePath/lib/infrastructure/services/storage_service.dart',
              );

              expect(serviceFile.existsSync(), isTrue); // Check service content
              final serviceContent = await serviceFile.readAsString();
              expect(serviceContent, contains('class StorageService'));
              expect(serviceContent, contains('extends GetxService'));

              print('✅ Service created successfully in Clean template');
            } finally {
              await project.cleanup();
            }
          },
        );
      });

      // Service Creation with Subdirectories
      group('📁 Service Creation with Subdirectories', () {
        test('should create service in single subdirectory', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final serviceName = 'Auth';
            final subdirectory = 'user';
            final result = await run([
              'make',
              'service',
              serviceName,
              '--on',
              subdirectory,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Check for service file in subdirectory
            final basePath = project.projectDir.path;
            final serviceFile = File(
              '$basePath/lib/app/data/services/user/auth_service.dart',
            );

            expect(serviceFile.existsSync(), isTrue);

            // Check service content
            final serviceContent = await serviceFile.readAsString();
            expect(serviceContent, contains('class AuthService'));
            expect(serviceContent, contains('extends GetxService'));

            print('✅ Service created successfully in subdirectory');
          } finally {
            await project.cleanup();
          }
        });

        test('should create service in nested subdirectories', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final serviceName = 'Payment';
            final subdirectory = 'user/billing';
            final result = await run([
              'make',
              'service',
              serviceName,
              '--on',
              subdirectory,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Check for service file in nested subdirectory
            final basePath = project.projectDir.path;
            final serviceFile = File(
              '$basePath/lib/app/data/services/user/billing/payment_service.dart',
            );

            expect(serviceFile.existsSync(), isTrue);

            // Check service content
            final serviceContent = await serviceFile.readAsString();
            expect(serviceContent, contains('class PaymentService'));
            expect(serviceContent, contains('extends GetxService'));

            print('✅ Service created successfully in nested subdirectories');
          } finally {
            await project.cleanup();
          }
        });

        test('should handle maximum subdirectory depth', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final serviceName = 'Deep';
            final subdirectory = 'level1/level2/level3';
            final result = await run([
              'make',
              'service',
              serviceName,
              '--on',
              subdirectory,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Check for service file at maximum depth
            final basePath = project.projectDir.path;
            final serviceFile = File(
              '$basePath/lib/app/data/services/level1/level2/level3/deep_service.dart',
            );

            expect(serviceFile.existsSync(), isTrue);

            print('✅ Service created at maximum subdirectory depth');
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
            final serviceName = 'Existing';

            // Create service first time
            var result = await run([
              'make',
              'service',
              serviceName,
              '--force',
            ], project.projectDir);
            expect(result.exitCode, equals(ExitCode.success.code));

            // Try to create same service without --force
            result = await run([
              'make',
              'service',
              serviceName,
            ], project.projectDir);

            // Should either prompt or inform about existing file
            expect(
              result.exitCode,
              anyOf([
                equals(ExitCode.success.code),
                equals(ExitCode.cantCreate.code),
              ]),
            );

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
            final serviceName = 'Overwrite';

            // Create service first time
            var result = await run([
              'make',
              'service',
              serviceName,
              '--force',
            ], project.projectDir);
            expect(result.exitCode, equals(ExitCode.success.code));

            // Overwrite with --force flag
            result = await run([
              'make',
              'service',
              serviceName,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('Generated service files successful'),
            );

            print('✅ Force overwrite working correctly');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Edge Cases & Error Handling
      group('⚠️ Edge Cases & Error Handling', () {
        test('should handle special characters in service name', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'make',
              'service',
              'Test-Service',
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(result.stderr, contains('invalid format'));

            print('✅ Special character validation working correctly');
          } finally {
            await project.cleanup();
          }
        });

        test('should handle whitespace-only service name', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'make',
              'service',
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
              'service',
              'Test',
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

      // Service Content Validation
      group('📝 Service Content Validation', () {
        test(
          'should generate service with proper GetX lifecycle methods',
          () async {
            final project = await OptimizedTestManager.createOptimizedProject(
              templateKey: 'getx',
            );

            try {
              final serviceName = 'Lifecycle';
              final result = await run([
                'make',
                'service',
                serviceName,
                '--force',
              ], project.projectDir);

              expect(result.exitCode, equals(ExitCode.success.code));

              final basePath = project.projectDir.path;
              final serviceFile = File(
                '$basePath/lib/app/data/services/lifecycle_service.dart',
              );

              final serviceContent = await serviceFile.readAsString();

              // Check for class structure
              expect(
                serviceContent,
                contains('class LifecycleService extends GetxService'),
              );

              // Check for lifecycle methods
              expect(serviceContent, contains('void onInit()'));
              expect(serviceContent, contains('void onReady()'));
              expect(serviceContent, contains('void onClose()'));

              // Check for proper method calls
              expect(serviceContent, contains('super.onInit()'));
              expect(serviceContent, contains('super.onReady()'));
              expect(serviceContent, contains('super.onClose()'));

              print('✅ Service lifecycle methods generated correctly');
            } finally {
              await project.cleanup();
            }
          },
        );

        test(
          'should generate service with proper naming conventions',
          () async {
            final project = await OptimizedTestManager.createOptimizedProject(
              templateKey: 'getx',
            );

            try {
              final serviceName = 'NetworkManager';
              final result = await run([
                'make',
                'service',
                serviceName,
                '--force',
              ], project.projectDir);

              expect(result.exitCode, equals(ExitCode.success.code));

              final basePath = project.projectDir.path;
              final serviceFile = File(
                '$basePath/lib/app/data/services/network_manager_service.dart',
              );

              final serviceContent = await serviceFile.readAsString();

              // Check for proper class naming
              expect(serviceContent, contains('class NetworkManagerService'));

              // Check for proper file naming (snake_case)
              expect(
                serviceFile.path,
                contains('network_manager_service.dart'),
              );

              print('✅ Service naming conventions working correctly');
            } finally {
              await project.cleanup();
            }
          },
        );

        test('should generate service with proper documentation', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final serviceName = 'Documented';
            final result = await run([
              'make',
              'service',
              serviceName,
              '--force',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            final basePath = project.projectDir.path;
            final serviceFile = File(
              '$basePath/lib/app/data/services/documented_service.dart',
            );

            final serviceContent = await serviceFile.readAsString();

            // Check for documentation comments
            expect(serviceContent, contains('/// Documented Service'));
            expect(
              serviceContent,
              contains('Business logic and state management'),
            );
            expect(
              serviceContent,
              contains('Injected using Get.put() or Get.lazyPut()'),
            );

            print('✅ Service documentation generated correctly');
          } finally {
            await project.cleanup();
          }
        });
      });
    });
  }
}

void main() {
  ServiceCommandTest().runTests();
}
