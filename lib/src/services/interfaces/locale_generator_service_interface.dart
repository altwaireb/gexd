import 'dart:io';

import 'package:gexd/gexd.dart';

/// Interface for locale generation services
///
/// Provides methods for validating locale files, generating translations,
/// and managing locale-related operations following clean architecture principles.
abstract class LocaleGeneratorServiceInterface {
  /// Validate and load locale files from directory
  ///
  /// Returns a map of locale code to JSON data
  /// Throws [ValidationException] if validation fails
  Future<Map<String, Map<String, dynamic>>> validateLocaleFiles({
    required String localesPath,
    required String targetDirPath,
    required LocaleKeyStyle keyStyle,
  });

  /// Generate Dart translations file
  ///
  /// Takes validated locale files and generates GetX-compatible Dart code
  /// Returns the generated file
  Future<File> generateTranslationsFile({
    required Map<String, Map<String, dynamic>> localeFiles,
    required GenerateData data,
  });

  /// Flatten nested JSON structure based on key style
  ///
  /// Converts hierarchical JSON to flat key-value pairs
  Map<String, String> flattenJson({
    required Map<String, dynamic> json,
    required LocaleKeyStyle keyStyle,
  });

  /// Validate consistency across multiple locale files
  ///
  /// Checks for missing or extra keys between locales
  void validateLocaleConsistency({
    required Map<String, Map<String, dynamic>> localeFiles,
    required LocaleKeyStyle keyStyle,
  });

  /// Check if locale code follows valid format
  ///
  /// Validates codes like: en, ar, en_US, ar_SA
  bool isValidLocaleCode({required String code});
}
