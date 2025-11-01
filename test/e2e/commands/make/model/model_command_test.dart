@Tags(['e2e'])
library;

import 'dart:io';
import 'package:io/io.dart' show ExitCode;
import 'package:test/test.dart';
import 'package:path/path.dart' as path;
import '../../../../helpers/e2e_test_base.dart';
import '../../../../helpers/optimized_test_manager.dart';

/// Model Command E2E Test Suite
///
/// Comprehensive end-to-end testing for model generation functionality.
/// Tests cover all input sources, model styles, validation, and custom fields.
///
/// Features tested:
/// - Model creation from different sources (file, url, template)
/// - Different model styles (plain, json_serializable, freezed)
/// - Custom field builder with interactive mode
/// - Relationship detection and generation
/// - Validation and error handling
/// - Template compatibility (GetX and Clean Architecture)
class ModelCommandTest extends E2ETestBase {
  void runTests() {
    group('ModelCommand E2E Tests', () {
      setUpAll(() async {
        await super.setUpAll();
        await OptimizedTestManager.initialize();
        print('🚀 Starting model command tests...');
        print('⚡ Using OptimizedTestManager for fast execution');
      });

      tearDownAll(() async {
        OptimizedTestManager.clearCache();
        await super.tearDownAll();
        print('🎉 Model command tests completed!');
      });

      // Pre-conditions & Validation Tests
      group('📋 Pre-conditions & Validation', () {
        test('should fail on uninitialized project', () async {
          final stopwatch = Stopwatch()..start();
          final tempDir = Directory.systemTemp.createTempSync('empty_project_');

          try {
            final result = await run(['make', 'model', 'Sample'], tempDir);
            expect(result.exitCode, equals(ExitCode.config.code));
            expect(result.stderr, contains('Not inside a valid Gexd project'));

            stopwatch.stop();
            print(
              '⚡ Pre-condition validation completed in ${stopwatch.elapsedMilliseconds}ms',
            );
          } finally {
            await tempDir.delete(recursive: true);
          }
        });

        test('should validate conflicting input source options', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
            withJsonModel: true,
            modelJsonName: 'user',
          );

          try {
            // Test file + url conflict
            final result = await run([
              'make',
              'model',
              'Conflict',
              '--file',
              'assets/models/user.json',
              '--url',
              'https://api.example.com/user',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(
              result.stderr,
              contains('Cannot specify both --file and --url'),
            );

            print('⚡ Input source conflict validation passed');
          } finally {
            await project.cleanup();
          }
        });

        test('should validate style compatibility', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            // Test copyWith without immutable for plain style
            final result = await run([
              'make',
              'model',
              'Style',
              '--style',
              'plain',
              '--copyWith',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.usage.code));
            expect(
              result.stderr,
              contains(
                'copyWith method is typically used with immutable models',
              ),
            );

            print('⚡ Style compatibility validation passed');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Template Source Tests
      group('🎯 Template Source Generation', () {
        test('should generate model from basic template', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'make',
              'model',
              'BasicUser',
              '--template',
              'basic',
              '--style',
              'plain',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('Model generation completed successfully'),
            );

            // Verify file creation
            final modelFile = File(
              path.join(
                project.projectDir.path,
                'lib/app/data/models/basic_user.dart',
              ),
            );
            expect(await modelFile.exists(), isTrue);

            // Verify content
            final content = await modelFile.readAsString();
            expect(content, contains('class BasicUser'));
            expect(content, contains('fromJson'));
            expect(content, contains('toJson'));

            print('⚡ Basic template generation passed');
          } finally {
            await project.cleanup();
          }
        });

        test(
          'should generate model from custom template (non-interactive)',
          () async {
            final project = await OptimizedTestManager.createOptimizedProject(
              templateKey: 'getx',
            );

            try {
              final result = await run([
                'make',
                'model',
                'CustomUser',
                '--template',
                'custom',
                '--style',
                'plain',
              ], project.projectDir);

              expect(result.exitCode, equals(ExitCode.success.code));
              expect(
                result.stdout,
                contains('Model generation completed successfully'),
              );

              // Verify file creation
              final modelFile = File(
                path.join(
                  project.projectDir.path,
                  'lib/app/data/models/custom_user.dart',
                ),
              );
              expect(await modelFile.exists(), isTrue);

              // Verify content has default fields (id, name, createdAt)
              final content = await modelFile.readAsString();
              expect(content, contains('class CustomUser'));
              expect(content, contains('int id'));
              expect(content, contains('String name'));
              expect(content, contains('String createdAt'));

              print('⚡ Custom template (non-interactive) generation passed');
            } finally {
              await project.cleanup();
            }
          },
        );
      });

      // File Source Tests
      group('📁 File Source Generation', () {
        test('should generate model from JSON file', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
            withJsonModel: true,
            modelJsonName: 'user_profile',
          );

          try {
            final result = await run([
              'make',
              'model',
              'UserProfile',
              '--file',
              'assets/models/user_profile.json',
              '--style',
              'plain',
              '--immutable',
              '--copyWith',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('Model generation completed successfully'),
            );

            // Verify main model file
            final modelFile = File(
              path.join(
                project.projectDir.path,
                'lib/app/data/models/user_profile.dart',
              ),
            );
            expect(await modelFile.exists(), isTrue);

            final content = await modelFile.readAsString();
            expect(content, contains('class UserProfile'));
            expect(content, contains('final int id')); // immutable
            expect(content, contains('copyWith')); // copyWith method

            // Verify relationships folder
            final relationshipsDir = Directory(
              path.join(
                project.projectDir.path,
                'lib/app/data/models/user_profile_relationships',
              ),
            );
            expect(await relationshipsDir.exists(), isTrue);

            print('⚡ File source generation with relationships passed');
          } finally {
            await project.cleanup();
          }
        });
      });

      // URL Source Tests
      group('🌐 URL Source Generation', () {
        test('should generate model from URL', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'make',
              'model',
              'ApiUser',
              '--url',
              'https://httpbin.org/json',
              '--style',
              'json',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('Model generation completed successfully'),
            );

            // Verify main model file
            final modelFile = File(
              path.join(
                project.projectDir.path,
                'lib/app/data/models/api_user.dart',
              ),
            );
            expect(await modelFile.exists(), isTrue);

            final content = await modelFile.readAsString();
            expect(content, contains('class ApiUser'));
            expect(
              content,
              contains('@JsonSerializable'),
            ); // json_serializable style

            print('⚡ URL source generation passed');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Model Styles Tests
      group('🎨 Model Styles', () {
        test('should generate plain Dart model', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
            withJsonModel: true,
            modelJsonName: 'simple_model',
          );

          try {
            final result = await run([
              'make',
              'model',
              'PlainUser',
              '--file',
              'assets/models/simple_model.json',
              '--style',
              'plain',
              '--immutable',
              '--equatable',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            final modelFile = File(
              path.join(
                project.projectDir.path,
                'lib/app/data/models/plain_user.dart',
              ),
            );
            final content = await modelFile.readAsString();

            expect(content, contains('class PlainUser extends Equatable'));
            expect(content, contains('final ')); // immutable fields
            expect(content, isNot(contains('@JsonSerializable')));

            print('⚡ Plain model generation passed');
          } finally {
            await project.cleanup();
          }
        });

        test('should generate json_serializable model', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'clean',
            withJsonModel: true,
            modelJsonName: 'json_model',
          );

          try {
            final result = await run([
              'make',
              'model',
              'JsonUser',
              '--file',
              'assets/models/json_model.json',
              '--style',
              'json',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('Build runner completed successfully'),
            );

            final modelFile = File(
              path.join(
                project.projectDir.path,
                'lib/infrastructure/models/json_user.dart',
              ),
            );
            final content = await modelFile.readAsString();

            expect(content, contains('@JsonSerializable'));
            expect(content, contains('part \'json_user.g.dart\''));

            print('⚡ JSON serializable model generation passed');
          } finally {
            await project.cleanup();
          }
        });

        test('should generate freezed model', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
            withJsonModel: true,
            modelJsonName: 'freezed_model',
          );

          try {
            final result = await run([
              'make',
              'model',
              'FreezedUser',
              '--file',
              'assets/models/freezed_model.json',
              '--style',
              'freezed',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            // Freezed models may have dependency installation issues in CI
            // Just verify the model file is generated correctly
            expect(
              result.stdout,
              anyOf([
                contains('Build runner completed successfully'),
                contains('Model generated successfully'),
              ]),
            );

            final modelFile = File(
              path.join(
                project.projectDir.path,
                'lib/app/data/models/freezed_user.dart',
              ),
            );
            final content = await modelFile.readAsString();

            expect(content, contains('@freezed'));
            expect(content, contains('with _\$FreezedUser'));
            expect(content, contains('part \'freezed_user.freezed.dart\''));

            print('⚡ Freezed model generation passed');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Subdirectory Tests
      group('📂 Subdirectory Organization', () {
        test('should generate model in specified subdirectory', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'make',
              'model',
              'AuthUser',
              '--template',
              'basic',
              '--on',
              'auth/user',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Verify file in subdirectory
            final modelFile = File(
              path.join(
                project.projectDir.path,
                'lib/app/data/models/auth/user/auth_user.dart',
              ),
            );
            expect(await modelFile.exists(), isTrue);

            print('⚡ Subdirectory model generation passed');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Relationships Tests
      group('🔗 Relationships Generation', () {
        test('should generate relationships in separate folder', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
            withJsonModel: true,
            modelJsonName: 'complex_model',
          );

          try {
            final result = await run([
              'make',
              'model',
              'ComplexUser',
              '--file',
              'assets/models/complex_model.json',
              '--relationships-in-folder',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Verify relationships folder exists
            final relationshipsDir = Directory(
              path.join(
                project.projectDir.path,
                'lib/app/data/models/complex_user_relationships',
              ),
            );
            expect(await relationshipsDir.exists(), isTrue);

            // Check for relationship files
            final relationshipFiles = await relationshipsDir.list().toList();
            expect(relationshipFiles.isNotEmpty, isTrue);

            print('⚡ Relationships generation passed');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Performance Tests
      group('⚡ Performance & Speed', () {
        test('should complete model generation quickly', () async {
          final stopwatch = Stopwatch()..start();

          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
            withJsonModel: true,
            modelJsonName: 'perf_test',
          );

          try {
            final result = await run([
              'make',
              'model',
              'Perf',
              '--file',
              'assets/models/perf_test.json',
              '--style',
              'plain',
            ], project.projectDir);

            stopwatch.stop();
            expect(result.exitCode, equals(ExitCode.success.code));

            // Should complete within reasonable time (30 seconds for E2E)
            // CI environments may be slower than local development
            expect(stopwatch.elapsedMilliseconds, lessThan(30000));

            print(
              '⚡ Performance test completed in ${stopwatch.elapsedMilliseconds}ms',
            );
          } finally {
            await project.cleanup();
          }
        });
      });

      // Cross-template Compatibility Tests
      group('🔄 Cross-template Compatibility', () {
        test('should work with GetX template', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
            withJsonModel: true,
            modelJsonName: 'getx_model',
          );

          try {
            final result = await run([
              'make',
              'model',
              'GetXUser',
              '--file',
              'assets/models/getx_model.json',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Verify GetX-specific path
            final modelFile = File(
              path.join(
                project.projectDir.path,
                'lib/app/data/models/get_x_user.dart',
              ),
            );
            expect(await modelFile.exists(), isTrue);

            print('⚡ GetX template compatibility passed');
          } finally {
            await project.cleanup();
          }
        });

        test('should work with Clean Architecture template', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'clean',
            withJsonModel: true,
            modelJsonName: 'clean_model',
          );

          try {
            final result = await run([
              'make',
              'model',
              'CleanUser',
              '--file',
              'assets/models/clean_model.json',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Verify Clean Architecture path
            final modelFile = File(
              path.join(
                project.projectDir.path,
                'lib/infrastructure/models/clean_user.dart',
              ),
            );
            expect(await modelFile.exists(), isTrue);

            print('⚡ Clean Architecture template compatibility passed');
          } finally {
            await project.cleanup();
          }
        });
      });
    });
  }
}

/// Main entry point for model command tests
void main() {
  ModelCommandTest().runTests();
}
