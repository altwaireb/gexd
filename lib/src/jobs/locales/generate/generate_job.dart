import 'dart:io';

import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

/// Job to generate localization files
/// Validates locale files and generates translations file
/// Uses LocaleGeneratorService for validation and generation
class GenerateJob {
  final GenerateData data;
  final Logger logger;
  final LocaleGeneratorServiceInterface localeService;

  GenerateJob(
    this.data, {
    Logger? logger,
    LocaleGeneratorServiceInterface? localeService,
  }) : logger = logger ?? Logger(),
       localeService = localeService ?? LocaleGeneratorService(logger: logger);

  Future<int> execute() async {
    try {
      // Validate locale files using service
      final localeFiles = await localeService.validateLocaleFiles(
        localesPath: data.from,
        targetDirPath: data.targetDir.path,
        keyStyle: data.keyStyle,
      );

      // Generate translations file using service
      final outputFile = await localeService.generateTranslationsFile(
        localeFiles: localeFiles,
        data: data,
      );

      _logSummary(outputFile);

      return ExitCode.success.code;
    } catch (e) {
      // Re-throw to let GexdCommandRunner handle it centrally
      rethrow;
    }
  }

  void _logSummary(File outputFile) {
    logger.info('');
    logger.info('Locale generation summary:');
    logger.info('  From: ${data.from}');
    logger.info('  Output: ${data.outputPath}');
    logger.info('  Key Style: ${data.keyStyle.name}');
    logger.info('  Sort Keys: ${data.sortKeys}');
    logger.info('');
    logger.info('Generated file:');
    logger.info(
      ' - ${path.relative(outputFile.path, from: data.targetDir.path)}',
    );
    logger.info('');
    logger.info('Locale translations generated successfully!');
  }
}
