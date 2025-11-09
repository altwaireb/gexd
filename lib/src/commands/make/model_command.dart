import 'package:args/command_runner.dart';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

class ModelCommand extends Command<int>
    with HasProjectData, HasTargetDirectory {
  final Logger _logger;
  final PromptServiceInterface _prompt;

  ModelCommand({Logger? logger, PromptServiceInterface? prompt})
    : _logger = logger ?? Logger(),
      _prompt = prompt ?? PromptService() {
    _setupArgs();
  }

  void _setupArgs() {
    argParser
      // Model input source options
      ..addOption(
        'file',
        abbr: 'f',
        help: 'Path to JSON file for model generation',
        valueHelp: 'assets/models/file.json',
      )
      ..addOption(
        'url',
        abbr: 'u',
        help: 'URL to fetch JSON data for model generation',
        valueHelp: 'https://api.example.com/user/123',
      )
      ..addOption(
        'template',
        abbr: 't',
        allowed: ModelStarterTemplate.allKeys,
        allowedHelp: ModelStarterTemplate.allowedHelp,
        defaultsTo: ModelStarterTemplate.basic.key,
        help: 'Choose starter template for model generation',
      )
      // Model style and features
      ..addOption(
        'style',
        abbr: 's',
        allowed: ModelStyle.allKeys,
        allowedHelp: ModelStyle.allowedHelp,
        defaultsTo: ModelStyle.plain.key,
        help: 'Choose model generation style',
      )
      ..addFlag(
        'immutable',
        abbr: 'i',
        negatable: false,
        help: 'Generate immutable model with final fields',
      )
      ..addFlag(
        'copyWith',
        abbr: 'c',
        negatable: false,
        help: 'Add copyWith method for creating modified copies',
      )
      ..addFlag(
        'equatable',
        abbr: 'e',
        negatable: false,
        help: 'Use Equatable package for value equality comparison',
      )
      // Organization options
      ..addFlag(
        'relationships-in-folder',
        abbr: 'r',
        defaultsTo: true,
        help: 'Generate relationships in separate <model>_relationships folder',
      )
      ..addOption(
        'on',
        help:
            'Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)',
        valueHelp: 'auth/user',
      )
      ..addFlag(
        'force',
        negatable: false,
        help: 'Force overwrite existing files without prompting',
      );
  }

  @override
  String get name => 'model';

  @override
  String get description => 'Generate model files';

  @override
  String get usage =>
      '''
$description

Usage: $invocation

Arguments:
  <name>          Model name (e.g., User, Profile)
                  [Optional: Run without arguments for interactive mode]

Options:
${argParser.usage}

Examples:
  gexd make model                                        # Interactive mode
  gexd make model User                                   # Smart mode (interactive if exists)

  # Model from template (default):
  gexd make model User                                   # Basic template
  gexd make model User --template custom                # Custom interactive template

  # Model from JSON file:
  gexd make model User --file assets/user.json          # From local file

  # Model from API endpoint:
  gexd make model User --url https://api.example.com/user/123

  # Model with advanced features:
  gexd make model User --immutable --copyWith --equatable

  # Model with different styles:
  gexd make model User --style json                     # JSON serializable
  gexd make model User --style freezed --immutable      # Freezed style

  # Model in subdirectory:
  gexd make model User --on auth/models                 # Model in subdirectory
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

      final ModelData inputs = await ModelInputs(
        argResults!,
        prompt: _prompt,
        template: template,
        targetDir: targetDirectory,
      ).handle();

      final create = ModelJob(
        inputs,
        quicktypeService: QuicktypeService(logger: _logger),
        relationshipService: RelationshipDetectorService(logger: _logger),
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
