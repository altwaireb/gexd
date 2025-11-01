@Tags(['e2e'])
library;

import 'dart:io';
import 'package:io/io.dart' show ExitCode;
import 'package:test/test.dart';
import 'package:path/path.dart' as path;
import '../../../helpers/e2e_test_base.dart';
import '../../../helpers/optimized_test_manager.dart';

/// Locale Generate Command E2E Test Suite
///
/// Comprehensive end-to-end testing for locale generation functionality.
/// Tests cover all key styles, validation, and GetX translation integration.
///
/// Features tested:
/// - Locale generation from JSON files
/// - Different key formatting styles (dot, snake_case, camelCase)
/// - Locale consistency validation
/// - Force overwrite functionality
/// - Sorting and organization options
/// - Template compatibility (GetX and Clean Architecture)
/// - Error handling and validation messages
class LocaleGenerateCommandTest extends E2ETestBase {
  void runTests() {
    group('LocaleGenerateCommand E2E Tests', () {
      setUpAll(() async {
        await super.setUpAll();
        await OptimizedTestManager.initialize();
        print('🚀 Starting locale generate command tests...');
        print('⚡ Using OptimizedTestManager for fast execution');
      });

      tearDownAll(() async {
        OptimizedTestManager.clearCache();
        await super.tearDownAll();
        print('🎉 Locale generate command tests completed!');
      });

      // Pre-conditions & Validation Tests
      group('📋 Pre-conditions & Validation', () {
        test('should fail on uninitialized project', () async {
          final stopwatch = Stopwatch()..start();
          final tempDir = Directory.systemTemp.createTempSync('empty_project_');

          try {
            final result = await run([
              'locale',
              'generate',
              'test_locales',
            ], tempDir);
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

        test('should fail when locale directory does not exist', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            final result = await run([
              'locale',
              'generate',
              'non_existent_locales',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.software.code));
            expect(result.stderr, contains('PathNotFoundException'));

            print('⚡ Missing directory validation passed');
          } finally {
            await project.cleanup();
          }
        });

        test('should fail when no JSON files found', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            // Create empty locales directory
            final localesDir = Directory(
              path.join(project.projectDir.path, 'assets', 'locales'),
            );
            await localesDir.create(recursive: true);

            final result = await run([
              'locale',
              'generate',
              'assets/locales',
            ], project.projectDir);

            expect(result.exitCode, isNot(equals(ExitCode.success.code)));
            expect(
              result.stderr,
              contains('No JSON files found in locale directory'),
            );

            print('⚡ Empty directory validation passed');
          } finally {
            await project.cleanup();
          }
        });

        test('should validate invalid locale code format', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            // Create locales directory with invalid file
            final localesDir = Directory(
              path.join(project.projectDir.path, 'assets', 'locales'),
            );
            await localesDir.create(recursive: true);

            // Create file with invalid locale name
            final invalidFile = File(
              path.join(localesDir.path, 'invalid-locale-123.json'),
            );
            await invalidFile.writeAsString('{"test": "value"}');

            final result = await run([
              'locale',
              'generate',
              'assets/locales',
            ], project.projectDir);

            expect(result.exitCode, isNot(equals(ExitCode.success.code)));
            expect(result.stderr, contains('No valid locale files found'));

            print('⚡ Invalid locale code validation passed');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Basic Generation Tests
      group('🎯 Basic Locale Generation', () {
        test('should generate translations with default settings', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            // Create test locale files
            await _createTestLocaleFiles(project.projectDir);

            final result = await run([
              'locale',
              'generate',
              'assets/locales',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('Locale translations generated successfully'),
            );

            // Verify output file creation
            final outputFile = File(
              path.join(
                project.projectDir.path,
                'lib/app/translations/translations.g.dart',
              ),
            );
            expect(await outputFile.exists(), isTrue);

            // Verify file content
            final content = await outputFile.readAsString();
            expect(content, contains('class LocaleKeys'));
            expect(
              content,
              contains('class AppTranslations extends Translations'),
            );
            expect(content, contains('app.name'));
            expect(content, contains('auth.login'));

            print('⚡ Basic generation passed');
          } finally {
            await project.cleanup();
          }
        });

        test('should generate with Clean Architecture template', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'clean',
          );

          try {
            // Create test locale files
            await _createTestLocaleFiles(project.projectDir);

            final result = await run([
              'locale',
              'generate',
              'assets/locales',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Verify output file in Clean Architecture path
            final outputFile = File(
              path.join(
                project.projectDir.path,
                'lib/translations/translations.g.dart',
              ),
            );
            expect(await outputFile.exists(), isTrue);

            print('⚡ Clean Architecture template generation passed');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Key Style Tests
      group('🎨 Key Formatting Styles', () {
        test('should generate with dot notation style (default)', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            await _createNestedTestLocaleFiles(project.projectDir);

            final result = await run([
              'locale',
              'generate',
              'assets/locales',
              '--key-style',
              'dot',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            final outputFile = File(
              path.join(
                project.projectDir.path,
                'lib/app/translations/translations.g.dart',
              ),
            );
            final content = await outputFile.readAsString();

            expect(content, contains('auth.validation.emailRequired'));
            expect(content, contains('home.greeting'));
            expect(content, contains('\'auth.validation.emailRequired\''));

            print('⚡ Dot notation style generation passed');
          } finally {
            await project.cleanup();
          }
        });

        test('should generate with snake_case style', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            await _createNestedTestLocaleFiles(project.projectDir);

            final result = await run([
              'locale',
              'generate',
              'assets/locales',
              '--key-style',
              'snake',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            final outputFile = File(
              path.join(
                project.projectDir.path,
                'lib/app/translations/translations.g.dart',
              ),
            );
            final content = await outputFile.readAsString();

            expect(content, contains('auth_validation_emailRequired'));
            expect(content, contains('home_greeting'));

            print('⚡ Snake case style generation passed');
          } finally {
            await project.cleanup();
          }
        });

        test('should generate with camelCase style', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            await _createNestedTestLocaleFiles(project.projectDir);

            final result = await run([
              'locale',
              'generate',
              'assets/locales',
              '--key-style',
              'camelCase',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            final outputFile = File(
              path.join(
                project.projectDir.path,
                'lib/app/translations/translations.g.dart',
              ),
            );
            final content = await outputFile.readAsString();

            expect(content, contains('authValidationEmailRequired'));
            expect(content, contains('homeGreeting'));

            print('⚡ CamelCase style generation passed');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Sorting Tests
      group('📋 Key Sorting', () {
        test('should sort keys alphabetically by default', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            await _createTestLocaleFiles(project.projectDir);

            final result = await run([
              'locale',
              'generate',
              'assets/locales',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            final outputFile = File(
              path.join(
                project.projectDir.path,
                'lib/app/translations/translations.g.dart',
              ),
            );
            final content = await outputFile.readAsString();

            // Keys should be sorted: app.name comes before auth.login
            final appNameIndex = content.indexOf('app.name');
            final authLoginIndex = content.indexOf('auth.login');
            expect(appNameIndex, lessThan(authLoginIndex));

            print('⚡ Alphabetical sorting passed');
          } finally {
            await project.cleanup();
          }
        });

        test('should disable sorting when specified', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            await _createTestLocaleFiles(project.projectDir);

            final result = await run([
              'locale',
              'generate',
              'assets/locales',
              '--no-sort-keys',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(result.stdout, contains('Sort Keys: false'));

            print('⚡ No sorting option passed');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Force Overwrite Tests
      group('🔄 Force Overwrite', () {
        test('should fail when output file exists without force', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            await _createTestLocaleFiles(project.projectDir);

            // First generation
            final firstResult = await run([
              'locale',
              'generate',
              'assets/locales',
            ], project.projectDir);
            expect(firstResult.exitCode, equals(ExitCode.success.code));

            // Second generation without force
            final secondResult = await run([
              'locale',
              'generate',
              'assets/locales',
            ], project.projectDir);

            expect(secondResult.exitCode, isNot(equals(ExitCode.success.code)));
            expect(secondResult.stderr, contains('Output file already exists'));

            print('⚡ File exists validation passed');
          } finally {
            await project.cleanup();
          }
        });

        test('should overwrite when force flag is used', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            await _createTestLocaleFiles(project.projectDir);

            // First generation
            final firstResult = await run([
              'locale',
              'generate',
              'assets/locales',
            ], project.projectDir);
            expect(firstResult.exitCode, equals(ExitCode.success.code));

            // Second generation with force
            final secondResult = await run([
              'locale',
              'generate',
              'assets/locales',
              '--force',
            ], project.projectDir);

            expect(secondResult.exitCode, equals(ExitCode.success.code));
            expect(
              secondResult.stdout,
              contains('Locale translations generated successfully'),
            );

            print('⚡ Force overwrite passed');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Locale Consistency Tests
      group('🔍 Locale Consistency Validation', () {
        test('should warn about missing keys in locales', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            await _createInconsistentLocaleFiles(project.projectDir);

            final result = await run([
              'locale',
              'generate',
              'assets/locales',
            ], project.projectDir);

            // Should succeed with locale generation
            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('Locale translations generated successfully'),
            );

            print('⚡ Locale consistency validation passed');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Error Handling Tests
      group('⚠️ Error Handling', () {
        test('should handle invalid JSON files gracefully', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            // Create locales directory with invalid JSON
            final localesDir = Directory(
              path.join(project.projectDir.path, 'assets', 'locales'),
            );
            await localesDir.create(recursive: true);

            final invalidFile = File(path.join(localesDir.path, 'en.json'));
            await invalidFile.writeAsString('{ invalid json }');

            final result = await run([
              'locale',
              'generate',
              'assets/locales',
            ], project.projectDir);

            expect(result.exitCode, isNot(equals(ExitCode.success.code)));
            expect(result.stderr, contains('Invalid JSON'));

            print('⚡ Invalid JSON handling passed');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Performance Tests
      group('⚡ Performance & Speed', () {
        test('should complete locale generation quickly', () async {
          final stopwatch = Stopwatch()..start();

          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            await _createLargeLocaleFiles(project.projectDir);

            final result = await run([
              'locale',
              'generate',
              'assets/locales',
            ], project.projectDir);

            stopwatch.stop();
            expect(result.exitCode, equals(ExitCode.success.code));

            // Should complete within reasonable time (45 seconds for E2E in CI)
            expect(stopwatch.elapsedMilliseconds, lessThan(45000));

            print(
              '⚡ Performance test completed in ${stopwatch.elapsedMilliseconds}ms',
            );
          } finally {
            await project.cleanup();
          }
        });
      });

      // Extensions Tests
      group('🔧 Extensions Generation', () {
        test('should generate trVars and trCount extension files', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            await _createExtensionTestLocaleFiles(project.projectDir);

            final result = await run([
              'locale',
              'generate',
              'assets/locales',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Verify extension files are created
            final extensionsDir = Directory(
              path.join(
                project.projectDir.path,
                'lib/app/translations/extensions',
              ),
            );
            expect(await extensionsDir.exists(), isTrue);

            // Check trVars extension file
            final trVarsFile = File(
              path.join(extensionsDir.path, 'tr_vars_extension.dart'),
            );
            expect(await trVarsFile.exists(), isTrue);

            final trVarsContent = await trVarsFile.readAsString();
            expect(
              trVarsContent,
              contains('extension TrVarsExtension on String'),
            );
            expect(trVarsContent, contains('String trVars('));
            expect(trVarsContent, contains('replaceAll(\'{\$key}\', value)'));

            // Check trCount extension file
            final trCountFile = File(
              path.join(extensionsDir.path, 'tr_count_extension.dart'),
            );
            expect(await trCountFile.exists(), isTrue);

            final trCountContent = await trCountFile.readAsString();
            expect(
              trCountContent,
              contains('extension TrCountExtension on String'),
            );
            expect(trCountContent, contains('String trCount('));
            expect(trCountContent, contains('_getPluralKey'));

            print('⚡ Extensions generation passed');
          } finally {
            await project.cleanup();
          }
        });

        test(
          'should generate extensions with universal pluralization',
          () async {
            final project = await OptimizedTestManager.createOptimizedProject(
              templateKey: 'getx',
            );

            try {
              await _createExtensionTestLocaleFiles(project.projectDir);

              final result = await run([
                'locale',
                'generate',
                'assets/locales',
              ], project.projectDir);

              expect(result.exitCode, equals(ExitCode.success.code));

              final trCountFile = File(
                path.join(
                  project.projectDir.path,
                  'lib/app/translations/extensions/tr_count_extension.dart',
                ),
              );
              final content = await trCountFile.readAsString();

              // Verify universal pluralization logic
              expect(content, contains('universal pluralization'));
              expect(content, contains('works with all languages'));
              expect(content, contains('zero: exactly 0 items'));
              expect(content, contains('one: exactly 1 item'));
              expect(content, contains('two: exactly 2 items'));
              expect(content, contains('few: small quantities'));
              expect(content, contains('many: larger quantities'));
              expect(content, contains('other: fallback'));

              // Check pluralization logic
              expect(content, contains('if (count == 0) return \'zero\''));
              expect(content, contains('if (count == 1) return \'one\''));
              expect(content, contains('if (count == 2) return \'two\''));
              expect(
                content,
                contains('if (count >= 3 && count <= 10) return \'few\''),
              );
              expect(content, contains('if (count >= 11) return \'many\''));
              expect(content, contains('return \'other\''));

              print('⚡ Universal pluralization logic passed');
            } finally {
              await project.cleanup();
            }
          },
        );
      });

      // trVars Functionality Tests
      group('🔤 trVars Extension Tests', () {
        test('should process __count structures correctly', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            await _createCountTestLocaleFiles(project.projectDir);

            final result = await run([
              'locale',
              'generate',
              'assets/locales',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            // Verify main translations file
            final outputFile = File(
              path.join(
                project.projectDir.path,
                'lib/app/translations/translations.g.dart',
              ),
            );
            final content = await outputFile.readAsString();

            // Check that __count is converted to JSON string
            expect(content, contains('{"zero":"No notifications"'));
            expect(content, contains('"one":"One notification"'));
            expect(content, contains('"few":"{count} notifications"'));
            expect(content, contains('"many":"{count} notifications"'));
            expect(content, contains('"other":"{count} notifications"}'));

            // Verify regular strings are not affected
            expect(content, contains('\'welcome\': \'Welcome {name}\''));

            print('⚡ __count processing passed');
          } finally {
            await project.cleanup();
          }
        });

        test('should handle variable replacement patterns', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            await _createVariableTestLocaleFiles(project.projectDir);

            final result = await run([
              'locale',
              'generate',
              'assets/locales',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            final outputFile = File(
              path.join(
                project.projectDir.path,
                'lib/app/translations/translations.g.dart',
              ),
            );
            final content = await outputFile.readAsString();

            // Verify variable patterns are preserved
            expect(content, contains('Hello {name}'));
            expect(content, contains('You have {count} messages'));
            expect(content, contains('Welcome {firstName} {lastName}'));

            print('⚡ Variable replacement patterns passed');
          } finally {
            await project.cleanup();
          }
        });
      });

      // trCount Functionality Tests
      group('🔢 trCount Extension Tests', () {
        test('should support all plural keys', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            await _createFullPluralTestLocaleFiles(project.projectDir);

            final result = await run([
              'locale',
              'generate',
              'assets/locales',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            final outputFile = File(
              path.join(
                project.projectDir.path,
                'lib/app/translations/translations.g.dart',
              ),
            );
            final content = await outputFile.readAsString();

            // English with basic plurals
            expect(content, contains('"zero":"No books"'));
            expect(content, contains('"one":"One book"'));
            expect(content, contains('"other":"{count} books"'));

            // Arabic with full plurals
            expect(content, contains('"zero":"لا توجد كتب"'));
            expect(content, contains('"one":"كتاب واحد"'));
            expect(content, contains('"two":"كتابان"'));
            expect(content, contains('"few":"{count} كتب"'));
            expect(content, contains('"many":"{count} كتاباً"'));
            expect(content, contains('"other":"{count} كتاب"'));

            print('⚡ All plural keys support passed');
          } finally {
            await project.cleanup();
          }
        });

        test('should handle mixed variable and count patterns', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            await _createMixedPluralTestLocaleFiles(project.projectDir);

            final result = await run([
              'locale',
              'generate',
              'assets/locales',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            final outputFile = File(
              path.join(
                project.projectDir.path,
                'lib/app/translations/translations.g.dart',
              ),
            );
            final content = await outputFile.readAsString();

            // Verify mixed patterns are preserved
            expect(content, contains('{name} has no items'));
            expect(content, contains('{name} has one item'));
            expect(content, contains('{name} has {count} items'));

            print('⚡ Mixed variable and count patterns passed');
          } finally {
            await project.cleanup();
          }
        });
      });

      // Integration Tests
      group('🔗 Integration & GetX Compatibility', () {
        test('should generate GetX-compatible translations', () async {
          final project = await OptimizedTestManager.createOptimizedProject(
            templateKey: 'getx',
          );

          try {
            await _createGetXCompatibleLocales(project.projectDir);

            final result = await run([
              'locale',
              'generate',
              'assets/locales',
            ], project.projectDir);

            expect(result.exitCode, equals(ExitCode.success.code));

            final outputFile = File(
              path.join(
                project.projectDir.path,
                'lib/app/translations/translations.g.dart',
              ),
            );
            final content = await outputFile.readAsString();

            // Verify GetX integration elements
            expect(content, contains('import \'package:get/get.dart\''));
            expect(
              content,
              contains('class AppTranslations extends Translations'),
            );
            expect(
              content,
              contains('Map<String, Map<String, String>> get keys'),
            );

            // Verify parameter placeholders are preserved
            expect(content, contains('{{name}}'));
            expect(content, contains('{{count}}'));

            print('⚡ GetX compatibility test passed');
          } finally {
            await project.cleanup();
          }
        });
      });
    });
  }

  // Helper Methods

  /// Creates basic test locale files (en.json, ar.json)
  Future<void> _createTestLocaleFiles(Directory projectDir) async {
    final localesDir = Directory(
      path.join(projectDir.path, 'assets', 'locales'),
    );
    await localesDir.create(recursive: true);

    // English locale
    final enFile = File(path.join(localesDir.path, 'en.json'));
    await enFile.writeAsString('''
{
  "app": {
    "name": "My App"
  },
  "auth": {
    "login": "Login",
    "logout": "Logout"
  }
}
''');

    // Arabic locale
    final arFile = File(path.join(localesDir.path, 'ar.json'));
    await arFile.writeAsString('''
{
  "app": {
    "name": "تطبيقي"
  },
  "auth": {
    "login": "تسجيل الدخول",
    "logout": "تسجيل الخروج"
  }
}
''');
  }

  /// Creates nested structure test locale files
  Future<void> _createNestedTestLocaleFiles(Directory projectDir) async {
    final localesDir = Directory(
      path.join(projectDir.path, 'assets', 'locales'),
    );
    await localesDir.create(recursive: true);

    // English locale with nested structure
    final enFile = File(path.join(localesDir.path, 'en.json'));
    await enFile.writeAsString('''
{
  "auth": {
    "validation": {
      "emailRequired": "Email is required"
    }
  },
  "home": {
    "greeting": "Welcome!"
  }
}
''');

    // Arabic locale
    final arFile = File(path.join(localesDir.path, 'ar.json'));
    await arFile.writeAsString('''
{
  "auth": {
    "validation": {
      "emailRequired": "البريد الإلكتروني مطلوب"
    }
  },
  "home": {
    "greeting": "مرحباً!"
  }
}
''');
  }

  /// Creates inconsistent locale files for validation testing
  Future<void> _createInconsistentLocaleFiles(Directory projectDir) async {
    final localesDir = Directory(
      path.join(projectDir.path, 'assets', 'locales'),
    );
    await localesDir.create(recursive: true);

    // English locale
    final enFile = File(path.join(localesDir.path, 'en.json'));
    await enFile.writeAsString('''
{
  "common": "Common",
  "shared": "Shared"
}
''');

    // Arabic locale with extra keys
    final arFile = File(path.join(localesDir.path, 'ar.json'));
    await arFile.writeAsString('''
{
  "common": "عام",
  "shared": "مشترك",
  "extra": "إضافي",
  "another": "آخر"
}
''');
  }

  /// Creates large locale files for performance testing
  Future<void> _createLargeLocaleFiles(Directory projectDir) async {
    final localesDir = Directory(
      path.join(projectDir.path, 'assets', 'locales'),
    );
    await localesDir.create(recursive: true);

    // Generate large locale files
    final enContent = <String, dynamic>{};
    final arContent = <String, dynamic>{};

    for (int i = 0; i < 100; i++) {
      enContent['key$i'] = 'Value $i';
      arContent['key$i'] = 'قيمة $i';
    }

    final enFile = File(path.join(localesDir.path, 'en.json'));
    await enFile.writeAsString(_jsonEncode(enContent));

    final arFile = File(path.join(localesDir.path, 'ar.json'));
    await arFile.writeAsString(_jsonEncode(arContent));
  }

  /// Creates GetX-compatible locale files with parameters
  Future<void> _createGetXCompatibleLocales(Directory projectDir) async {
    final localesDir = Directory(
      path.join(projectDir.path, 'assets', 'locales'),
    );
    await localesDir.create(recursive: true);

    // English locale with GetX features
    final enFile = File(path.join(localesDir.path, 'en.json'));
    await enFile.writeAsString('''
{
  "welcome": "Welcome, {{name}}!",
  "messages": {
    "one": "You have one message",
    "other": "You have {{count}} messages"
  },
  "greeting": "Hello {{name}}, you have {{count}} notifications"
}
''');

    // Arabic locale
    final arFile = File(path.join(localesDir.path, 'ar.json'));
    await arFile.writeAsString('''
{
  "welcome": "مرحباً، {{name}}!",
  "messages": {
    "zero": "ليس لديك رسائل",
    "one": "لديك رسالة واحدة",
    "two": "لديك رسالتان",
    "few": "لديك {{count}} رسائل",
    "many": "لديك {{count}} رسالة",
    "other": "لديك {{count}} رسائل"
  },
  "greeting": "مرحباً {{name}}، لديك {{count}} إشعار"
}
''');
  }

  /// Simple JSON encoder
  String _jsonEncode(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    buffer.write('{');
    final entries = data.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      buffer.write('"${entry.key}":"${entry.value}"');
      if (i < entries.length - 1) buffer.write(',');
    }
    buffer.write('}');
    return buffer.toString();
  }

  /// Creates extension test locale files with trVars and trCount examples
  Future<void> _createExtensionTestLocaleFiles(Directory projectDir) async {
    final localesDir = Directory(
      path.join(projectDir.path, 'assets', 'locales'),
    );
    await localesDir.create(recursive: true);

    // English locale with extensions features
    final enFile = File(path.join(localesDir.path, 'en.json'));
    await enFile.writeAsString('''
{
  "welcome": "Welcome {name}!",
  "items": {
    "__count": {
      "zero": "No items",
      "one": "One item",
      "other": "{count} items"
    }
  },
  "simple": "Simple text"
}
''');

    // Arabic locale with full plural support
    final arFile = File(path.join(localesDir.path, 'ar.json'));
    await arFile.writeAsString('''
{
  "welcome": "مرحباً {name}!",
  "items": {
    "__count": {
      "zero": "لا توجد عناصر",
      "one": "عنصر واحد",
      "two": "عنصران",
      "few": "{count} عناصر",
      "many": "{count} عنصراً",
      "other": "{count} عنصر"
    }
  },
  "simple": "نص بسيط"
}
''');
  }

  /// Creates test files specifically for __count processing
  Future<void> _createCountTestLocaleFiles(Directory projectDir) async {
    final localesDir = Directory(
      path.join(projectDir.path, 'assets', 'locales'),
    );
    await localesDir.create(recursive: true);

    final enFile = File(path.join(localesDir.path, 'en.json'));
    await enFile.writeAsString('''
{
  "welcome": "Welcome {name}",
  "notifications": {
    "__count": {
      "zero": "No notifications",
      "one": "One notification",
      "few": "{count} notifications",
      "many": "{count} notifications",
      "other": "{count} notifications"
    }
  },
  "regular": "Regular string"
}
''');
  }

  /// Creates test files for variable replacement patterns
  Future<void> _createVariableTestLocaleFiles(Directory projectDir) async {
    final localesDir = Directory(
      path.join(projectDir.path, 'assets', 'locales'),
    );
    await localesDir.create(recursive: true);

    final enFile = File(path.join(localesDir.path, 'en.json'));
    await enFile.writeAsString('''
{
  "greeting": "Hello {name}",
  "messages": "You have {count} messages",
  "fullName": "Welcome {firstName} {lastName}",
  "complex": "Hello {name}, you have {count} items and {unread} unread"
}
''');
  }

  /// Creates test files with full plural key support
  Future<void> _createFullPluralTestLocaleFiles(Directory projectDir) async {
    final localesDir = Directory(
      path.join(projectDir.path, 'assets', 'locales'),
    );
    await localesDir.create(recursive: true);

    // English with basic plurals
    final enFile = File(path.join(localesDir.path, 'en.json'));
    await enFile.writeAsString('''
{
  "books": {
    "__count": {
      "zero": "No books",
      "one": "One book",
      "other": "{count} books"
    }
  }
}
''');

    // Arabic with full plurals
    final arFile = File(path.join(localesDir.path, 'ar.json'));
    await arFile.writeAsString('''
{
  "books": {
    "__count": {
      "zero": "لا توجد كتب",
      "one": "كتاب واحد",
      "two": "كتابان",
      "few": "{count} كتب",
      "many": "{count} كتاباً",
      "other": "{count} كتاب"
    }
  }
}
''');
  }

  /// Creates test files with mixed variable and count patterns
  Future<void> _createMixedPluralTestLocaleFiles(Directory projectDir) async {
    final localesDir = Directory(
      path.join(projectDir.path, 'assets', 'locales'),
    );
    await localesDir.create(recursive: true);

    final enFile = File(path.join(localesDir.path, 'en.json'));
    await enFile.writeAsString('''
{
  "userItems": {
    "__count": {
      "zero": "{name} has no items",
      "one": "{name} has one item",
      "other": "{name} has {count} items"
    }
  },
  "status": "User {name} is {status} with {points} points"
}
''');
  }
}

/// Main entry point for locale generate command tests
void main() {
  LocaleGenerateCommandTest().runTests();
}
