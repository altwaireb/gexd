@Tags(['e2e'])
library;

import 'dart:io';
import 'package:io/io.dart' show ExitCode;
import 'package:test/test.dart';
import '../../../helpers/e2e_test_base.dart';

/// Locale Command E2E Test Suite
///
/// Tests for the main locale command and its subcommands.
/// Covers command structure, help messages, and basic validation.
class LocaleCommandTest extends E2ETestBase {
  void runTests() {
    group('LocaleCommand E2E Tests', () {
      setUpAll(() async {
        await super.setUpAll();
        print('🚀 Starting locale command tests...');
      });

      tearDownAll(() async {
        await super.tearDownAll();
        print('🎉 Locale command tests completed!');
      });

      // Basic Command Tests
      group('📋 Basic Command Structure', () {
        test('should show help when no subcommand provided', () async {
          final tempDir = Directory.systemTemp.createTempSync('locale_test_');

          try {
            final result = await run(['locale'], tempDir);

            // The command returns exit code 70 when missing subcommand
            expect(result.exitCode, equals(ExitCode.software.code));
            expect(
              result.stderr,
              contains('Missing subcommand for "gexd locale"'),
            );
            expect(result.stderr, contains('Available subcommands:'));
            expect(result.stderr, contains('generate'));

            print('⚡ Basic help display passed');
          } finally {
            await tempDir.delete(recursive: true);
          }
        });
        test('should show help with --help flag', () async {
          final tempDir = Directory.systemTemp.createTempSync('locale_test_');

          try {
            final result = await run(['locale', '--help'], tempDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(result.stdout, contains('Manage GetX locale translations'));
            expect(result.stdout, contains('generate'));

            print('⚡ Help flag display passed');
          } finally {
            await tempDir.delete(recursive: true);
          }
        });
        test('should show generate subcommand help', () async {
          final tempDir = Directory.systemTemp.createTempSync('locale_test_');

          try {
            final result = await run(['locale', 'generate', '--help'], tempDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('Generate GetX locale translations'),
            );
            expect(result.stdout, contains('key-style'));
            expect(result.stdout, contains('sort-keys'));

            print('⚡ Generate subcommand help passed');
          } finally {
            await tempDir.delete(recursive: true);
          }
        });
      });

      // Error Handling Tests
      group('⚠️ Error Handling', () {
        test('should fail with unknown subcommand', () async {
          final tempDir = Directory.systemTemp.createTempSync('locale_test_');

          try {
            final result = await run(['locale', 'unknown'], tempDir);

            expect(result.exitCode, equals(70));
            expect(
              result.stderr,
              contains('Could not find a subcommand named "unknown"'),
            );

            print('⚡ Unknown subcommand handling passed');
          } finally {
            await tempDir.delete(recursive: true);
          }
        });
      });

      // Integration Tests
      group('🔗 Command Integration', () {
        test('should be listed in main gexd help', () async {
          final tempDir = Directory.systemTemp.createTempSync('locale_test_');

          try {
            final result = await run(['--help'], tempDir);

            expect(result.exitCode, equals(ExitCode.success.code));
            expect(
              result.stdout,
              contains('locale        Manage GetX locale translations'),
            );

            print('⚡ Main help integration passed');
          } finally {
            await tempDir.delete(recursive: true);
          }
        });
      });
    });
  }
}

/// Main entry point for locale command tests
void main() {
  LocaleCommandTest().runTests();
}
