import 'dart:io';
import 'package:path/path.dart' as p;

import 'extractors/command_extractor.dart';
import 'writers/markdown_writer.dart';
import 'writers/summary_writer.dart';

/// Professional documentation generator for Dart CLI applications
///
/// This tool automatically parses command files and generates structured
/// Markdown documentation with GitBook compatibility.
///
/// Usage:
/// ```bash
/// dart run tool/gexd_doc/generate_doc.dart [version]
/// ```
///
/// Example:
/// ```bash
/// dart run tool/gexd_doc/generate_doc.dart 1.x
/// ```
Future<void> main(List<String> args) async {
  final version = args.isNotEmpty ? args.first : '1.x';
  final commandsDir = Directory('lib/src/commands');
  final docsDir = Directory('doc/.$version/commands');
  final summaryFile = File('doc/.$version/SUMMARY.md');

  if (!commandsDir.existsSync()) {
    stderr.writeln('❌ Commands directory not found: ${commandsDir.path}');
    exit(1);
  }

  print('🚀 Generating professional documentation for version $version...\n');

  // Ensure output directories exist
  docsDir.createSync(recursive: true);
  summaryFile.parent.createSync(recursive: true);

  // Discover all command files
  final commandFiles = await commandsDir
      .list(recursive: true)
      .where(
        (entity) => entity is File && entity.path.endsWith('_command.dart'),
      )
      .cast<File>()
      .toList();

  print('📁 Found ${commandFiles.length} command files\n');

  final commandNames = <String>[];

  // Process each command file
  for (final file in commandFiles) {
    try {
      final content = await file.readAsString();
      final extractor = CommandExtractor(content, filePath: file.path);

      // Generate the documentation path
      final relativePath = p.relative(file.path, from: commandsDir.path);
      final docPath = p
          .join(docsDir.path, relativePath)
          .replaceAll('.dart', '.md');

      // Write the command documentation
      await writeCommandDoc(
        name: extractor.name,
        className: extractor.className,
        description: extractor.description,
        aliases: extractor.aliases,
        detailedUsage: extractor.detailedUsage,
        options: extractor.options,
        flags: extractor.flags,
        docPath: docPath,
      );

      // Add command name for summary generation
      commandNames.add(extractor.name);

      print('  ✅ ${extractor.name} → $docPath');
    } catch (e) {
      stderr.writeln('⚠️ Error processing ${file.path}: $e');
    }
  }

  // Generate introduction README
  await writeIntroduction(outputDir: 'doc/.$version', commands: commandNames);

  print('📚 Documentation structure generated in: doc/.$version/');
  print('🎉 Professional documentation generated successfully!');
  print('📖 Total commands documented: ${commandNames.length}');
  print('');
  print('📋 Next steps:');
  print('1. Review generated documentation in doc/.$version/');
  print('2. Make any manual edits or improvements');
  print('3. Copy final version to doc/$version/ for publishing');
  print('4. Commit the published version to git');
}
