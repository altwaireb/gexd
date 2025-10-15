import 'package:args/command_runner.dart';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

class CreateCommand extends Command<int> {
  final Logger _logger;
  final PromptServiceInterface _prompt;

  @override
  String get name => 'create';

  @override
  String get description =>
      'Create a new Flutter project using gexd templates.\n\n'
      'Usage: gexd create <project_name> [options]\n'
      'Example: gexd create my_app -t getx -o com.example';

  @override
  List<String> get aliases => ['c'];

  CreateCommand({Logger? logger, PromptServiceInterface? prompt})
    : _logger = logger ?? Logger(),
      _prompt = prompt ?? PromptService() {
    _setupArgs();
  }

  void _setupArgs() {
    argParser
      ..addOption(
        'template',
        abbr: 't',
        help: 'Project template',
        allowed: ProjectTemplate.allKeys,
        allowedHelp: ProjectTemplate.allowedHelp,
      )
      ..addOption(
        'org',
        abbr: 'o',
        help: 'Organization name (e.g., com.example)',
      )
      ..addOption('description', abbr: 'd', help: 'Project description')
      ..addMultiOption(
        'platforms',
        abbr: 'p',
        help: 'Target platforms (e.g., android, ios)',
        allowed: ['android', 'ios', 'web', 'windows', 'macos', 'linux'],
        splitCommas: true,
      )
      ..addFlag(
        'full',
        abbr: 'f',
        help: 'Generate full project structure with all directories',
        defaultsTo: false,
      );
  }

  @override
  Future<int> run() async {
    try {
      // Validate project name argument
      // handle inputs
      final CreateData inputs = await CreateInputs(
        argResults!,
        prompt: _prompt,
      ).handle();

      // execute creation
      final CreateServiceFactory factory = CreateServiceFactory(_logger);

      // create project job
      final CreateJob create = CreateJob(
        inputs,
        flutterService: factory.createFlutter(),
        masonService: factory.createMason(),
        dependencyService: factory.createDependency(),
        postGenService: factory.createPostGen(),
        logger: _logger,
      );
      return await create.execute();
    } catch (e, s) {
      _logger.err('❌ Error: $e');
      _logger.detail(s.toString());
      return ExitCode.software.code;
    }
  }
}
