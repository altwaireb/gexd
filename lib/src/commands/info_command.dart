import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import 'info/config_command.dart';
import 'info/template_command.dart';

/// Info command for displaying project and template information
class InfoCommand extends Command<int> {
  final Logger _logger;

  InfoCommand({Logger? logger}) : _logger = logger ?? Logger() {
    addSubcommand(ConfigCommand(logger: _logger));
    addSubcommand(TemplateCommand(logger: _logger));
  }

  @override
  String get name => 'info';

  @override
  String get description => 'Display project and template information';

  @override
  String get usage =>
      '''
$description

Usage: $invocation <subcommand>

Available subcommands:
  config      Show current project configuration
  template    Display template information and structure

Examples:
  gexd info config                    # Show project configuration
  gexd info template                  # List all available templates
  gexd info template clean            # Show clean template details
  gexd info template clean --full     # Show full directory structure
''';

  @override
  Future<int> run() async {
    // If no subcommand is provided, show help
    _logger.info(usage);
    return ExitCode.success.code;
  }
}
