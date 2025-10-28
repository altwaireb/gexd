import 'package:args/command_runner.dart';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

/// Main locale command that contains subcommands for locale management.
///
/// Available subcommands:
/// - `generate`: Generate GetX locale translations from JSON files
///
/// Usage:
/// ```
/// gexd locale <subcommand> [options]
/// ```
class LocaleCommand extends Command<int> {
  /// The [Logger] instance used for logging.
  final Logger _logger;

  /// The prompt service for user interaction
  final PromptServiceInterface _prompt;

  LocaleCommand({Logger? logger, PromptServiceInterface? prompt})
    : _logger = logger ?? Logger(),
      _prompt = prompt ?? PromptService() {
    addSubcommand(LocaleGenerateCommand(logger: _logger, prompt: _prompt));
  }

  @override
  String get description => 'Manage GetX locale translations';

  @override
  String get name => 'locale';

  @override
  List<String> get aliases => ['l'];

  @override
  String get invocation => 'gexd locale <subcommand> [options]';
}
