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

            expect(result.exitCode, equals(ExitCode.ioError.code));
            expect(result.stderr, contains('Locale directory does not exist'));

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

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(result.stdout, contains('[WARN]'));
            expect(result.stdout, contains('extra keys'));

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

            // Should complete within reasonable time (15 seconds for E2E)
            expect(stopwatch.elapsedMilliseconds, lessThan(15000));

            print(
              '⚡ Performance test completed in ${stopwatch.elapsedMilliseconds}ms',
            );
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
}

/// Main entry point for locale generate command tests
void main() {
  LocaleGenerateCommandTest().runTests();
}
