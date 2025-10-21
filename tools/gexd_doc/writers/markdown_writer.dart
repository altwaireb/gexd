import 'dart:io';

import '../config/doc_config.dart';

/// Writes professional Markdown documentation for individual commands
///
/// This module handles the generation of well-formatted Markdown files
/// that are compatible with GitBook and other documentation platforms.

/// Writes a complete Markdown documentation file for a command
///
/// Creates a professionally formatted Markdown document containing
/// all command information including usage, options, flags, and examples.
///
/// Parameters:
/// - [name]: The command name (e.g., 'create')
/// - [className]: The class name (e.g., 'CreateCommand')
/// - [description]: The command description with formatting
/// - [aliases]: List of command aliases
/// - [detailedUsage]: Detailed usage information from the command's usage getter
/// - [options]: List of available options with detailed information
/// - [flags]: List of available flags with detailed information
/// - [docPath]: Output file path for the documentation
Future<void> writeCommandDoc({
  required String name,
  required String className,
  required String description,
  required List<String> aliases,
  required String detailedUsage,
  required List<Map<String, dynamic>> options,
  required List<Map<String, dynamic>> flags,
  required String docPath,
}) async {
  final buffer = StringBuffer();

  // Write the main header (if enabled)
  if (DocConfig.includeHeader) {
    buffer.writeln('# `$name` Command\n');

    if (DocConfig.showClassName) {
      buffer.writeln('**Class:** `$className`\n');
    }

    buffer.writeln('---\n');
  }

  // Write description section (if enabled)
  if (DocConfig.includeContent && DocConfig.showDescription) {
    buffer
      ..writeln('## 📝 Description\n')
      ..writeln('$description\n')
      ..writeln('---\n');
  }

  // Write usage section (if enabled)
  if (DocConfig.includeContent && DocConfig.showUsage) {
    buffer
      ..writeln('## ⚙️ Usage\n')
      ..writeln('```bash')
      ..writeln('gexd $name [options]')
      ..writeln('```\n')
      ..writeln('---\n');
  }

  // Write detailed usage section (if enabled and available)
  if (DocConfig.includeContent &&
      DocConfig.showDetailedUsage &&
      detailedUsage.isNotEmpty) {
    buffer
      ..writeln('## 📖 Detailed Usage\n')
      ..writeln('```text')
      ..writeln(detailedUsage)
      ..writeln('```\n')
      ..writeln('---\n');
  }

  // Write aliases section if available and enabled
  if (DocConfig.includeContent && DocConfig.showAliases && aliases.isNotEmpty) {
    buffer
      ..writeln('## 🧩 Aliases\n')
      ..writeln('`${aliases.join('`, `')}`\n')
      ..writeln('---\n');
  }

  // Write detailed options section if available and enabled
  if (DocConfig.includeContent && DocConfig.showOptions && options.isNotEmpty) {
    buffer.writeln('## ⚙️ Options\n');

    for (final option in options) {
      final name = option['name'] as String;
      final help = option['help'] as String;
      final abbr = option['abbr'] as String;
      final defaultsTo = option['defaultsTo'] as String;
      final enumInfo = option['enumInfo'] as Map<String, dynamic>?;
      final optionType = option['type'] as String? ?? 'option';
      final allowedValues = option['allowed'] as List<dynamic>? ?? [];

      // Write option header
      buffer.write('### `--$name`');
      if (DocConfig.showOptionAbbr && abbr.isNotEmpty) {
        buffer.write(' (`-$abbr`)');
      }
      buffer.writeln('\n');

      // Write help text if available
      if (help.isNotEmpty) {
        buffer.writeln('**Description:** $help\n');
      }

      // Write type information for multiOption (if enabled)
      if (DocConfig.showMultiOptionType && optionType == 'multiOption') {
        buffer.writeln('**Type:** Multiple values (comma-separated)\n');
      }

      // Write enum information if available and enabled
      if (DocConfig.showEnumDetails && enumInfo != null) {
        final values = enumInfo['values'] as List<dynamic>;

        buffer.writeln(
          '**Format:** `${values.map((v) => v['key']).join('|')}`\n',
        );
        buffer.writeln('**Available Options:**');

        for (final value in values) {
          final key = value['key'] as String;
          final description = value['description'] as String;
          buffer.writeln('- `$key` → $description');
        }
        buffer.writeln();
      } else if (allowedValues.isNotEmpty) {
        // Write allowed values if no enum info
        buffer.writeln('**Format:** `${allowedValues.join('|')}`\n');
        buffer.writeln('**Available Options:**');

        for (final value in allowedValues) {
          buffer.writeln('- `$value`');
        }
        buffer.writeln();
      }

      // Write default value if available and enabled
      if (DocConfig.showOptionDefaults && defaultsTo.isNotEmpty) {
        buffer.writeln('**Default:** `$defaultsTo`\n');
      }

      buffer.writeln('---\n');
    }
  }

  // Write detailed flags section if available and enabled
  if (DocConfig.includeContent && DocConfig.showFlags && flags.isNotEmpty) {
    buffer.writeln('## 🚩 Flags\n');

    for (final flag in flags) {
      final name = flag['name'] as String;
      final help = flag['help'] as String;
      final abbr = flag['abbr'] as String;
      final defaultsTo = flag['defaultsTo'] as String;

      buffer.write('- **`--$name`**');
      if (DocConfig.showFlagAbbr && abbr.isNotEmpty) {
        buffer.write(' (`-$abbr`)');
      }

      if (help.isNotEmpty) {
        buffer.write(' → $help');
      }

      if (DocConfig.showFlagDefaults && defaultsTo != 'false') {
        buffer.write(' (default: $defaultsTo)');
      }

      buffer.writeln();
    }

    buffer.writeln('\n---\n');
  }

  // Write footer (if enabled)
  if (DocConfig.includeFooter && DocConfig.showGeneratorCredit) {
    buffer.writeln('_Generated automatically by `gexd_doc`_');
  }

  // Ensure the output directory exists
  final file = File(docPath);
  await file.create(recursive: true);

  // Write the content to file
  await file.writeAsString(buffer.toString());
}
