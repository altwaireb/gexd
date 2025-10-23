import 'dart:io';

/// Generates GitBook-compatible SUMMARY.md with navigation structure
///
/// This module creates the table of contents file that GitBook uses
/// for sidebar navigation, organizing commands into logical groups.

/// Writes the main SUMMARY.md file for GitBook navigation
///
/// Creates a GitBook-compatible SUMMARY.md file with organized sections
/// for different types of commands and documentation.
///
/// Parameters:
/// - [commands]: List of command names to include in the summary
/// - [outputDir]: Base directory where documentation files are located
Future<void> writeSummary({
  required List<String> commands,
  required String outputDir,
}) async {
  final buffer = StringBuffer();

  // Write the main title
  buffer
    ..writeln('# Summary\n')
    ..writeln('## 🚀 GEXD Documentation\n')
    ..writeln('* [Introduction](README.md)\n');

  // Write commands section
  if (commands.isNotEmpty) {
    buffer.writeln('## 📋 Commands\n');

    for (final command in commands) {
      // Convert command name to title case for display
      final displayName = _formatCommandName(command);
      buffer.writeln('* [$displayName]($command.md)');
    }

    buffer.writeln();
  }

  // Write additional sections
  buffer
    ..writeln('## 📚 Additional Resources\n')
    ..writeln('* [Contributing](CONTRIBUTING.md)')
    ..writeln('* [Changelog](CHANGELOG.md)')
    ..writeln('* [License](LICENSE.md)');

  // Write to SUMMARY.md file
  final summaryPath = '$outputDir/SUMMARY.md';
  final file = File(summaryPath);
  await file.create(recursive: true);
  await file.writeAsString(buffer.toString());

  print('📋 Generated SUMMARY.md with ${commands.length} commands');
}

/// Formats a command name for display in the summary
///
/// Converts snake_case or lowercase command names to proper title case
/// for better presentation in the documentation navigation.
///
/// Example: 'create_project' -> 'Create Project'
String _formatCommandName(String commandName) {
  return commandName
      .split('_')
      .map(
        (word) => word.isEmpty
            ? word
            : word[0].toUpperCase() + word.substring(1).toLowerCase(),
      )
      .join(' ');
}

/// Writes an introduction README.md for the documentation
///
/// Creates a welcoming README.md file that serves as the landing page
/// for the generated documentation with overview and quick start guide.
///
/// Parameters:
/// - [outputDir]: Directory where the README.md should be created
/// - [commands]: List of available commands for the quick reference
Future<void> writeIntroduction({
  required String outputDir,
  required List<String> commands,
}) async {
  final buffer = StringBuffer();

  // Write the main header
  buffer
    ..writeln('# GEXD Documentation\n')
    ..writeln('Welcome to the **GEXD** command-line tool documentation!\n')
    ..writeln(
      'GEXD is a powerful Flutter/GetX project generator that helps you',
    )
    ..writeln(
      'quickly scaffold new projects with clean architecture and best practices.\n',
    )
    ..writeln('---\n');

  // Write quick start section
  buffer
    ..writeln('## 🚀 Quick Start\n')
    ..writeln('```bash')
    ..writeln('# Install GEXD globally')
    ..writeln('dart pub global activate gexd\n')
    ..writeln('# Create a new project')
    ..writeln('gexd create my_app\n')
    ..writeln('# Get help')
    ..writeln('gexd --help')
    ..writeln('```\n')
    ..writeln('---\n');

  // Write available commands section
  if (commands.isNotEmpty) {
    buffer.writeln('## 📋 Available Commands\n');

    for (final command in commands) {
      final displayName = _formatCommandName(command);
      buffer.writeln(
        '- **[$displayName]($command.md)** - Generate Flutter/GetX projects',
      );
    }

    buffer
      ..writeln()
      ..writeln('---\n');
  }

  // Write features section
  buffer
    ..writeln('## ✨ Features\n')
    ..writeln(
      '- 🏗️ **Clean Architecture** - Well-structured project templates',
    )
    ..writeln('- 🎨 **GetX Integration** - State management and routing')
    ..writeln('- 📱 **Flutter Ready** - Mobile-first development')
    ..writeln('- ⚡ **Fast Setup** - Get started in seconds')
    ..writeln('- 🛠️ **Customizable** - Flexible project configuration\n')
    ..writeln('---\n');

  // Write footer
  buffer
    ..writeln('## 📖 Navigation\n')
    ..writeln(
      'Use the sidebar to explore detailed documentation for each command.',
    )
    ..writeln(
      'Each command page includes usage examples, available options, and practical guides.\n',
    )
    ..writeln('_This documentation is generated automatically by `gexd_doc`_');

  // Write to README.md file
  final readmePath = '$outputDir/README.md';
  final file = File(readmePath);
  await file.create(recursive: true);
  await file.writeAsString(buffer.toString());

  print('📖 Generated introduction README.md');
}
