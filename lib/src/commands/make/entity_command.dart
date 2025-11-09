import 'package:args/command_runner.dart';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

class EntityCommand extends Command<int>
    with HasProjectData, HasTargetDirectory {
  final Logger _logger;
  final PromptServiceInterface _prompt;

  EntityCommand({Logger? logger, PromptServiceInterface? prompt})
    : _logger = logger ?? Logger(),
      _prompt = prompt ?? PromptService() {
    _setupArgs();
  }

  void _setupArgs() {
    argParser
      // Entity input source options
      ..addOption(
        'file',
        abbr: 'f',
        help: 'Path to JSON file for entity generation',
        valueHelp: 'assets/models/file.json',
      )
      ..addOption(
        'url',
        abbr: 'u',
        help: 'URL to fetch JSON data for entity generation',
        valueHelp: 'https://api.example.com/user/123',
      )
      // Entity style and features
      ..addOption(
        'style',
        abbr: 's',
        allowed: EntityStyle.allKeys,
        allowedHelp: EntityStyle.allowedHelp,
        defaultsTo: EntityStyle.immutable.key,
        help: 'Choose entity generation style',
      )
      ..addFlag(
        'with-model',
        abbr: 'm',
        negatable: false,
        help: 'Generate corresponding data model that extends this entity',
      )
      ..addFlag(
        'equatable',
        abbr: 'e',
        defaultsTo: true,
        help: 'Use Equatable package for value equality comparison',
      )
      // Organization options
      ..addOption(
        'on',
        help:
            'Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)',
        valueHelp: 'user/profile',
      )
      ..addFlag(
        'force',
        negatable: false,
        help: 'Force overwrite existing files without prompting',
      );
  }

  @override
  String get name => 'entity';

  @override
  String get description =>
      'Generate domain entity files for Clean Architecture';

  @override
  String get usage =>
      '''
$description

Usage: $invocation

Arguments:
  <name>          Entity name (e.g., User, Profile, Product)
                  [Optional: Run without arguments for interactive mode]

Options:
${argParser.usage}

Examples:
  gexd make entity                                       # Interactive mode
  gexd make entity User                                  # Simple entity from template

  # Entity from JSON file:
  gexd make entity User --file assets/user.json         # From local file

  # Entity from API endpoint:
  gexd make entity User --url https://api.example.com/user/123

  # Entity with different styles:
  gexd make entity User --style plain                   # Plain class
  gexd make entity User --style immutable               # Immutable with Equatable (default)
  gexd make entity User --style freezed                 # Freezed style

  # Entity with corresponding Model:
  gexd make entity User --with-model                    # Generate both entity and model

  # Entity in subdirectory:
  gexd make entity User --on auth/user                  # Entity in subdirectory

  # Force overwrite:
  gexd make entity User --force                         # Skip confirmation prompts
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

      // Only allow entity generation for Clean Architecture template
      if (template != ProjectTemplate.clean) {
        _logger.err(
          '❌ Entity command is only available for Clean Architecture projects',
        );
        _logger.info('');
        _logger.info(
          '💡 Use "gexd make model" for ${template.displayName} projects',
        );
        _logger.info(
          '💡 Create a Clean Architecture project with: gexd create <project_name> --template clean',
        );
        return ExitCode.config.code;
      }

      final EntityData inputs = await EntityInputs(
        argResults!,
        prompt: _prompt,
        template: template,
        targetDir: targetDirectory,
      ).handle();

      final create = EntityJob(
        inputs,
        entityGeneratorService: EntityGeneratorService(logger: _logger),
        entityDetectionService: EntityDetectionService(),
        environmentService: EnvironmentValidatorService(logger: _logger),
        logger: _logger,
      );

      return create.execute();
    } catch (error) {
      // Log and rethrow error
      rethrow;
    }
  }
}
