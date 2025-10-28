import 'dart:io';
import 'dart:convert';

import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

/// Implementation of locale generation service
///
/// Handles validation, processing, and generation of GetX locale translations
/// from JSON files following clean architecture principles.
class LocaleGeneratorService implements LocaleGeneratorServiceInterface {
  /// Logger instance for output and debugging
  final Logger logger;

  /// Creates a new locale generator service
  LocaleGeneratorService({Logger? logger}) : logger = logger ?? Logger();

  @override
  Future<Map<String, Map<String, dynamic>>> validateLocaleFiles({
    required String localesPath,
    required String targetDirPath,
    required LocaleKeyStyle keyStyle,
  }) async {
    final progress = logger.progress('Validating locale files...');

    try {
      final localesDir = Directory(path.join(targetDirPath, localesPath));

      if (!localesDir.existsSync()) {
        progress.fail('Locale directory not found');
        throw ValidationException.directoryNotFound(localesDir.path);
      }

      final jsonFiles = localesDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList();

      if (jsonFiles.isEmpty) {
        progress.fail('No JSON files found in locale directory');
        throw ValidationException.custom(
          'No JSON files found in locale directory',
          code: ValidationErrorCode.notFound,
          field: 'locales',
        );
      }

      logger.detail('Found ${jsonFiles.length} JSON files to process');
      final localeFiles = <String, Map<String, dynamic>>{};

      for (final file in jsonFiles) {
        final fileName = path.basenameWithoutExtension(file.path);

        // Validate locale code format (e.g., en, ar, en_US, ar_SA)
        if (!isValidLocaleCode(code: fileName)) {
          logger.warn('Skipping file with invalid locale code: $fileName');
          continue;
        }

        try {
          final content = await file.readAsString();
          final jsonData = jsonDecode(content) as Map<String, dynamic>;
          localeFiles[fileName] = jsonData;
          logger.detail('✓ Loaded locale: $fileName');
        } catch (e) {
          progress.fail('Failed to parse JSON in ${file.path}');
          throw ValidationException.custom(
            'Invalid JSON in file ${file.path}: $e',
            code: ValidationErrorCode.invalidFormat,
            field: 'json',
          );
        }
      }

      if (localeFiles.isEmpty) {
        progress.fail('No valid locale files found');
        throw ValidationException.custom(
          'No valid locale files found',
          code: ValidationErrorCode.notFound,
          field: 'locales',
        );
      }

      // Validate consistency across locales
      logger.detail(
        'Validating consistency across ${localeFiles.length} locales',
      );
      validateLocaleConsistency(localeFiles: localeFiles, keyStyle: keyStyle);

      progress.complete('✓ Validated ${localeFiles.length} locale files');
      return localeFiles;
    } catch (e) {
      progress.fail('Locale validation failed');
      rethrow;
    }
  }

  @override
  Future<File> generateTranslationsFile({
    required GenerateData data,
    required Map<String, Map<String, dynamic>> localeFiles,
  }) async {
    final progress = logger.progress('Generating translations file');

    try {
      final outputFile = File(data.outputPath);

      // Check if file exists and force is false
      if (outputFile.existsSync() && !data.force) {
        progress.fail('Output file already exists (use --force to overwrite)');
        throw ValidationException.custom(
          'Output file already exists. Use --force to overwrite.',
          code: ValidationErrorCode.duplicate,
          field: 'output',
        );
      }

      // Create output directory if needed
      logger.detail('Creating output directory: ${outputFile.parent.path}');
      await outputFile.parent.create(recursive: true);

      // Flatten all locale keys
      logger.detail('Processing ${localeFiles.length} locale files');
      final flattenedLocales = <String, Map<String, String>>{};
      for (final entry in localeFiles.entries) {
        flattenedLocales[entry.key] = flattenJson(
          json: entry.value,
          keyStyle: data.keyStyle,
        );
        logger.detail('✓ Flattened locale: ${entry.key}');
      }

      // Get all unique keys
      final allKeys = <String>{};
      for (final locale in flattenedLocales.values) {
        allKeys.addAll(locale.keys);
      }

      logger.detail('Found ${allKeys.length} unique translation keys');

      // Sort keys if requested
      final sortedKeys = data.sortKeys
          ? (allKeys.toList()..sort())
          : allKeys.toList();

      if (data.sortKeys) {
        logger.detail('Keys sorted alphabetically');
      }

      // Generate Dart code
      logger.detail('Generating Dart code with ${data.keyStyle.name} style');
      final dartContent = _generateDartTranslations(
        flattenedLocales,
        sortedKeys,
      );

      // Write file
      logger.detail('Writing to: ${outputFile.path}');
      await outputFile.writeAsString(dartContent);

      progress.complete(
        '✓ Generated translations file with ${sortedKeys.length} keys',
      );
      return outputFile;
    } catch (e) {
      progress.fail('Failed to generate translations file');
      rethrow;
    }
  }

