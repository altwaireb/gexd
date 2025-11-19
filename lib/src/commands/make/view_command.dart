import 'package:args/command_runner.dart';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

class ViewCommand extends Command<int> with HasProjectData, HasTargetDirectory {
  final Logger _logger;
  final PromptServiceInterface _prompt;

  ViewCommand({Logger? logger, PromptServiceInterface? prompt})
    : _logger = logger ?? Logger(),
      _prompt = prompt ?? PromptService() {
    _setupArgs();
  }

  void _setupArgs() {
    argParser
      ..addOption(
        'location',
        abbr: 'l',
        help: 'View location in project structure',
        valueHelp: 'shared|screen',
        allowed: ViewLocation.allKeys,
        allowedHelp: ViewLocation.allowedHelp,
      )
      ..addOption(
        'on-screen',
        help:
            'Screen name for screen-specific views (required for screen location)',
        valueHelp: 'login',
      )
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
  String get name => 'view';

  @override
  String get description => 'Generate view files';

  @override
  String get usage =>
      '''
$description

Usage: $invocation

Arguments:
  <name>          View name (e.g., Auth, Profile)
                  [Optional: Run without arguments for interactive mode]

Options:
${argParser.usage}

View Locations:
  shared          Shared module views (<modules|presentation>/views/)
  screen          Screen-specific views (linked to specific screen)

Examples:
  gexd make view                                      # Interactive mode
  gexd make view App                                  # Smart mode (interactive if exists)

  # Core/Shared views (use --on for custom subdirectory):
  gexd make view Auth --location shared               # Shared view
  gexd make view Settings --location shared --on user # Core view in subdirectory

  # Screen views (use --on-screen, --on not allowed):
  gexd make view Profile --location screen --on-screen login
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

      final ViewData inputs = await ViewInputs(
        argResults!,
        prompt: _prompt,
        template: template,
        targetDir: targetDirectory,
      ).handle();

      final create = ViewJob(
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
