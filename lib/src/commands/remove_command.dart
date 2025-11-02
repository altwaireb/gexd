import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

/// Remove command for managing Flutter project dependencies
///
/// Provides functionality to remove packages from Flutter projects using
/// flutter pub remove with full support for all original options.
class RemoveCommand extends Command<int>
    with HasProjectData, HasTargetDirectory {
  /// Logger instance for output
  final Logger _logger;

  RemoveCommand({Logger? logger}) : _logger = logger ?? Logger() {
    // Add all flutter pub remove options
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
      help: 'Precompile executables in immediate dependencies.',
      negatable: true,
      defaultsTo: null,
    );
  }

  @override
  String get description => 'Remove packages from your Flutter project.';

  @override
  String get name => 'remove';

  @override
  String get category => 'Package Management';

  @override
  String get invocation => 'gexd remove <package1> [<package2>...]';

  @override
  Future<int> run() async {
    final packages = argResults?.rest ?? [];

    if (packages.isEmpty) {
      _logger.err('❌ Please specify at least one package to remove');
      _logger.info('');
      _logger.info('Usage examples:');
      _logger.info('  gexd remove http');
      _logger.info('  gexd remove http dio shared_preferences');
      _logger.info('  gexd remove override:package_name');
      _logger.info('');
      _logger.info('Run "gexd remove --help" for more options');
      return ExitCode.usage.code;
    }

    try {
      // Validate we're in a gexd project
      if (!await isInGexdProject) {
        _logger.err('❌ Not inside a valid gexd project');
        _logger.info('💡 Run this command from a gexd project root');
        return ExitCode.config.code;
      }

      // Build flutter pub remove command
      final command = _buildFlutterCommand(packages);

      _logger.info('📦 Removing packages: ${packages.join(', ')}');
      _logger.info('🔄 Running: $command');

      // Execute flutter pub remove
      final result = await _executeFlutterCommand(command);

      if (result == ExitCode.success.code) {
        _logger.success('✅ Packages removed successfully!');
      }

      return result;
    } catch (e) {
      _logger.err('❌ Failed to remove packages: $e');
      return ExitCode.software.code;
    }
  }

  /// Build the complete flutter pub remove command with all options
  String _buildFlutterCommand(List<String> packages) {
    final commandParts = <String>['flutter', 'pub', 'remove'];

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

    // Add packages to remove
    commandParts.addAll(packages);

    return commandParts.join(' ');
  }

  /// Execute the flutter pub remove command
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
