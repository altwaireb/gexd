import 'package:args/command_runner.dart';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

/// Main make command that contains subcommands for generating various project files and components.
/// Available subcommands:
/// - `binding`: Generate a GetX binding file
/// - `controller`: Generate a GetX controller file
/// - `entity`: Generate a domain entity for Clean Architecture
/// - `exception`: Generate a custom exception class
/// - `interface`: Generate a Dart interface
/// - `middleware`: Generate a GetX middleware file
/// - `model`: Generate a Dart model class with JSON serialization
/// - `provider`: Generate a data provider class
/// - `repository`: Generate a repository class
/// - `screen`: Generate a Flutter screen (view) with GetX structure
/// - `service`: Generate a service class
/// - `view`: Generate a Flutter view widget
class MakeCommand extends Command<int> {
  final Logger _logger;

  MakeCommand({Logger? logger}) : _logger = logger ?? Logger() {
    addSubcommand(BindingCommand(logger: _logger));
    addSubcommand(ControllerCommand(logger: _logger));
    addSubcommand(EntityCommand(logger: _logger));
    addSubcommand(ExceptionCommand(logger: _logger));
    addSubcommand(InterfaceCommand(logger: _logger));
    addSubcommand(MiddlewareCommand(logger: _logger));
    addSubcommand(ModelCommand(logger: _logger));
    addSubcommand(ProviderCommand(logger: _logger));
    addSubcommand(RepositoryCommand(logger: _logger));
    addSubcommand(ScreenCommand(logger: _logger));
    addSubcommand(ServiceCommand(logger: _logger));
    addSubcommand(ViewCommand(logger: _logger));
  }

  @override
  String get name => 'make';

  @override
  String get description => 'Generate various project files and components.';

  @override
  Future<int> run() async {
    // Validate that we're in a Gexd project
    final isInProject = await ConfigService.isInGexdProject();
    if (!isInProject) {
      _logger.err('❌ Not in a Gexd project directory');
      _logger.info('');
      _logger.info(
        '💡 Make sure you are in a directory that contains .gexd/config.yaml',
      );
      _logger.info('💡 Create a new project with: gexd create <project_name>');
      return ExitCode.config.code;
    }

    // If no subcommand is provided, show help
    _logger.info(usage);
    return ExitCode.success.code;
  }
}
