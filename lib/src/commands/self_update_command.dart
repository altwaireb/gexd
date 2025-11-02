import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_updater/pub_updater.dart';

/// Self-update command for updating gexd CLI tool
///
/// Provides functionality to update the gexd CLI tool to the latest version
/// with support for dry-run mode and automatic project config updates.
class SelfUpdateCommand extends Command<int> {
  /// Logger instance for output
  final Logger _logger;

  /// PubUpdater instance for managing updates
  final PubUpdater _pubUpdater;

  /// Prompt service for user interactions
  final PromptServiceInterface _prompt;

  /// Package name for pub.dev
  static const String packageName = 'gexd';

  SelfUpdateCommand({
    Logger? logger,
    PubUpdater? pubUpdater,
    PromptServiceInterface? prompt,
  }) : _logger = logger ?? Logger(),
       _pubUpdater = pubUpdater ?? PubUpdater(),
       _prompt = prompt ?? PromptService() {
    // Add dry-run flag
    argParser.addFlag(
      'dry-run',
      help: 'Show what would be updated without making changes.',
      negatable: false,
    );

    // Add force flag
    argParser.addFlag(
      'force',
      abbr: 'f',
      help: 'Force update even if already up to date.',
      negatable: false,
    );

    // Add quiet flag
    argParser.addFlag(
      'quiet',
      abbr: 'q',
      help: 'Suppress output during update.',
      negatable: false,
    );
  }

  @override
  String get description => 'Update gexd CLI tool to the latest version.';

  @override
  String get name => 'self-update';

  @override
  String get category => 'Maintenance';

  @override
  Future<int> run() async {
    final isDryRun = argResults?['dry-run'] == true;
    final isForce = argResults?['force'] == true;
    final isQuiet = argResults?['quiet'] == true;

    try {
      if (!isQuiet) {
        _logger.info('🔍 Checking for gexd updates...');
      }

      // Get current and latest versions
      final currentVersion = packageVersion;
      final latestVersion = await _getLatestVersion();

      if (latestVersion == null) {
        _logger.err('❌ Failed to fetch latest version from pub.dev');
        return ExitCode.software.code;
      }

      final isUpToDate = await _pubUpdater.isUpToDate(
        packageName: packageName,
        currentVersion: currentVersion,
      );

      if (!isQuiet) {
        _logger.info('📦 Current version: $currentVersion');
        _logger.info('📦 Latest version: $latestVersion');
      }

      if (isUpToDate && !isForce) {
        if (!isQuiet) {
          _logger.success('✅ gexd is already up to date!');
        }
        return ExitCode.success.code;
      }

      if (isDryRun) {
        _logger.info('🔍 Dry run mode - no changes will be made');
        if (isUpToDate) {
          _logger.info('📦 No update needed (already up to date)');
        } else {
          _logger.info(
            '📦 Would update from $currentVersion to $latestVersion',
          );
          await _showUpdatePreview(currentVersion, latestVersion);
        }
        return ExitCode.success.code;
      }

      // Confirm update
      if (!isQuiet && !isForce) {
        final shouldUpdate = await _prompt.confirm(
          '🚀 Update gexd from $currentVersion to $latestVersion?',
        );

        if (!shouldUpdate) {
          _logger.info('❌ Update cancelled by user');
          return ExitCode.success.code;
        }
      }

      // Perform the update
      return await _performUpdate(currentVersion, latestVersion, isQuiet);
    } catch (e) {
      _logger.err('❌ Update failed: $e');
      return ExitCode.software.code;
    }
  }

  /// Get latest version from pub.dev
  Future<String?> _getLatestVersion() async {
    try {
      return await _pubUpdater.getLatestVersion(packageName);
    } catch (e) {
      _logger.err('Failed to fetch latest version: $e');
      return null;
    }
  }

  /// Show what would be updated in dry-run mode
  Future<void> _showUpdatePreview(String current, String latest) async {
    _logger.info('');
    _logger.info('📋 Update Preview:');
    _logger.info('  • Package: $packageName');
    _logger.info('  • From: $current');
    _logger.info('  • To: $latest');

    // Check if we're in a gexd project
    final currentDir = Directory.current;
    final configFile = File('${currentDir.path}/.gexd/config.yaml');

    if (await configFile.exists()) {
      _logger.info('  • Would update project config: ${configFile.path}');
    }

    _logger.info('');
    _logger.info('💡 Run without --dry-run to apply changes');
  }

  /// Perform the actual update
  Future<int> _performUpdate(
    String current,
    String latest,
    bool isQuiet,
  ) async {
    final progress = _logger.progress('Updating gexd CLI tool...');

    try {
      // Update the package
      final updateResult = await _pubUpdater.update(packageName: packageName);

      if (updateResult.exitCode != 0) {
        progress.fail('Failed to update gexd');
        _logger.err('Update error: ${updateResult.stderr}');
        return ExitCode.software.code;
      }

      progress.update('Updated gexd successfully');

      // Update project config if we're in a gexd project
      await _updateProjectConfig(latest, isQuiet);

      progress.complete('✅ gexd updated successfully!');

      if (!isQuiet) {
        _logger.success('🎉 Updated from $current to $latest');
        _logger.info('');
        _logger.info(
          '💡 Restart your terminal or run "gexd --version" to verify',
        );
      }

      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Update failed');
      _logger.err('Update error: $e');
      return ExitCode.software.code;
    }
  }

  /// Update project config.yaml if we're in a gexd project
  Future<void> _updateProjectConfig(String newVersion, bool isQuiet) async {
    try {
      final currentDir = Directory.current;
      final configFile = File('${currentDir.path}/.gexd/config.yaml');

      if (await configFile.exists()) {
        if (!isQuiet) {
          _logger.info('📝 Updating project config...');
        }

        final success = await ConfigService.updateProjectVersion(
          projectPath: currentDir.path,
          newVersion: newVersion,
        );

        if (success && !isQuiet) {
          _logger.success('✅ Project config updated');
        } else if (!success) {
          _logger.warn('⚠️  Could not update project config');
        }
      }
    } catch (e) {
      if (!isQuiet) {
        _logger.warn('⚠️  Failed to update project config: $e');
      }
    }
  }
}
