import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

/// Add command for managing Flutter project dependencies
///
/// Provides functionality to add packages to Flutter projects using
/// flutter pub add with full support for all original options and package types.
class AddCommand extends Command<int> with HasProjectData, HasTargetDirectory {
  /// Logger instance for output
  final Logger _logger;

  AddCommand({Logger? logger}) : _logger = logger ?? Logger() {
    // Add all flutter pub add options
    argParser.addFlag(
      'dry-run',
      abbr: 'n',
      help: 'Report what dependencies would change but don\'t change any.',
      negatable: false,
    );

    argParser.addFlag(
      'offline',
      help: 'Use cached packages instead of accessing the network.',
      negatable: true,
      defaultsTo: null,
    );

    argParser.addFlag(
      'precompile',
      help: 'Build executables in immediate dependencies.',
      negatable: true,
      defaultsTo: null,
    );
  }

  @override
  String get description => 'Add packages to your Flutter project.';

  @override
  String get name => 'add';

  @override
  String get category => 'Package Management';

  @override
  String get invocation =>
      'gexd add [options] [<section>:]<package>[:descriptor] [<section>:]<package2>[:descriptor] ...';

  @override
  Future<int> run() async {
    final packages = argResults?.rest ?? [];

    if (packages.isEmpty) {
      _logger.err('❌ Please specify at least one package to add');
      _logger.info('');
      _logger.info('Usage examples:');
      _logger.info('  gexd add http');
      _logger.info('  gexd add dev:build_runner');
      _logger.info('  gexd add http dio shared_preferences');
      _logger.info('  gexd add "local_package:{path: ../local}"');
      _logger.info('');
      _logger.info('Run "gexd add --help" for more options');
      return ExitCode.usage.code;
    }

    try {
      // Validate we're in a gexd project
      if (!await isInGexdProject) {
        _logger.err('❌ Not inside a valid gexd project');
        _logger.info('💡 Run this command from a gexd project root');
        return ExitCode.config.code;
      }

      // Build flutter pub add command
      final command = _buildFlutterCommand(packages);

      _logger.info('📦 Adding packages: ${packages.join(', ')}');
      _logger.info('🔄 Running: $command');

      // Execute flutter pub add
      final result = await _executeFlutterCommand(command);

      if (result == ExitCode.success.code) {
        _logger.success('✅ Packages added successfully!');
      }

      return result;
    } catch (e) {
      _logger.err('❌ Failed to add packages: $e');
      return ExitCode.software.code;
    }
  }

  /// Build the complete flutter pub add command with all options
  String _buildFlutterCommand(List<String> packages) {
    final commandParts = <String>['flutter', 'pub', 'add'];

    // Add flags
    if (argResults?['dry-run'] == true) {
      commandParts.add('--dry-run');
    }

    final offline = argResults?['offline'];
    if (offline != null) {
      commandParts.add(offline ? '--offline' : '--no-offline');
    }

    final precompile = argResults?['precompile'];
    if (precompile != null) {
      commandParts.add(precompile ? '--precompile' : '--no-precompile');
    }

    // Work in current directory (targetDirectory)
    // No need for --directory flag since we work in the project root

    // Add packages (preserve exact user input for complex descriptors)
    commandParts.addAll(packages);

    return commandParts.join(' ');
  }

  /// Execute the flutter pub add command
  Future<int> _executeFlutterCommand(String command) async {
    try {
      // Split command into parts for Process.run
      final parts = _parseCommandParts(command);

      final result = await Process.run(
        parts.first,
        parts.skip(1).toList(),
        runInShell: true,
      );

      // Output the results
      if (result.stdout.toString().isNotEmpty) {
        _logger.info(result.stdout.toString().trim());
      }

      if (result.stderr.toString().isNotEmpty) {
        if (result.exitCode == 0) {
          // Sometimes warnings go to stderr but command succeeds
          _logger.warn(result.stderr.toString().trim());
        } else {
          _logger.err(result.stderr.toString().trim());
        }
      }

      return result.exitCode;
    } catch (e) {
      _logger.err('Failed to execute command: $e');
      return ExitCode.software.code;
    }
  }

  /// Parse command string into parts, handling quoted arguments
  List<String> _parseCommandParts(String command) {
    final parts = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;
    bool inSingleQuotes = false;

    for (int i = 0; i < command.length; i++) {
      final char = command[i];

      if (char == '"' && !inSingleQuotes) {
        inQuotes = !inQuotes;
      } else if (char == "'" && !inQuotes) {
        inSingleQuotes = !inSingleQuotes;
      } else if (char == ' ' && !inQuotes && !inSingleQuotes) {
        if (buffer.isNotEmpty) {
          parts.add(buffer.toString());
          buffer.clear();
        }
      } else {
        buffer.write(char);
      }
    }

    if (buffer.isNotEmpty) {
      parts.add(buffer.toString());
    }

    return parts;
  }
}
