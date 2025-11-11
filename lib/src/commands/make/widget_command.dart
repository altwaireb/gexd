import 'package:args/command_runner.dart';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

class WidgetCommand extends Command<int>
    with HasProjectData, HasTargetDirectory {
  final Logger _logger;
  final PromptServiceInterface _prompt;

  WidgetCommand({Logger? logger, PromptServiceInterface? prompt})
    : _logger = logger ?? Logger(),
      _prompt = prompt ?? PromptService() {
    _setupArgs();
  }

  void _setupArgs() {
    argParser
      ..addOption(
        'location',
        abbr: 'l',
        help: 'Widget location in project structure',
        valueHelp: 'shared|screen',
        allowed: WidgetLocation.allKeys,
        allowedHelp: WidgetLocation.allowedHelp,
        defaultsTo: WidgetLocation.shared.key,
      )
      ..addOption(
        'on-screen',
        help:
            'Screen name for screen-specific widgets (required for screen location)',
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
  String get name => 'widget';

  @override
  String get description => 'Generate widget files';

  @override
  String get usage =>
      '''
$description

Usage: $invocation

Arguments:
  <name>          Widget name (e.g., CustomButton, UserCard)
                  [Optional: Run without arguments for interactive mode]

Options:
${argParser.usage}

Widget Locations:
  shared          Shared widgets (<shared>/widgets/)
  screen          Screen-specific widgets (linked to specific screen)

Examples:
  gexd make widget                                      # Interactive mode
  gexd make widget CustomButton                         # Smart mode (interactive if exists)

  # Shared widgets (use --on for custom subdirectory):
  gexd make widget CustomButton --location shared      # Shared widget
  gexd make widget AuthForm --location shared --on auth # Shared widget in subdirectory

  # Screen widgets (use --on-screen, --on not allowed):
  gexd make widget ProfileCard --location screen --on-screen profile
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

      final WidgetData inputs = await WidgetInputs(
        argResults!,
        prompt: _prompt,
        template: template,
        targetDir: targetDirectory,
      ).handle();

      final create = WidgetJob(
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
