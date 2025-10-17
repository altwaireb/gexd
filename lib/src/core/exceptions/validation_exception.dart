/// Thrown when validation of arguments, inputs, or configuration fails.
///
/// This exception provides detailed information about validation failures,
/// including the specific field, value, and error type to help with debugging
/// and user-friendly error reporting.
library;

import 'package:gexd/src/core/messages/validation_messages.dart';

enum ValidationErrorCode {
  /// Field is empty when a value is required
  empty,

  /// Value is shorter than the minimum required length
  tooShort,

  /// Value exceeds the maximum allowed length
  tooLong,

  /// Value contains non-ASCII characters when ASCII-only is required
  invalidAscii,

  /// Value format doesn't match the expected pattern
  invalidFormat,

  /// Referenced item or resource was not found
  notFound,

  /// Value is outside the allowed range
  outOfRange,

  /// Value already exists when uniqueness is required
  duplicate,

  /// Value is not in the list of allowed options
  invalidOption,

  /// Required dependency is missing
  missingDependency,
}

class ValidationException implements Exception {
  /// Human-readable error message
  final String message;

  /// Specific error code for programmatic handling
  final ValidationErrorCode code;

  /// The field name that failed validation (optional)
  final String? field;

  /// The actual value that failed validation (optional)
  final Object? value;

  /// Additional context or details about the validation failure
  final Map<String, dynamic>? details;

  const ValidationException(
    this.message, {
    required this.code,
    this.field,
    this.value,
    this.details,
  });

  /// Factory constructor for empty field validation
  factory ValidationException.empty(String field) {
    return ValidationException(
      ValidationMessages.empty.format({'field': field}),
      code: ValidationErrorCode.empty,
      field: field,
    );
  }

  /// Factory constructor for length validation
  factory ValidationException.tooShort(
    String field,
    Object value,
    int minLength,
  ) {
    return ValidationException(
      ValidationMessages.tooShort.format({
        'field': field,
        'minLength': minLength.toString(),
      }),
      code: ValidationErrorCode.tooShort,
      field: field,
      value: value,
      details: {
        'minLength': minLength,
        'actualLength': value.toString().length,
      },
    );
  }

  /// Factory constructor for length validation
  factory ValidationException.tooLong(
    String field,
    Object value,
    int maxLength,
  ) {
    return ValidationException(
      ValidationMessages.tooLong.format({
        'field': field,
        'maxLength': maxLength.toString(),
      }),
      code: ValidationErrorCode.tooLong,
      field: field,
      value: value,
      details: {
        'maxLength': maxLength,
        'actualLength': value.toString().length,
      },
    );
  }

  /// Factory constructor for format validation
  factory ValidationException.invalidFormat(
    String field,
    Object value, {
    String? expectedFormat,
  }) {
    final formatSuffix = expectedFormat != null
        ? ' (expected: $expectedFormat)'
        : '';
    return ValidationException(
      ValidationMessages.invalidFormat.format({
        'field': field,
        'expectedFormat': formatSuffix,
      }),
      code: ValidationErrorCode.invalidFormat,
      field: field,
      value: value,
      details: expectedFormat != null
          ? {'expectedFormat': expectedFormat}
          : null,
    );
  }

  /// Factory constructor for not found validation
  factory ValidationException.notFound(String item, {Object? identifier}) {
    final idSuffix = identifier != null ? ' with identifier "$identifier"' : '';
    return ValidationException(
      ValidationMessages.notFound.format({
        'item': item,
        'identifier': idSuffix,
      }),
      code: ValidationErrorCode.notFound,
      details: identifier != null ? {'identifier': identifier} : null,
    );
  }

  /// Factory constructor for invalid option validation
  factory ValidationException.invalidOption(
    String field,
    Object value,
    List<String> validOptions,
  ) {
    return ValidationException(
      ValidationMessages.invalidOption.format({
        'field': field,
        'value': value.toString(),
        'validOptions': validOptions.join(', '),
      }),
      code: ValidationErrorCode.invalidOption,
      field: field,
      value: value,
      details: {'validOptions': validOptions},
    );
  }

  /// Factory constructor for duplicate validation
  factory ValidationException.duplicate(String field, Object value) {
    return ValidationException(
      ValidationMessages.duplicate.format({
        'field': field,
        'value': value.toString(),
      }),
      code: ValidationErrorCode.duplicate,
      field: field,
      value: value,
    );
  }

  /// Factory constructor for directory not found validation
  factory ValidationException.directoryNotFound(String path) {
    return ValidationException(
      ValidationMessages.directoryNotFound.format({'path': path}),
      code: ValidationErrorCode.notFound,
      field: 'directory',
      value: path,
    );
  }

  /// Factory constructor for not Flutter project validation
  factory ValidationException.notFlutterProject(String path) {
    return ValidationException(
      ValidationMessages.notFlutterProject.format({'path': path}),
      code: ValidationErrorCode.invalidFormat,
      field: 'project',
      value: path,
    );
  }

  /// Factory constructor for invalid path format validation
  factory ValidationException.invalidPath(String path, String reason) {
    return ValidationException(
      'Invalid path format: "$path". $reason',
      code: ValidationErrorCode.invalidFormat,
      field: 'path',
      value: path,
      details: {'reason': reason},
    );
  }

  /// Factory constructor for path depth validation
  factory ValidationException.pathTooDeep(String path, int maxDepth) {
    return ValidationException(
      'Path "$path" exceeds maximum depth of $maxDepth levels.',
      code: ValidationErrorCode.outOfRange,
      field: 'path depth',
      value: path,
      details: {'maxDepth': maxDepth, 'actualDepth': path.split('/').length},
    );
  }

  /// Factory constructor for file not found validation
  factory ValidationException.fileNotFound(String filePath) {
    return ValidationException(
      'File not found: $filePath',
      code: ValidationErrorCode.notFound,
      field: 'file',
      value: filePath,
      details: {'filePath': filePath},
    );
  }

  /// Factory constructor for missing dependency validation
  factory ValidationException.missingDependency(
    String dependency, {
    String? hint,
  }) {
    final message =
        'Required dependency "$dependency" is missing.${hint != null ? ' $hint' : ''}';
    return ValidationException(
      message,
      code: ValidationErrorCode.missingDependency,
      field: 'dependency',
      value: dependency,
      details: {'dependency': dependency, if (hint != null) 'hint': hint},
    );
  }

  /// Factory constructor for custom validation messages
  factory ValidationException.custom(
    String message, {
    ValidationErrorCode code = ValidationErrorCode.invalidFormat,
    String? field,
    Object? value,
  }) {
    return ValidationException(message, code: code, field: field, value: value);
  }

  @override
  String toString() {
    final buffer = StringBuffer('ValidationException: $message');

    if (field != null) {
      buffer.write(' (field: $field)');
    }

    if (value != null) {
      buffer.write(' (value: $value)');
    }

    buffer.write(' [code: $code]');

    return buffer.toString();
  }

  /// Returns a detailed representation including all available information
  String toDetailedString() {
    final buffer = StringBuffer(toString());

    if (details != null && details!.isNotEmpty) {
      buffer.write('\nDetails: $details');
    }

    return buffer.toString();
  }

  /// Returns only the user-friendly message without technical details
  String toUserMessage() => message;

  /// Checks if this exception matches a specific error code
  bool hasCode(ValidationErrorCode errorCode) => code == errorCode;

  /// Checks if this exception is related to a specific field
  bool isForField(String fieldName) => field == fieldName;
}
