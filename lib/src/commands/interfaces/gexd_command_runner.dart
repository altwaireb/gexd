import 'package:args/args.dart';
import 'package:cli_completion/cli_completion.dart';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_updater/pub_updater.dart';

/// Gexd command runner
///
/// This class is responsible for running Gexd commands.
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

    argParser.addFlag(
      'skip-update-check',
      negatable: false,
      help: 'Skip automatic update check.',
      hide: true,
    );

    addCommand(AddCommand(logger: _logger));
    addCommand(CreateCommand(logger: _logger, prompt: _prompt));
    addCommand(InitCommand(logger: _logger, prompt: _prompt));
    addCommand(MakeCommand(logger: _logger));
    addCommand(LocaleCommand(logger: _logger, prompt: _prompt));
    addCommand(RemoveCommand(logger: _logger));
    addCommand(UpgradeCommand(logger: _logger));
    addCommand(
      SelfUpdateCommand(
        logger: _logger,
        pubUpdater: _pubUpdater,
        prompt: _prompt,
      ),
    );
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
    } on ConfigProjectException catch (e) {
      _logger.errMessage(CommandMessages.configFailed, {'message': e.message});
      return ExitCode.config.code;
    } on ModelNotFoundException catch (e) {
      _logger.errMessage(CommandMessages.modelFailed, {'message': e.message});
      return ExitCode.usage.code;
    } on ProjectCreationException catch (e) {
      _logger.errMessage(JobMessages.projectCreationFailed, {
        'error': e.message,
      });
      return ExitCode.software.code;
    } on MasonBrickException catch (e) {
      _logger.errMessage(JobMessages.templateGeneratedFailed, {
        'error': e.message,
      });
      return ExitCode.software.code;
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
      // Skip update check for now since repository is private
      // This will be re-enabled once repository becomes public
      _logger.info('gexd $packageVersion');
      return ExitCode.success.code;
    }
    final result = await super.runCommand(topLevelResults);

    // Skip automatic update check while repository is private
    // This will be re-enabled once repository becomes public
    // TODO: Re-enable update check after making repository public

    return result;
  }

  // TODO: Re-enable after repository becomes public
  // Future<void> _checkForUpdates() async {
  //   try {
  //     final latest = await _pubUpdater.getLatestVersion('gexd');
  //     if (packageVersion != latest) {
  //       _logger
  //         ..info('')
  //         ..warnMessage(CommandMessages.updateAvailable, {
  //           'currentVersion': packageVersion,
  //           'latestVersion': latest,
  //         })
  //         ..infoMessage(CommandMessages.updateInstruction);
  //     }
  //   } catch (_) {}
  // }
}
