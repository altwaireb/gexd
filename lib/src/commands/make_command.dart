import 'package:args/command_runner.dart';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

class MakeCommand extends Command<int> {
  final Logger _logger;

  MakeCommand({Logger? logger}) : _logger = logger ?? Logger() {
    addSubcommand(BindingCommand(logger: _logger));
    addSubcommand(ControllerCommand(logger: _logger));
    addSubcommand(ViewCommand(logger: _logger));
    addSubcommand(ScreenCommand(logger: _logger));
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
