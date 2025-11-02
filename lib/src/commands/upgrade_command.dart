import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

/// Upgrade command for updating Flutter project dependencies
///
/// Provides functionality to upgrade packages in Flutter projects using
/// flutter pub upgrade with full support for all original options including advanced upgrade modes.
class UpgradeCommand extends Command<int>
    with HasProjectData, HasTargetDirectory {
  /// Logger instance for output
  final Logger _logger;

  UpgradeCommand({Logger? logger}) : _logger = logger ?? Logger() {
    // Add all flutter pub upgrade options
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

    // Advanced upgrade options
    argParser.addFlag(
      'tighten',
      help:
          'Updates lower bounds in pubspec.yaml to match the resolved version.',
      negatable: false,
    );

    argParser.addFlag(
      'unlock-transitive',
      help: 'Also upgrades the transitive dependencies of the listed packages.',
      negatable: false,
    );

    argParser.addFlag(
      'major-versions',
      help:
          'Upgrades packages to their latest resolvable versions, and updates pubspec.yaml.',
      negatable: false,
    );
  }

  @override
  String get description =>
      'Upgrade packages in your Flutter project to their latest versions.';

  @override
  String get name => 'upgrade';

  @override
  String get category => 'Package Management';

  @override
  String get invocation => 'gexd upgrade [options] [dependencies...]';

  @override
  Future<int> run() async {
    final packages = argResults?.rest ?? [];

    try {
      // Validate we're in a gexd project
      if (!await isInGexdProject) {
        _logger.err('❌ Not inside a valid gexd project');
        _logger.info('💡 Run this command from a gexd project root');
        return ExitCode.config.code;
      }

      // Build flutter pub upgrade command
      final command = _buildFlutterCommand(packages);

      if (packages.isEmpty) {
        _logger.info('🔄 Upgrading all packages...');
      } else {
        _logger.info('🔄 Upgrading packages: ${packages.join(', ')}');
      }

      _logger.info('🔄 Running: $command');

      // Execute flutter pub upgrade
      final result = await _executeFlutterCommand(command);

      if (result == ExitCode.success.code) {
        if (packages.isEmpty) {
          _logger.success('✅ All packages upgraded successfully!');
        } else {
          _logger.success('✅ Packages upgraded successfully!');
        }

        // Show upgrade tips
        _showUpgradeTips();
      }

      return result;
    } catch (e) {
      _logger.err('❌ Failed to upgrade packages: $e');
      return ExitCode.software.code;
    }
  }

  /// Build the complete flutter pub upgrade command with all options
  String _buildFlutterCommand(List<String> packages) {
    final commandParts = <String>['flutter', 'pub', 'upgrade'];

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

    // Advanced upgrade options
    if (argResults?['tighten'] == true) {
      commandParts.add('--tighten');
    }

    if (argResults?['unlock-transitive'] == true) {
      commandParts.add('--unlock-transitive');
    }

    if (argResults?['major-versions'] == true) {
      commandParts.add('--major-versions');
    }

    // Work in current directory (targetDirectory)
    // No need for --directory flag since we work in the project root

    // Add specific packages if provided
    if (packages.isNotEmpty) {
      commandParts.addAll(packages);
    }

    return commandParts.join(' ');
  }

  /// Execute the flutter pub upgrade command
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

  /// Show helpful tips after upgrade
  void _showUpgradeTips() {
    final isDryRun = argResults?['dry-run'] == true;
    final hasMajorVersions = argResults?['major-versions'] == true;
    final hasTighten = argResults?['tighten'] == true;

    if (isDryRun) {
      _logger.info('');
      _logger.info(
        '💡 This was a dry run. Run without --dry-run to apply changes.',
      );
      return;
    }

    _logger.info('');

    if (hasMajorVersions) {
      _logger.info(
        '⚠️  Major version upgrades applied. Please test your app thoroughly.',
      );
    }

    if (hasTighten) {
      _logger.info('🔒 Package constraints tightened in pubspec.yaml.');
    }

    _logger.info('💡 Consider running "flutter test" to ensure compatibility.');
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
