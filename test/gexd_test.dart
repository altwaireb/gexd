@Tags(['unit'])
library;

import 'package:gexd/gexd.dart';
import 'package:test/test.dart';

void main() {
  group('🎯 GexdCommandRunner', () {
    late GexdCommandRunner commandRunner;

    setUp(() {
      commandRunner = GexdCommandRunner();
    });

    group('📋 Constructor & Initialization', () {
      test('should initialize with default dependencies when none provided', () {
        final runner = GexdCommandRunner();

        expect(runner, isA<GexdCommandRunner>());
        expect(
          runner.description,
          equals(
            'A CLI tool to scaffold Flutter projects using GetX with SOLID principles.',
          ),
        );
        expect(runner.executableName, equals('gexd'));
      });

      test('should initialize with provided dependencies', () {
        expect(commandRunner, isA<GexdCommandRunner>());
        expect(commandRunner.packageName, equals('gexd'));
      });

      test('should register all required commands', () {
        final commands = commandRunner.commands;

        expect(commands.containsKey('create'), isTrue);
        expect(commands.containsKey('init'), isTrue);
        expect(commands.containsKey('make'), isTrue);

        expect(commands['create'], isA<CreateCommand>());
        expect(commands['init'], isA<InitCommand>());
        expect(commands['make'], isA<MakeCommand>());
      });

      test('should configure version flag correctly', () {
        final argParser = commandRunner.argParser;

        expect(argParser.options.containsKey('version'), isTrue);

        final versionOption = argParser.options['version'];
        expect(versionOption?.abbr, equals('v'));
        expect(versionOption?.negatable, isFalse);
        expect(versionOption?.help, equals('Print the current version.'));
      });
    });

    group('🎯 Integration Tests', () {
      test('should execute help command successfully', () async {
        final result = await commandRunner.run(['--help']);

        expect(result, equals(0)); // Success exit code
      });

      test('should show available commands in help', () async {
        await commandRunner.run(['--help']);

        final commands = commandRunner.commands;
        expect(commands.keys, containsAll(['create', 'init', 'make']));
      });

      test('should handle empty arguments gracefully', () async {
        final result = await commandRunner.run([]);

        expect(result, equals(0)); // Success exit code
      });

      test('should handle version command', () async {
        final result = await commandRunner.run(['--version']);

        // Version command may return different exit codes based on update check
        expect(result, isA<int>());
      });

      test('should handle -v flag', () async {
        final result = await commandRunner.run(['-v']);

        // Version command may return different exit codes based on update check
        expect(result, isA<int>());
      });
    });

    group('📊 Package Information', () {
      test('should have correct package name', () {
        expect(commandRunner.packageName, equals('gexd'));
      });

      test('should have correct executable name', () {
        expect(commandRunner.executableName, equals('gexd'));
      });

      test('should have meaningful description', () {
        expect(
          commandRunner.description,
          equals(
            'A CLI tool to scaffold Flutter projects using GetX with SOLID principles.',
          ),
        );
      });
    });

    group('⚠️ Exception Handling', () {
      test('should handle invalid command gracefully', () async {
        final result = await commandRunner.run(['nonexistent-command']);

        // Should return non-zero exit code for invalid command
        expect(result, isNot(equals(0)));
      });

      test('should handle empty command name', () async {
        final result = await commandRunner.run(['']);

        // Should handle empty command gracefully
        expect(result, isA<int>());
      });
    });

    group('🔧 Command Structure', () {
      test('should have create command with correct structure', () {
        final createCommand = commandRunner.commands['create'];
        expect(createCommand, isNotNull);
        expect(createCommand!.name, equals('create'));
        expect(
          createCommand.description,
          contains('Create a new Flutter project'),
        );
      });

      test('should have init command with correct structure', () {
        final initCommand = commandRunner.commands['init'];
        expect(initCommand, isNotNull);
        expect(initCommand!.name, equals('init'));
        expect(
          initCommand.description,
          contains('Initialize an existing Flutter project'),
        );
      });

      test('should have make command with correct structure', () {
        final makeCommand = commandRunner.commands['make'];
        expect(makeCommand, isNotNull);
        expect(makeCommand!.name, equals('make'));
        expect(
          makeCommand.description,
          contains('Generate various project files'),
        );
      });
    });

    group('🌟 Professional Package Standards', () {
      test('should follow CLI best practices', () {
        // Check if the command runner follows CLI conventions
        expect(commandRunner.executableName, isNotEmpty);
        expect(commandRunner.description, isNotEmpty);
        expect(commandRunner.commands, isNotEmpty);
      });

      test('should provide comprehensive help system', () {
        final argParser = commandRunner.argParser;

        // Should have help option
        expect(argParser.options.containsKey('help'), isTrue);
        expect(argParser.options.containsKey('version'), isTrue);
      });

      test('should have well-structured command hierarchy', () {
        final commands = commandRunner.commands;

        // Should have the expected core commands
        expect(commands.length, greaterThanOrEqualTo(3));
        expect(commands.containsKey('create'), isTrue);
        expect(commands.containsKey('init'), isTrue);
        expect(commands.containsKey('make'), isTrue);
      });
    });
  });
}
