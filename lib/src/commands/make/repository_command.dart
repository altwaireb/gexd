import 'package:args/command_runner.dart';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

class RepositoryCommand extends Command<int>
    with HasProjectData, HasTargetDirectory {
  final Logger _logger;
  final PromptServiceInterface _prompt;

  RepositoryCommand({
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
        allowed: RepositoryType.allKeys,
        allowedHelp: RepositoryType.allowedHelp,
        defaultsTo: RepositoryType.empty.key,
      )
      ..addOption(
        'model',
        help:
            'Specify model class for CRUD repositories (enables typed repository methods)',
        valueHelp: 'User|Product',
      )
      ..addOption(
        'entity',
        help:
            'Specify entity class for CRUD repositories (enables typed repository methods with entities)',
        valueHelp: 'User|Product',
      )
      ..addOption(
        'on',
        help:
            'Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)',
        valueHelp: 'auth/user',
      )
      ..addFlag(
        'interface',
        abbr: 'i',
        help: 'Generate associated interface for the repository',
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
  String get name => 'repository';

  @override
  String get description => 'Generate repository files for data access layers';

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

Repository Types:
  crud            Repository with common CRUD operations
  empty           Empty repository for custom method definitions

Examples:
  gexd make repository                                   # Interactive mode
  gexd make repository User                              # Smart mode (interactive if exists)
  gexd make repository User --type crud                  # Generate CRUD repository type
  gexd make repository User --type crud --interface      # Generate CRUD repository type with interface
  gexd make repository User --type crud --model User     # Generate typed CRUD repository with User model
  gexd make repository User --type crud --entity User    # Generate typed CRUD repository with User entity
  gexd make repository User --force                      # Force overwrite without prompting
  gexd make repository User --on auth                    # Create in subdirectory
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

      final RepositoryData inputs = await RepositoryInputs(
        argResults!,
        prompt: _prompt,
        template: template,
        projectName: nameProject,
        targetDir: targetDirectory,
      ).handle();

      final create = RepositoryJob(
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
