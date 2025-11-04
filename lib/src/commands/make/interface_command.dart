import 'package:args/command_runner.dart';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

class InterfaceCommand extends Command<int>
    with HasProjectData, HasTargetDirectory {
  final Logger _logger;
  final PromptServiceInterface _prompt;

  InterfaceCommand({
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
        'type',
        abbr: 't',
        help: 'Interface type to generate',
        valueHelp: 'crud|empty',
        allowed: InterfaceType.allKeys,
        allowedHelp: InterfaceType.allowedHelp,
        defaultsTo: InterfaceType.empty.key,
      )
      ..addOption(
        'model',
        help:
            'Specify model class for CRUD interfaces (enables typed interface methods)',
        valueHelp: 'User|Product',
      )
      ..addOption(
        'location',
        abbr: 'l',
        help: 'Interface location in project structure',
        valueHelp: 'domain|repositories|datasources',
        allowed: InterfaceLocation.allKeys,
        allowedHelp: InterfaceLocation.allowedHelp,
        defaultsTo: InterfaceLocation.domain.key,
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
  String get name => 'interface';

  @override
  String get description => 'Generate interface files for abstraction layers';

  @override
  String get usage =>
      '''
$description

Usage: $invocation

Arguments:
  <name>          Interface name (e.g., User)
                  [Optional: Run without arguments for interactive mode]

Options:
${argParser.usage}

Interface Types:
  crud            Interface with common CRUD operations
  empty           Empty interface for custom method definitions

Interface Locations:
  domain          Domain layer interfaces
  repositories    Repositories layer interfaces
  datasources     Datasources layer interfaces

Examples:
  gexd make interface                                   # Interactive mode
  gexd make interface User                              # Smart mode (interactive if exists)
  gexd make interface User --type crud                  # Generate CRUD interface type
  gexd make interface User --type crud --model User     # Generate typed CRUD interface with User model
  gexd make interface User --force                      # Force overwrite without prompting
  gexd make interface User --location repositories      # Create in repositories location
  gexd make interface User --on auth                    # Create in subdirectory
''';

  @override
  Future<int> run() async {
    try {
      // Validate that we're in a Gexd project

      final ProjectTemplate? template = await projectTemplate;
      final String? nameProject = await projectName;

      if (template == null || nameProject == null) {
        _logger.err('Not inside a valid Gexd project.');
        return ExitCode.config.code;
      }

      final InterfaceData inputs = await InterfaceInputs(
        argResults!,
        prompt: _prompt,
        template: template,
        projectName: nameProject,
        targetDir: targetDirectory,
      ).handle();

      final create = InterfaceJob(
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
