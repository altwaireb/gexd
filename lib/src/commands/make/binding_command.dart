import 'package:args/command_runner.dart';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

class BindingCommand extends Command<int>
    with HasProjectData, HasTargetDirectory {
  final Logger _logger;
  final PromptServiceInterface _prompt;

  BindingCommand({Logger? logger, PromptServiceInterface? prompt})
    : _logger = logger ?? Logger(),
      _prompt = prompt ?? PromptService() {
    _setupArgs();
  }

  void _setupArgs() {
    argParser
      ..addOption(
        'location',
        abbr: 'l',
        help: 'Binding location in project structure',
        valueHelp: 'core|shared|screen',
        allowed: BindingLocation.allKeys,
        allowedHelp: BindingLocation.allowedHelp,
        defaultsTo: BindingLocation.shared.key,
      )
      ..addOption(
        'on-screen',
        help:
            'Screen name for screen-specific bindings (required for screen location)',
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
  String get name => 'binding';

  @override
  String get description => 'Generate binding files for dependency injection';

  @override
  String get usage =>
      '''
$description

Usage: $invocation

Arguments:
  <name>          Binding name (e.g., Auth, Profile)
                  [Optional: Run without arguments for interactive mode]

Options:
${argParser.usage}

Binding Locations:
  core            Global application bindings (core/bindings/)
  shared          Shared module bindings (<modules|presentation>/bindings/)
  screen          Screen-specific bindings (linked to specific screen)

Examples:
  gexd make binding                                      # Interactive mode
  gexd make binding App                                  # Smart mode (interactive if exists)

  # Core/Shared bindings (use --on for custom subdirectory):
  gexd make binding Config --location core               # Core binding
  gexd make binding Tools --location shared              # Shared binding
  gexd make binding Auth --location core --on user       # Core binding in subdirectory

  # Screen bindings (use --on-screen, --on not allowed):
  gexd make binding Profile --location screen --on-screen login
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

      final BindingData inputs = await BindingInputs(
        argResults!,
        prompt: _prompt,
        template: template,
        targetDir: targetDirectory,
      ).handle();

      final create = BindingJob(
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
