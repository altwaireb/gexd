import 'package:args/args.dart';
import 'package:cli_completion/cli_completion.dart';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_updater/pub_updater.dart';

class GexdCommandRunner extends CompletionCommandRunner<int> {
  final Logger _logger;
  final PubUpdater _pubUpdater;
  final PromptServiceInterface _prompt;

  final String packageName = 'gexd';

  GexdCommandRunner({
    Logger? logger,
    PubUpdater? pubUpdater,
    PromptServiceInterface? prompt,
  }) : _logger = logger ?? Logger(),
       _pubUpdater = pubUpdater ?? PubUpdater(),
       _prompt = prompt ?? PromptService(),
       super(
         'gexd',
         'A CLI tool to scaffold Flutter projects using GetX with SOLID principles.',
       ) {
    argParser.addFlag(
      'version',
      abbr: 'v',
      negatable: false,
      help: 'Print the current version.',
    );

    addCommand(CreateCommand(logger: _logger, prompt: _prompt));
    addCommand(InitCommand(logger: _logger, prompt: _prompt));
    addCommand(MakeCommand(logger: _logger));
  }

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      return await runCommand(parse(args)) ?? ExitCode.success.code;
    } on ValidationException catch (e) {
      _logger.errMessage(CommandMessages.validationFailed, {
        'message': e.message,
      });
      return ExitCode.usage.code;
    } catch (error) {
      _logger.errMessage(CommandMessages.unexpectedError, {
        'error': error.toString(),
      });
      return ExitCode.software.code;
    }
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    final isVersionCommand =
        topLevelResults['version'] == true ||
        topLevelResults.arguments.contains('--version');

    if (isVersionCommand) {
      final isUpToDate = await _pubUpdater.isUpToDate(
        packageName: packageName,
        currentVersion: packageVersion,
      );
      if (!isUpToDate) {
        await _pubUpdater.update(packageName: packageName);
      }
      // _logger.info('gexd $packageVersion');
      return ExitCode.success.code;
    }
    final result = await super.runCommand(topLevelResults);
    // Automatic update check (skip for help/version/update commands for performance)
    final skipUpdateCheck =
        topLevelResults.command?.name == 'update' ||
        topLevelResults['help'] == true ||
        topLevelResults.arguments.contains('--help') ||
        topLevelResults.arguments.contains('-h') ||
        isVersionCommand;

    if (!skipUpdateCheck) {
      // final latestVersion = await _pubUpdater.getLatestVersion(packageName);
      await _checkForUpdates();
    }

    return result;
  }

  Future<void> _checkForUpdates() async {
    try {
      final latest = await _pubUpdater.getLatestVersion('gexd');
      if (packageVersion != latest) {
        _logger
          ..info('')
          ..warnMessage(CommandMessages.updateAvailable, {
            'currentVersion': packageVersion,
            'latestVersion': latest,
          })
          ..infoMessage(CommandMessages.updateInstruction);
      }
    } catch (_) {}
  }
}
