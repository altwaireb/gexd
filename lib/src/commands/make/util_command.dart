import 'package:args/command_runner.dart';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

class UtilCommand extends Command<int> with HasProjectData, HasTargetDirectory {
  final Logger _logger;
  final PromptServiceInterface _prompt;

  UtilCommand({Logger? logger, PromptServiceInterface? prompt})
    : _logger = logger ?? Logger(),
      _prompt = prompt ?? PromptService() {
    _setupArgs();
  }

  void _setupArgs() {
    argParser
      ..addOption(
        'on',
        help:
            'Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)',
        valueHelp: 'auth/user',
      )
      ..addFlag(
        'force',
        abbr: 'f',
        help: 'Force overwrite existing files without prompting',
        negatable: false,
      );
  }

  @override
  String get name => 'util';

  @override
  String get description => 'Generate util files';

  @override
  String get usage =>
      '''
$description

Usage: $invocation

Arguments:
  <name>          Util name (e.g., Validation, Formatter)
                  [Optional: Run without arguments for interactive mode]

Options:
${argParser.usage}

Examples:
  gexd make util                                           # Interactive mode
  gexd make util Validation                                # Smart mode (interactive if exists)

  # Util (use --on for custom subdirectory):
  gexd make util StringHelper                              # util
  gexd make util StringHelper --on foo                     # util in subdirectory
''';

  @override
  Future<int> run() async {
    try {
      // Validate that we're in a Gexd project

      final ProjectTemplate? template = await projectTemplate;
      if (template == null) {
        _logger.err('Not inside a valid Gexd project.');
        return ExitCode.config.code;
      }

      final UtilData inputs = await UtilInputs(
        argResults!,
        prompt: _prompt,
        template: template,
        targetDir: targetDirectory,
      ).handle();

      final create = UtilJob(
        inputs,
        masonService: MasonService(logger: _logger),
        postGenerationService: PostGenerationService(logger: _logger),
        logger: _logger,
      );

      return create.execute();
    } catch (error) {
      // Log and rethrow error
      rethrow;
    }
  }
}
