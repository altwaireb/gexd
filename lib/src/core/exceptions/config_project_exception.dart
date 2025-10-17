/// Thrown when project configuration or environment setup fails.
///
/// This exception is designed to handle errors related to invalid,
/// missing, or corrupted configuration files and project states.
///
/// Example use cases:
/// - Missing `.gexd` configuration file
/// - Invalid or unsupported project template
/// - Missing environment variables or paths
/// - Inconsistent project structure
library;

enum ConfigProjectErrorCode {
  /// The configuration file or value is missing
  missingConfig,

  /// The project type or template could not be detected
  unknownTemplate,

  /// The configuration format is invalid or corrupted
  invalidFormat,

  /// The project directory is not initialized or incomplete
  uninitializedProject,

  /// A required dependency or setup file was not found
  missingDependency,

  /// Generic configuration error
  generic,
}

class ConfigProjectException implements Exception {
  /// Human-readable error message
  final String message;

  /// Specific error code for programmatic handling
  final ConfigProjectErrorCode code;

  /// The field or configuration key that failed validation (optional)
  final String? field;

  /// The actual value that caused the error (optional)
  final Object? value;

  /// Additional diagnostic context
  final Map<String, dynamic>? details;

  const ConfigProjectException(
    this.message, {
    required this.code,
    this.field,
    this.value,
    this.details,
  });

  // ───────────────────────────────────────────────
  // 🔸 FACTORY CONSTRUCTORS
  // ───────────────────────────────────────────────

  /// Missing configuration or project setup
  factory ConfigProjectException.missing(String field) {
    return ConfigProjectException(
      'Missing required configuration: "$field".',
      code: ConfigProjectErrorCode.missingConfig,
      field: field,
    );
  }

  /// Invalid or corrupted configuration format
  factory ConfigProjectException.invalidFormat(
    String field,
    Object value, {
    String? expectedFormat,
  }) {
    final formatSuffix = expectedFormat != null
        ? ' Expected format: $expectedFormat.'
        : '';
    return ConfigProjectException(
      'Invalid configuration format for "$field".$formatSuffix',
      code: ConfigProjectErrorCode.invalidFormat,
      field: field,
      value: value,
      details: expectedFormat != null
          ? {'expectedFormat': expectedFormat}
          : null,
    );
  }

  /// Unknown or unsupported project template
  factory ConfigProjectException.unknownTemplate([Object? value]) {
    return ConfigProjectException(
      'Could not detect a valid project template.',
      code: ConfigProjectErrorCode.unknownTemplate,
      field: 'template',
      value: value,
      details: {
        'hint': 'Make sure this is a valid Gexd project with a known template.',
      },
    );
  }

  /// Project has not been initialized correctly
  factory ConfigProjectException.uninitializedProject(String path) {
    return ConfigProjectException(
      'The project at "$path" is not initialized properly.',
      code: ConfigProjectErrorCode.uninitializedProject,
      field: 'project',
      value: path,
    );
  }

  /// Missing dependency or setup file
  factory ConfigProjectException.missingDependency(String dependency) {
    return ConfigProjectException(
      'Missing required dependency or setup file: "$dependency".',
      code: ConfigProjectErrorCode.missingDependency,
      field: dependency,
    );
  }

  /// Custom configuration error
  factory ConfigProjectException.custom(
    String message, {
    ConfigProjectErrorCode code = ConfigProjectErrorCode.generic,
    String? field,
    Object? value,
    Map<String, dynamic>? details,
  }) {
    return ConfigProjectException(
      message,
      code: code,
      field: field,
      value: value,
      details: details,
    );
  }

  // ───────────────────────────────────────────────
  // 🔸 UTILITIES
  // ───────────────────────────────────────────────

  @override
  String toString() {
    final buffer = StringBuffer('ConfigProjectException: $message');

    if (field != null) buffer.write(' (field: $field)');
    if (value != null) buffer.write(' (value: $value)');
    buffer.write(' [code: $code]');

    return buffer.toString();
  }

  /// Returns a user-friendly message
  String toUserMessage() => message;

  /// Returns detailed debugging info
  String toDetailedString() {
    final buffer = StringBuffer(toString());
    if (details != null && details!.isNotEmpty) {
      buffer.write('\nDetails: $details');
    }
    return buffer.toString();
  }

  /// Checks if exception matches specific code
  bool hasCode(ConfigProjectErrorCode errorCode) => code == errorCode;
}