  @override
  Map<String, String> flattenJson({
    required Map<String, dynamic> json,
    required LocaleKeyStyle keyStyle,
  }) {
    final flattened = <String, String>{};

    void flatten(Map<String, dynamic> obj, [String prefix = '']) {
      obj.forEach((key, value) {
        final newKey = prefix.isEmpty
            ? key
            : _combineKeys(prefix, key, keyStyle);

        if (value is Map<String, dynamic>) {
          flatten(value, newKey);
        } else {
          flattened[newKey] = value.toString();
        }
      });
    }

    flatten(json);
    return flattened;
  }

  @override
  void validateLocaleConsistency({
    required Map<String, Map<String, dynamic>> localeFiles,
    required LocaleKeyStyle keyStyle,
  }) {
    if (localeFiles.length < 2) return; // No need to validate single locale

    final firstLocale = localeFiles.values.first;
    final firstKeys = flattenJson(
      json: firstLocale,
      keyStyle: keyStyle,
    ).keys.toSet();

    for (final entry in localeFiles.entries) {
      final localeKeys = flattenJson(
        json: entry.value,
        keyStyle: keyStyle,
      ).keys.toSet();

      final missingKeys = firstKeys.difference(localeKeys);
      final extraKeys = localeKeys.difference(firstKeys);

      if (missingKeys.isNotEmpty) {
        logger.warn(
          'Locale ${entry.key} missing keys: ${missingKeys.join(', ')}',
        );
      }

      if (extraKeys.isNotEmpty) {
        logger.warn('Locale ${entry.key} extra keys: ${extraKeys.join(', ')}');
      }
    }
  }

  @override
  bool isValidLocaleCode({required String code}) {
    // Basic validation for locale codes like: en, ar, en_US, ar_SA
    final pattern = RegExp(r'^[a-z]{2}(_[A-Z]{2})?$');
    return pattern.hasMatch(code);
  }

  /// Combine keys based on the selected key style
  String _combineKeys(String prefix, String key, LocaleKeyStyle keyStyle) {
    switch (keyStyle) {
      case LocaleKeyStyle.dot:
        return '$prefix.$key';
      case LocaleKeyStyle.snake:
        return '${prefix}_$key';
      case LocaleKeyStyle.camelCase:
        return '$prefix${key[0].toUpperCase()}${key.substring(1)}';
    }
  }

  /// Generate Dart translations code
  String _generateDartTranslations(
    Map<String, Map<String, String>> locales,
    List<String> keys,
  ) {
    final buffer = StringBuffer();

    // File header
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// Generated by gexd locale generator');
    buffer.writeln('// ${DateTime.now().toIso8601String()}');
    buffer.writeln();
    buffer.writeln('// ignore_for_file: constant_identifier_names');
    buffer.writeln();

    // Imports
    buffer.writeln("import 'package:get/get.dart';");
    buffer.writeln();

    // Keys class
    buffer.writeln('class LocaleKeys {');
    for (final key in keys) {
      final dartKey = _toDartIdentifier(key);
      buffer.writeln("  static const String $dartKey = '$key';");
    }
    buffer.writeln('}');
    buffer.writeln();

    // Translations class
    buffer.writeln('class AppTranslations extends Translations {');
    buffer.writeln('  @override');
    buffer.writeln('  Map<String, Map<String, String>> get keys => {');

    for (final entry in locales.entries) {
      buffer.writeln("    '${entry.key}': {");
      for (final key in keys) {
        final value = entry.value[key] ?? key; // Fallback to key if missing
        final escapedValue = value.replaceAll("'", "\\'");
        buffer.writeln("      '$key': '$escapedValue',");
      }
      buffer.writeln('    },');
    }

    buffer.writeln('  };');
    buffer.writeln('}');

    return buffer.toString();
  }

  /// Convert locale key to valid Dart identifier
  String _toDartIdentifier(String key) {
    // Keep the original key format but ensure it's a valid Dart identifier
    String identifier = key;

    // Replace any invalid characters with underscores
    identifier = identifier.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');

    // Ensure it starts with letter or underscore
    if (identifier.isNotEmpty && RegExp(r'^[0-9]').hasMatch(identifier[0])) {
      identifier = 'key_$identifier';
    }

    // Handle empty case
    if (identifier.isEmpty) {
      identifier = 'empty_key';
    }

    return identifier;
  }
}
