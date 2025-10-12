import 'base_exception.dart';

/// Error codes for Mason-related failures
enum MasonErrorCode {
  /// Brick not found
  brickNotFound,

  /// Invalid brick configuration
  invalidBrickConfig,

  /// Brick generation failed
  generationFailed,

  /// Brick installation failed
  installationFailed,

  /// Brick cache error
  cacheError,

  /// Brick dependency error
  dependencyError,

  /// Brick validation error
  validationError,

  /// Mason configuration error
  configurationError,

  /// Hook execution failed
  hookExecutionFailed,

  /// Variable processing error
  variableProcessingError,
}

/// Thrown when Mason encounters an error.
class MasonBrickException extends BaseException {
  final MasonErrorCode errorCode;
  final String? brickName;
  final String? brickPath;
  final Map<String, dynamic>? details;

  MasonBrickException(
    super.message, {
    required this.errorCode,
    this.brickName,
    this.brickPath,
    this.details,
    super.code,
  });

  /// Factory constructor for brick not found error
  factory MasonBrickException.brickNotFound(String brickName) {
    return MasonBrickException(
      'Brick "$brickName" not found',
      errorCode: MasonErrorCode.brickNotFound,
      brickName: brickName,
      code: 3001,
    );
  }

  /// Factory constructor for invalid brick configuration
  factory MasonBrickException.invalidBrickConfig(
    String brickName,
    String issue,
  ) {
    return MasonBrickException(
      'Invalid configuration in brick "$brickName": $issue',
      errorCode: MasonErrorCode.invalidBrickConfig,
      brickName: brickName,
      details: {'issue': issue},
      code: 3002,
    );
  }

  /// Factory constructor for brick generation failure
  factory MasonBrickException.generationFailed(String brickName, String error) {
    return MasonBrickException(
      'Failed to generate from brick "$brickName": $error',
      errorCode: MasonErrorCode.generationFailed,
      brickName: brickName,
      details: {'error': error},
      code: 3003,
    );
  }

  /// Factory constructor for brick installation failure
  factory MasonBrickException.installationFailed(
    String brickName,
    String error,
  ) {
    return MasonBrickException(
      'Failed to install brick "$brickName": $error',
      errorCode: MasonErrorCode.installationFailed,
      brickName: brickName,
      details: {'error': error},
      code: 3004,
    );
  }

  /// Factory constructor for cache error
  factory MasonBrickException.cacheError(String operation, String error) {
    return MasonBrickException(
      'Cache error during $operation: $error',
      errorCode: MasonErrorCode.cacheError,
      details: {'operation': operation, 'error': error},
      code: 3005,
    );
  }

  /// Factory constructor for dependency error
  factory MasonBrickException.dependencyError(
    String brickName,
    String dependency,
  ) {
    return MasonBrickException(
      'Dependency error in brick "$brickName": missing or invalid "$dependency"',
      errorCode: MasonErrorCode.dependencyError,
      brickName: brickName,
      details: {'dependency': dependency},
      code: 3006,
    );
  }

  /// Factory constructor for validation error
  factory MasonBrickException.validationError(
    String brickName,
    String validation,
  ) {
    return MasonBrickException(
      'Validation failed for brick "$brickName": $validation',
      errorCode: MasonErrorCode.validationError,
      brickName: brickName,
      details: {'validation': validation},
      code: 3007,
    );
  }

  /// Factory constructor for hook execution failure
  factory MasonBrickException.hookExecutionFailed(
    String brickName,
    String hook,
    String error,
  ) {
    return MasonBrickException(
      'Hook "$hook" failed in brick "$brickName": $error',
      errorCode: MasonErrorCode.hookExecutionFailed,
      brickName: brickName,
      details: {'hook': hook, 'error': error},
      code: 3008,
    );
  }

  /// Factory constructor for variable processing error
  factory MasonBrickException.variableProcessingError(
    String variable,
    String error,
  ) {
    return MasonBrickException(
      'Error processing variable "$variable": $error',
      errorCode: MasonErrorCode.variableProcessingError,
      details: {'variable': variable, 'error': error},
      code: 3009,
    );
  }

  /// Factory constructor for configuration error
  factory MasonBrickException.configurationError(String config, String issue) {
    return MasonBrickException(
      'Mason configuration error in $config: $issue',
      errorCode: MasonErrorCode.configurationError,
      details: {'config': config, 'issue': issue},
      code: 3010,
    );
  }

  /// Convert to user-friendly message
  @override
  String toUserMessage() {
    switch (errorCode) {
      case MasonErrorCode.brickNotFound:
        return 'The template "$brickName" was not found. Please check the template name and try again.';

      case MasonErrorCode.invalidBrickConfig:
        return 'The template "$brickName" has invalid configuration. Please contact the template maintainer.';

      case MasonErrorCode.generationFailed:
        return 'Failed to generate project from template "$brickName". Please try again or choose a different template.';

      case MasonErrorCode.installationFailed:
        return 'Failed to install template "$brickName". Please check your internet connection and try again.';

      case MasonErrorCode.cacheError:
        return 'Template cache error. Please clear the cache and try again.';

      case MasonErrorCode.dependencyError:
        return 'Template dependency error. The template "$brickName" is missing required dependencies.';

      case MasonErrorCode.hookExecutionFailed:
        final hook = details?['hook'] ?? 'unknown';
        return 'Template setup failed during $hook execution. Please try again.';

      default:
        return message;
    }
  }

  @override
  String toString() => 'MasonException: $message (Code: ${errorCode.name})';
}
