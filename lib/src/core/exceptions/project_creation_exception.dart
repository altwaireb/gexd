import 'base_exception.dart';

/// Error codes for project creation failures
enum ProjectCreationErrorCode {
  /// Project directory already exists
  directoryExists,

  /// Permission denied to create directory
  permissionDenied,

  /// Insufficient disk space
  insufficientSpace,

  /// Invalid project path
  invalidPath,

  /// Template processing failed
  templateProcessingFailed,

  /// Dependency installation failed
  dependencyInstallationFailed,

  /// File system error
  fileSystemError,

  /// Configuration error
  configurationError,
}

/// Thrown when project creation fails.
class ProjectCreationException extends BaseException {
  final ProjectCreationErrorCode errorCode;
  final String? projectPath;
  final String? templateName;
  final Map<String, dynamic>? details;

  ProjectCreationException(
    super.message, {
    required this.errorCode,
    this.projectPath,
    this.templateName,
    this.details,
    super.code,
  });

  /// Factory constructor for directory already exists error
  factory ProjectCreationException.directoryExists(String projectPath) {
    return ProjectCreationException(
      'Project directory "$projectPath" already exists',
      errorCode: ProjectCreationErrorCode.directoryExists,
      projectPath: projectPath,
      code: 2001,
    );
  }

  /// Factory constructor for permission denied error
  factory ProjectCreationException.permissionDenied(String projectPath) {
    return ProjectCreationException(
      'Permission denied to create project at "$projectPath"',
      errorCode: ProjectCreationErrorCode.permissionDenied,
      projectPath: projectPath,
      code: 2002,
    );
  }

  /// Factory constructor for template processing error
  factory ProjectCreationException.templateProcessingFailed(
    String templateName,
    String reason,
  ) {
    return ProjectCreationException(
      'Failed to process template "$templateName": $reason',
      errorCode: ProjectCreationErrorCode.templateProcessingFailed,
      templateName: templateName,
      details: {'reason': reason},
      code: 2003,
    );
  }

  /// Factory constructor for dependency installation error
  factory ProjectCreationException.dependencyInstallationFailed(String error) {
    return ProjectCreationException(
      'Failed to install project dependencies: $error',
      errorCode: ProjectCreationErrorCode.dependencyInstallationFailed,
      details: {'error': error},
      code: 2004,
    );
  }

  /// Factory constructor for file system error
  factory ProjectCreationException.fileSystemError(
    String operation,
    String error,
  ) {
    return ProjectCreationException(
      'File system error during $operation: $error',
      errorCode: ProjectCreationErrorCode.fileSystemError,
      details: {'operation': operation, 'error': error},
      code: 2005,
    );
  }

  /// Factory constructor for configuration error
  factory ProjectCreationException.configurationError(
    String config,
    String issue,
  ) {
    return ProjectCreationException(
      'Configuration error in $config: $issue',
      errorCode: ProjectCreationErrorCode.configurationError,
      details: {'config': config, 'issue': issue},
      code: 2006,
    );
  }

  /// Factory constructor for insufficient disk space
  factory ProjectCreationException.insufficientSpace(String requiredSpace) {
    return ProjectCreationException(
      'Insufficient disk space. Required: $requiredSpace',
      errorCode: ProjectCreationErrorCode.insufficientSpace,
      details: {'requiredSpace': requiredSpace},
      code: 2007,
    );
  }

  /// Factory constructor for invalid project path
  factory ProjectCreationException.invalidPath(String path, String reason) {
    return ProjectCreationException(
      'Invalid project path "$path": $reason',
      errorCode: ProjectCreationErrorCode.invalidPath,
      projectPath: path,
      details: {'reason': reason},
      code: 2008,
    );
  }

  /// Convert to user-friendly message
  @override
  String toUserMessage() {
    switch (errorCode) {
      case ProjectCreationErrorCode.directoryExists:
        return 'A project with this name already exists at "$projectPath". Please choose a different name or location.';

      case ProjectCreationErrorCode.permissionDenied:
        return 'Permission denied. Please check your access rights for the target directory and try again.';

      case ProjectCreationErrorCode.insufficientSpace:
        final required = details?['requiredSpace'] ?? 'unknown';
        return 'Not enough disk space available. Please free up space (required: $required) and try again.';

      case ProjectCreationErrorCode.templateProcessingFailed:
        return 'There was an issue processing the project template. Please try again or choose a different template.';

      case ProjectCreationErrorCode.dependencyInstallationFailed:
        return 'Failed to install project dependencies. Please check your internet connection and try again.';

      default:
        return message;
    }
  }

  @override
  String toString() =>
      'ProjectCreationException: $message (Code: ${errorCode.name})';
}
