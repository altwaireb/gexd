import 'package:args/command_runner.dart';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

class ControllerCommand extends Command<int>
    with HasProjectData, HasTargetDirectory {
  final Logger _logger;
  final PromptServiceInterface _prompt;

  ControllerCommand({Logger? logger, PromptServiceInterface? prompt})
    : _logger = logger ?? Logger(),
      _prompt = prompt ?? PromptService() {
    _setupArgs();
  }

  void _setupArgs() {
    argParser
      ..addOption(
        'location',
        abbr: 'l',
        help: 'Controller location in project structure',
        valueHelp: 'shared|screen',
        allowed: ControllerLocation.allKeys,
        allowedHelp: ControllerLocation.allowedHelp,
      )
      ..addOption(
        'on-screen',
        help:
            'Screen name for screen-specific controllers (required for screen location)',
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
  String get name => 'controller';

  @override
  String get description => 'Generate controller files';

  @override
  String get usage =>
      '''
$description

Usage: $invocation

Arguments:
  <name>          Controller name (e.g., Auth, Profile)
                  [Optional: Run without arguments for interactive mode]

Options:
${argParser.usage}

Controller Locations:
  shared          Shared module controllers (<modules|presentation>/controllers/)
  screen          Screen-specific controllers (linked to specific screen)

Examples:
  gexd make controller                                      # Interactive mode
  gexd make controller App                                  # Smart mode (interactive if exists)

  # Core/Shared controllers (use --on for custom subdirectory):
  gexd make controller Auth --location shared               # Shared controller
  gexd make controller Settings --location shared --on user # Core controller in subdirectory

  # Screen controllers (use --on-screen, --on not allowed):
  gexd make controller Profile --location screen --on-screen login
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

      final ControllerData inputs = await ControllerInputs(
        argResults!,
        prompt: _prompt,
        template: template,
        targetDir: targetDirectory,
      ).handle();

      final create = ControllerJob(
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
