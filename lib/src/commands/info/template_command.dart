import 'package:args/command_runner.dart';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

/// Command to display template information and structure
class TemplateCommand extends Command<int> {
  final Logger _logger;

  TemplateCommand({Logger? logger}) : _logger = logger ?? Logger() {
    argParser.addFlag(
      'full',
      help: 'Show full directory structure including optional components',
      negatable: false,
    );
  }

  @override
  String get name => 'template';

  @override
  String get description => 'Display template information and structure';

  @override
  String get usage =>
      '''
$description

Usage: $invocation [template_name] [options]

Arguments:
  <template_name>    Template to display (getx, clean)
                     [Optional: Shows all templates if not specified]

Options:
${argParser.usage}

Examples:
  gexd info template                  # List all available templates
  gexd info template clean            # Show clean template details
  gexd info template clean --full     # Show full directory structure
  gexd info template getx --full      # Show GetX template with full structure
''';

  @override
  Future<int> run() async {
    final templateName = argResults?.rest.isNotEmpty == true
        ? argResults!.rest.first
        : null;
    final showFull = argResults?['full'] == true;

    if (templateName == null) {
      // Show all available templates
      _displayAllTemplates();
    } else {
      // Show specific template
      try {
        final template = ProjectTemplate.fromKey(templateName);
        _displayTemplateDetails(template, showFull);
      } catch (e) {
        _logger.err('❌ Unknown template: $templateName');
        _logger.info(
          '💡 Available templates: ${ProjectTemplate.allKeys.join(', ')}',
        );
        return ExitCode.usage.code;
      }
    }

    return ExitCode.success.code;
  }

  void _displayAllTemplates() {
    _logger.info('');
    _logger.info('🏗️ ${lightCyan.wrap('Available Templates')}');
    _logger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _logger.info('');

    for (final template in ProjectTemplate.values) {
      final info = _getTemplateInfo(template);

      _logger.info(
        '${green.wrap('📁 ${template.displayName}')} ${darkGray.wrap('(${template.key})')}',
      );
      _logger.info(
        '   ${lightBlue.wrap('Description:')} ${info['description']}',
      );
      _logger.info('   ${lightBlue.wrap('Best For:')} ${info['bestFor']}');
      _logger.info('');
    }

    _logger.info(
      '💡 ${darkGray.wrap('Use')} ${yellow.wrap('gexd info template <name> --full')} ${darkGray.wrap('to see detailed structure')}',
    );
    _logger.info('');
  }

  void _displayTemplateDetails(ProjectTemplate template, bool showFull) {
    final info = _getTemplateInfo(template);

    _logger.info('');
    _logger.info(
      '🏗️ ${lightCyan.wrap(template.displayName)} ${darkGray.wrap('Template')}',
    );
    _logger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _logger.info('');

    // Template information
    _logger.info('${lightBlue.wrap('📖 Description:')}');
    _logger.info('   ${info['description']}');
    _logger.info('');

    _logger.info('${lightBlue.wrap('🎯 Best For:')}');
    _logger.info('   ${info['bestFor']}');
    _logger.info('');

    _logger.info('${lightBlue.wrap('✨ Key Features:')}');
    _logger.info('   ${info['features']}');
    _logger.info('');

    // Directory structure
    _logger.info('${lightBlue.wrap('📁 Directory Structure:')}');
    _logger.info('');

    if (showFull) {
      _displayFullStructure(template);
    } else {
      _displayBasicStructure(template);
      _logger.info('');
      _logger.info(
        '💡 ${darkGray.wrap('Use')} ${yellow.wrap('--full')} ${darkGray.wrap('flag to see the complete directory structure')}',
      );
    }
    _logger.info('');
  }

  void _displayBasicStructure(ProjectTemplate template) {
    final structure = ArchitectureHelpers.getTreeStructure(
      template,
      full: false,
    );
    _logger.info(structure);
  }

  void _displayFullStructure(ProjectTemplate template) {
    final structure = ArchitectureHelpers.getTreeStructure(
      template,
      full: true,
    );
    final description = ArchitectureHelpers.getDescription(template);

    _logger.info(structure);
    _logger.info('');
    _logger.info('${lightBlue.wrap('📋 Architecture Details:')}');
    _logger.info(description);
  }

  Map<String, String> _getTemplateInfo(ProjectTemplate template) {
    switch (template) {
      case ProjectTemplate.getx:
        return {
          'description':
              'Feature-based modular architecture with GetX state management.\n   Perfect for rapid development with reactive programming patterns.',
          'bestFor':
              'Medium to large applications, rapid prototyping, GetX enthusiasts',
          'features':
              'Reactive state management, automatic dependency injection,\n   feature-based organization, built-in routing, minimal boilerplate',
        };
      case ProjectTemplate.clean:
        return {
          'description':
              'Domain-driven design with clear separation of concerns.\n   Follows Uncle Bob\'s Clean Architecture principles for maximum maintainability.',
          'bestFor':
              'Enterprise applications, complex business logic, long-term projects',
          'features':
              'Layered architecture, dependency inversion principle,\n   high testability, framework independence, clear boundaries',
        };
    }
  }
}
