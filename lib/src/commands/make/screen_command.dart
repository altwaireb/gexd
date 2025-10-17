import 'package:args/command_runner.dart';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

class ScreenCommand extends Command<int>
    with HasProjectData, HasTargetDirectory {
  final Logger _logger;
  final PromptServiceInterface _prompt;

  ScreenCommand({
    Logger? logger,
    PromptServiceInterface? prompt,
    bool skipValidation = false,
  }) : _logger = logger ?? Logger(),
       _prompt = prompt ?? PromptService() {
    _setupArgs();
  }

  void _setupArgs() {
    argParser
      ..addOption(
        'on',
        help:
            'Specify subdirectory path (max ${ScreenConstants.maxPathDepth} levels)',
        valueHelp: 'auth/user',
      )
      ..addOption(
        'type',
        abbr: 't',
        help: 'Screen type to generate',
        valueHelp: 'basic|form|withState',
        allowed: ScreenType.allKeys,
        allowedHelp: ScreenType.allowedHelp,
        defaultsTo: ScreenType.basic.key,
      )
      ..addOption(
        'model',
        help:
            'Specify model class for withState screens (enables typed state management)',
        valueHelp: 'User|Product',
      )
      ..addFlag(
        'has-model',
        help: 'Use model class with same name as screen for withState screens',
        negatable: false,
      )
      ..addFlag(
        'skip-route',
        help: 'Skip automatic route generation',
        negatable: false,
      )
      ..addFlag(
        'force',
        abbr: 'f',
        help: 'Force overwrite existing files without prompting',
        negatable: false,
      );
  }

  @override
  String get name => 'screen';

  @override
  String get description => 'Generate screen files (controller, view, binding)';

  @override
  String get usage =>
      '''
$description

Usage: $invocation

Arguments:
  <name>          Screen name (e.g., Login, Profile, Dashboard)
                  [Optional: Run without arguments for interactive mode]

Options:
${argParser.usage}

Screen Types:
  basic           Simple controller with basic lifecycle methods
  form            Controller with form validation and submission handling
  withState       Controller with reactive state management and loading states

Model Detection:
  --model <ModelName>       Specify exact model class for withState screens
  --has-model               Use model class with same name as screen

Examples:
  gexd make screen                                    # Interactive mode
  gexd make screen Login                              # Smart mode (interactive if exists)
  gexd make screen Login --type form                  # Generate form screen type
  gexd make screen Login --force                      # Force overwrite without prompting
  gexd make screen Login --on auth                    # Create in subdirectory
  gexd make screen UserList --type withState --model User          # Specific model class (User)
  gexd make screen Product --type withState --has-model            # Use Product model (same name)
  gexd make screen UserProfile --on auth/user --type withState --skip-route --force
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

      final ScreenData inputs = await ScreenInputs(
        argResults!,
        prompt: _prompt,
        template: template,
        targetDir: targetDirectory,
      ).handle();

      final factory = ScreenServiceFactory(_logger);

      final create = ScreenJob(
        inputs,
        masonService: factory.createMason(),
        routeUpdateService: factory.createRoute(),
        logger: _logger,
      );

      return create.execute();
    } on ValidationException catch (error, stackTrace) {
      _logger.err(error.toString());
      _logger.detail(stackTrace.toString());
      return ExitCode.usage.code;
    } on ModelNotFoundException catch (error, stackTrace) {
      _logger.err(error.toString());
      _logger.detail(stackTrace.toString());
      return ExitCode.usage.code;
    } catch (error, stackTrace) {
      _logger.err('❌ Error: $error');
      _logger.detail(stackTrace.toString());
      return ExitCode.software.code;
    }
  }
}
