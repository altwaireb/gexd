import 'package:args/command_runner.dart';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

/// Command for generating GetX locale translations from JSON files.
///
/// This command reads JSON locale files from a specified directory,
/// validates them for consistency, and generates a Dart file with
/// GetX-compatible translations.
///
/// Usage:
/// ```
/// gexd locale generate [input_directory] [options]
/// ```
///
/// Options:
/// - `--output`: Output file path (default: lib/generated/translations.g.dart)
/// - `--key-style`: Key formatting style (dot|snake|camelCase, default: dot)
/// - `--sort-keys`: Sort translation keys alphabetically (default: true)
/// - `--force`: Overwrite existing output file (default: false)
class LocaleGenerateCommand extends Command<int>
    with HasProjectData, HasTargetDirectory {
  /// The [Logger] instance used for logging.
  final Logger _logger;

  /// The prompt service for user interaction
  final PromptServiceInterface _prompt;

  LocaleGenerateCommand({Logger? logger, PromptServiceInterface? prompt})
    : _logger = logger ?? Logger(),
      _prompt = prompt ?? PromptService() {
    argParser
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Output file path for generated translations',
        hide: true,
      )
      ..addOption(
        'key-style',
        abbr: 's',
        help: 'Key formatting style for nested JSON',
        defaultsTo: 'dot',
        allowed: LocaleKeyStyle.allKeys,
        allowedHelp: LocaleKeyStyle.allowedHelp,
      )
      ..addFlag(
        'sort-keys',
        help: 'Sort translation keys alphabetically',
        defaultsTo: true,
      )
      ..addFlag(
        'force',
        abbr: 'f',
        help: 'Overwrite existing output file',
        defaultsTo: false,
      );
  }

  @override
  String get description => 'Generate GetX locale translations from JSON files';

  @override
  String get name => 'generate';

  @override
  String get invocation => 'gexd locale generate [input_directory] [options]';

  @override
  Future<int> run() async {
    try {
      final ProjectTemplate? template = await projectTemplate;
      if (template == null) {
        _logger.err('Not inside a valid Gexd project.');
        return ExitCode.config.code;
      }

      final inputs = GenerateInputs(
        argResults!,
        targetDir: targetDirectory,
        prompt: _prompt,
        template: template,
      );

      final data = await inputs.handle();

      final job = GenerateJob(data, logger: _logger);

      return await job.execute();
    } on ValidationException catch (e) {
      _logger.err(e.toUserMessage());
      return ExitCode.usage.code;
    } on ProjectCreationException catch (e) {
      _logger.err(e.toUserMessage());
      return ExitCode.software.code;
    } catch (e) {
      _logger.err('An unexpected error occurred: $e');
      return ExitCode.software.code;
    }
  }
}
