import 'dart:io';

import 'package:gexd/gexd.dart';

/// Field validator utility class that provides comprehensive validation methods
/// with consistent error handling and user-friendly messages.
class FieldValidator {
  final String field;
  final String example;
  final String? defaultValue;

  FieldValidator(this.field, {required this.example, this.defaultValue});

  // Regex constants for various format validations
  static final _snake = RegExp(r'^[a-z0-9]+(_[a-z0-9]+)*$');
  static final _camel = RegExp(r'^[a-z][a-zA-Z0-9]*$');
  static final _pascal = RegExp(r'^[A-Z][a-zA-Z0-9]*$');
  static final _kebab = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');
  static final _path = RegExp(r'^[a-z0-9]+(/[a-z0-9]+)*$');
  static final _constant = RegExp(r'^[A-Z0-9]+(_[A-Z0-9]+)*$');
  static final _dot = RegExp(r'^[a-z0-9]+(\.[a-z0-9]+)*$');
  static final _lower = RegExp(r'^[a-z0-9]+$');
  static final _upper = RegExp(r'^[A-Z0-9 ]+$');
  static final _ascii = RegExp(r'^[\x00-\x7F]+$');
  static final _startAlpha = RegExp(r'^[a-zA-Z]');

  // Reserved suffixes that should not be used in names
  static const List<String> _reservedSuffixes = [
    // Flutter/GetX specific
    'view',
    'binding',
    'screen',
    'controller',
    'provider',
    'page',
    'widget',
    'component',
    'service',
    'repository',
    'model',
    'entity',
    'state',
    'event',
    'data',
    'interface',

    // General programming suffixes
    'manager',
    'helper',
    'util',
    'utils',

    // Dart/OOP reserved patterns
    'impl',
    'interface',
  ];

  // Helper methods for common checks
  bool isEmpty(String value) => value.trim().isEmpty;
  bool isMinLength(String value, int min) => value.length >= min;
  bool isMaxLength(String value, int max) => value.length <= max;
  bool isMatch(String value, RegExp pattern) => pattern.hasMatch(value);

  /// Validates that the field is not empty
  void notEmpty(String value, [bool toUserMessage = false]) {
    if (isEmpty(value)) {
      if (toUserMessage) {
        throw ValidationException.empty(field).toUserMessage();
      } else {
        throw ValidationException.empty(field);
      }
    }
  }

  /// Validates minimum length requirement
  void minLength(String value, int min, [bool toUserMessage = false]) {
    if (!isMinLength(value, min)) {
      if (toUserMessage) {
        throw ValidationException.tooShort(field, value, min).toUserMessage();
      } else {
        throw ValidationException.tooShort(field, value, min);
      }
    }
  }

  /// Validates maximum length requirement
  void maxLength(String value, int max, [bool toUserMessage = false]) {
    if (!isMaxLength(value, max)) {
      if (toUserMessage) {
        throw ValidationException.tooLong(field, value, max).toUserMessage();
      } else {
        throw ValidationException.tooLong(field, value, max);
      }
    }
  }

  /// Validates that value contains only ASCII characters
  void asciiOnly(String value, [bool toUserMessage = false]) {
    if (!isMatch(value, _ascii)) {
      if (toUserMessage) {
        throw ValidationException(
          'The $field must contain only ASCII characters',
          code: ValidationErrorCode.invalidAscii,
          field: field,
          value: value,
        ).toUserMessage();
      } else {
        throw ValidationException(
          'The $field must contain only ASCII characters',
          code: ValidationErrorCode.invalidAscii,
          field: field,
          value: value,
        );
      }
    }
  }

  /// Validates that value starts with an alphabetic character (a-z, A-Z)
  /// This is useful for ensuring compliance with naming conventions like Dart packages
  void startAlpha(String value, [bool toUserMessage = false]) {
    if (!isMatch(value, _startAlpha)) {
      if (toUserMessage) {
        throw ValidationException(
          'The $field must start with an alphabetic character (a-z, A-Z)',
          code: ValidationErrorCode.invalidFormat,
          field: field,
          value: value,
        ).toUserMessage();
      } else {
        throw ValidationException(
          'The $field must start with an alphabetic character (a-z, A-Z)',
          code: ValidationErrorCode.invalidFormat,
          field: field,
          value: value,
        );
      }
    }
  }

  /// Validates that value doesn't end with reserved suffixes
  /// This prevents naming conflicts and ensures consistent code generation
  void validSuffix(
    String value, [
    String? example = 'User',
    bool toUserMessage = false,
  ]) {
    final name = value.trim().toLowerCase();

    for (final suffix in _reservedSuffixes) {
      if (name.endsWith(suffix)) {
        if (toUserMessage) {
          throw ValidationException(
            'The $field should not end with "$suffix". '
            'Use base name only (e.g., "$example" instead of "$example${suffix.toCapitalized}")',
            code: ValidationErrorCode.invalidFormat,
            field: field,
            value: value,
          ).toUserMessage();
        } else {
          throw ValidationException(
            'The $field should not end with "$suffix". '
            'Use base name only (e.g., "$example" instead of "$example${suffix.toCapitalized}")',
            code: ValidationErrorCode.invalidFormat,
            field: field,
            value: value,
          );
        }
      }
    }
  }

  /// Validates snake_case format (allows numbers at start)
  void snakeCase(
    String value, [
    String? example = 'my_project',
    bool toUserMessage = false,
  ]) => _validate(value, _snake, 'snake_case (e.g., $example)', toUserMessage);

  /// Validates camelCase format
  void camelCase(
    String value, [
    String? example = 'myProject',
    bool toUserMessage = false,
  ]) => _validate(value, _camel, 'camelCase (e.g., $example)', toUserMessage);

  /// Validates PascalCase format
  void pascalCase(
    String value, [
    String? example = 'MyProject',
    bool toUserMessage = false,
  ]) => _validate(value, _pascal, 'PascalCase (e.g., $example)', toUserMessage);

  /// Validates kebab-case format
  void kebabCase(
    String value, [
    String? example = 'my-project',
    bool toUserMessage = false,
  ]) => _validate(value, _kebab, 'kebab-case (e.g., $example)', toUserMessage);

  /// Validates path/case format
  void pathCase(
    String value, [
    String? example = 'my/project',
    bool toUserMessage = false,
  ]) => _validate(value, _path, 'path/case (e.g., $example)', toUserMessage);

  /// Validates path with maximum depth limit (for --on option)
  /// Supports 1-3 levels: auth, auth/user, auth/user/registration
  void pathCaseWithDepth(
    String value, {
    int maxDepth = 3,
    String? example,
    bool toUserMessage = false,
  }) {
    // Check basic path format first
    if (!isMatch(value, _path)) {
      if (toUserMessage) {
        throw ValidationException.invalidFormat(
          field,
          value,
          expectedFormat:
              'path/case with max $maxDepth levels (e.g., ${example ?? 'auth/user/registration'})',
        ).toUserMessage();
      } else {
        throw ValidationException.invalidFormat(
          field,
          value,
          expectedFormat:
              'path/case with max $maxDepth levels (e.g., ${example ?? 'auth/user/registration'})',
        );
      }
    }

    // Check depth limit
    final parts = value.split('/');
    if (parts.length > maxDepth) {
      final exception = ValidationException.pathTooDeep(value, maxDepth);
      if (toUserMessage) {
        throw exception.toUserMessage();
      } else {
        throw exception;
      }
    }

    // Validate each part individually
    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      if (part.isEmpty) {
        final exception = ValidationException.invalidPath(
          value,
          'Path contains empty segments. Each level must have a valid name.',
        );
        if (toUserMessage) {
          throw exception.toUserMessage();
        } else {
          throw exception;
        }
      }

      // Each part should follow snake_case or lowercase
      if (!RegExp(r'^[a-z0-9]+(_[a-z0-9]+)*$').hasMatch(part)) {
        final exception = ValidationException.invalidPath(
          value,
          'Path segment "$part" must be in snake_case format. Use lowercase letters, numbers, and underscores only.',
        );
        if (toUserMessage) {
          throw exception.toUserMessage();
        } else {
          throw exception;
        }
      }
    }
  }

  /// Validates CONSTANT_CASE format
  void constantCase(
    String value, [
    String? example = 'MY_PROJECT',
    bool toUserMessage = false,
  ]) => _validate(
    value,
    _constant,
    'CONSTANT_CASE (e.g., $example)',
    toUserMessage,
  );

  /// Validates dot.case format
  void dotCase(
    String value, [
    String? example = 'my.project',
    bool toUserMessage = false,
  ]) => _validate(value, _dot, 'dot.case (e.g., $example)', toUserMessage);

  /// Validates lowercase only format
  void lowerCaseOnly(
    String value, [
    String? example = 'myproject',
    bool toUserMessage = false,
  ]) => _validate(
    value,
    _lower,
    'lowercase only (e.g., $example)',
    toUserMessage,
  );

  /// Validates UPPERCASE only format
  void upperCaseOnly(
    String value, [
    String? example = 'MY PROJECT',
    bool toUserMessage = false,
  ]) => _validate(
    value,
    _upper,
    'UPPERCASE only (e.g., $example)',
    toUserMessage,
  );

  /// Generic validation method for pattern matching
  void _validate(
    String value,
    RegExp pattern,
    String expectedFormat, [
    bool toUserMessage = false,
  ]) {
    if (!isMatch(value, pattern)) {
      if (toUserMessage) {
        throw ValidationException.invalidFormat(
          field,
          value,
          expectedFormat: expectedFormat,
        ).toUserMessage();
      } else {
        throw ValidationException.invalidFormat(
          field,
          value,
          expectedFormat: expectedFormat,
        );
      }
    }
  }

  /// Validates that value is one of the allowed options
  void oneOf(
    String value,
    List<String> allowedValues, {
    bool toUserMessage = false,
  }) {
    if (!allowedValues.contains(value)) {
      if (toUserMessage) {
        throw ValidationException.invalidOption(
          field,
          value,
          allowedValues,
        ).toUserMessage();
      } else {
        throw ValidationException.invalidOption(field, value, allowedValues);
      }
    }
  }

  /// Validates length range (both min and max)
  void lengthRange(
    String value,
    int min,
    int max, {
    bool toUserMessage = false,
  }) {
    if (value.length < min) {
      if (toUserMessage) {
        throw ValidationException.tooShort(field, value, min).toUserMessage();
      } else {
        throw ValidationException.tooShort(field, value, min);
      }
    }
    if (value.length > max) {
      if (toUserMessage) {
        throw ValidationException.tooLong(field, value, max).toUserMessage();
      } else {
        throw ValidationException.tooLong(field, value, max);
      }
    }
  }

  /// Validates field name for model fields
  /// Checks: not empty, camelCase format, valid suffix, and no duplicates
  void modelFieldName(
    String value, {
    Set<String>? existingFields,
    bool toUserMessage = false,
  }) {
    // Basic validation
    notEmpty(value, toUserMessage);

    // Format validation (camelCase for field names)
    camelCase(value, 'userId', toUserMessage);

    // Check for valid suffix (no reserved words)
    validSuffix(value, 'user', toUserMessage);

    // Check for duplicates if existingFields provided
    if (existingFields != null && existingFields.contains(value)) {
      if (toUserMessage) {
        throw ValidationException(
          'Field "$value" already exists. Choose a different name.',
          code: ValidationErrorCode.duplicate,
          field: field,
          value: value,
        ).toUserMessage();
      } else {
        throw ValidationException(
          'Field "$value" already exists. Choose a different name.',
          code: ValidationErrorCode.duplicate,
          field: field,
          value: value,
        );
      }
    }
  }

  /// Creates a user-friendly validation message with examples
  String get helpMessage {
    final buffer = StringBuffer('Field: $field\n');
    buffer.write('Example: "$example"\n');
    if (defaultValue != null) {
      buffer.write('Default: "$defaultValue"\n');
    }
    return buffer.toString();
  }

  // === FILE VALIDATION METHODS ===

  /// Validates that a file exists and is accessible
  void fileExists(String filePath, {bool toUserMessage = false}) {
    if (isEmpty(filePath)) {
      if (toUserMessage) {
        throw ValidationException.empty(field).toUserMessage();
      } else {
        throw ValidationException.empty(field);
      }
    }

    final file = File(filePath);
    if (!file.existsSync()) {
      final exception = ValidationException.fileNotFound(filePath);
      if (toUserMessage) {
        throw exception.toUserMessage();
      } else {
        throw exception;
      }
    }
  }

  /// Validates that a file has .json extension
  void jsonFile(String filePath, {bool toUserMessage = false}) {
    if (!filePath.toLowerCase().endsWith('.json')) {
      if (toUserMessage) {
        throw ValidationException(
          'File must have .json extension',
          code: ValidationErrorCode.invalidFormat,
          field: field,
          value: filePath,
        ).toUserMessage();
      } else {
        throw ValidationException(
          'File must have .json extension',
          code: ValidationErrorCode.invalidFormat,
          field: field,
          value: filePath,
        );
      }
    }
  }

  /// Validates that a file path is safe (no directory traversal)
  void safeFilePath(String filePath, {bool toUserMessage = false}) {
    if (filePath.contains('..') ||
        filePath.contains('~') ||
        filePath.startsWith('/etc/') ||
        filePath.startsWith('/usr/') ||
        filePath.startsWith('/System/')) {
      if (toUserMessage) {
        throw ValidationException(
          'File path is not allowed for security reasons',
          code: ValidationErrorCode.invalidFormat,
          field: field,
          value: filePath,
        ).toUserMessage();
      } else {
        throw ValidationException(
          'File path is not allowed for security reasons',
          code: ValidationErrorCode.invalidFormat,
          field: field,
          value: filePath,
        );
      }
    }
  }

  /// Validates file size (max 10MB by default)
  void fileSize(
    String filePath, {
    int maxSizeBytes = 10 * 1024 * 1024,
    bool toUserMessage = false,
  }) {
    final file = File(filePath);
    final size = file.lengthSync();

    if (size > maxSizeBytes) {
      final sizeMB = (size / (1024 * 1024)).toStringAsFixed(1);
      final maxMB = (maxSizeBytes / (1024 * 1024)).toStringAsFixed(1);
      if (toUserMessage) {
        throw ValidationException(
          'File too large ($sizeMB MB). Maximum allowed size is $maxMB MB',
          code: ValidationErrorCode.invalidFormat,
          field: field,
          value: filePath,
        ).toUserMessage();
      } else {
        throw ValidationException(
          'File too large ($sizeMB MB). Maximum allowed size is $maxMB MB',
          code: ValidationErrorCode.invalidFormat,
          field: field,
          value: filePath,
        );
      }
    }
  }

  // === URL VALIDATION METHODS ===

  /// Validates basic URL format
  void validUrl(String url, {bool toUserMessage = false}) {
    if (isEmpty(url)) {
      if (toUserMessage) {
        throw ValidationException.empty(field).toUserMessage();
      } else {
        throw ValidationException.empty(field);
      }
    }

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      if (toUserMessage) {
        throw ValidationException(
          'Invalid URL format',
          code: ValidationErrorCode.invalidFormat,
          field: field,
          value: url,
        ).toUserMessage();
      } else {
        throw ValidationException(
          'Invalid URL format',
          code: ValidationErrorCode.invalidFormat,
          field: field,
          value: url,
        );
      }
    }
  }

  /// Validates that URL uses HTTP or HTTPS protocol
  void httpUrl(String url, {bool toUserMessage = false}) {
    validUrl(url, toUserMessage: toUserMessage); // First check basic format

    final uri = Uri.parse(url);
    if (!['http', 'https'].contains(uri.scheme.toLowerCase())) {
      if (toUserMessage) {
        throw ValidationException(
          'URL must use HTTP or HTTPS protocol',
          code: ValidationErrorCode.invalidFormat,
          field: field,
          value: url,
        ).toUserMessage();
      } else {
        throw ValidationException(
          'URL must use HTTP or HTTPS protocol',
          code: ValidationErrorCode.invalidFormat,
          field: field,
          value: url,
        );
      }
    }
  }

  /// Validates that URL is not localhost or private IP (security)
  void publicUrl(String url, {bool toUserMessage = false}) {
    httpUrl(url, toUserMessage: toUserMessage); // First check HTTP format

    final uri = Uri.parse(url);
    final host = uri.host.toLowerCase();

    // Block localhost
    if (host == 'localhost' || host == '127.0.0.1' || host == '::1') {
      if (toUserMessage) {
        throw ValidationException(
          'Access to localhost is not allowed',
          code: ValidationErrorCode.invalidFormat,
          field: field,
          value: url,
        ).toUserMessage();
      } else {
        throw ValidationException(
          'Access to localhost is not allowed',
          code: ValidationErrorCode.invalidFormat,
          field: field,
          value: url,
        );
      }
    }

    // Block private IP ranges
    if (_isPrivateIP(host)) {
      if (toUserMessage) {
        throw ValidationException(
          'Access to private IP addresses is not allowed',
          code: ValidationErrorCode.invalidFormat,
          field: field,
          value: url,
        ).toUserMessage();
      } else {
        throw ValidationException(
          'Access to private IP addresses is not allowed',
          code: ValidationErrorCode.invalidFormat,
          field: field,
          value: url,
        );
      }
    }
  }

  /// Helper method to check if an IP is in private ranges
  bool _isPrivateIP(String host) {
    try {
      final addr = InternetAddress(host);
      final bytes = addr.rawAddress;

      if (addr.type == InternetAddressType.IPv4) {
        // 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 169.254.0.0/16
        if (bytes[0] == 10) return true;
        if (bytes[0] == 172 && bytes[1] >= 16 && bytes[1] <= 31) return true;
        if (bytes[0] == 192 && bytes[1] == 168) return true;
        if (bytes[0] == 169 && bytes[1] == 254) return true;
      } else if (addr.type == InternetAddressType.IPv6) {
        // fc00::/7 (unique local), fe80::/10 (link-local)
        if ((bytes[0] & 0xfe) == 0xfc) return true;
        if (bytes[0] == 0xfe && (bytes[1] & 0xc0) == 0x80) return true;
      }
      return false;
    } catch (e) {
      return false; // Not a valid IP, could be hostname
    }
  }

  // === PROJECT STRUCTURE VALIDATION METHODS ===

  /// Validates that a screen path exists in the project structure
  /// Uses ArchitectureCoordinator to detect the correct screen path based on project template
  Future<void> existingScreenPath(
    String screenName, {
    ProjectTemplate? template,
    String projectRoot = '.',
    bool toUserMessage = false,
  }) async {
    // Basic validation first
    notEmpty(screenName, toUserMessage);

    // Get template if not provided
    template ??= await ArchitectureCoordinator.getCurrentProjectTemplate();

    if (template == null) {
      final exception = ConfigProjectException.unknownTemplate(screenName);
      if (toUserMessage) {
        throw exception.toUserMessage();
      } else {
        throw exception;
      }
    }

    // Get the screen base path from ArchitectureCoordinator
    final screenBasePath = ArchitectureCoordinator.getComponentPath(
      NameComponent.screen,
      template,
    );

    if (screenBasePath.isEmpty) {
      if (toUserMessage) {
        throw ValidationException(
          'Screen component is not supported in ${template.name} template.',
          code: ValidationErrorCode.invalidFormat,
          field: field,
          value: screenName,
        ).toUserMessage();
      } else {
        throw ValidationException(
          'Screen component is not supported in ${template.name} template.',
          code: ValidationErrorCode.invalidFormat,
          field: field,
          value: screenName,
        );
      }
    }

    // Convert to snake_case for path checking
    final snakeCaseName = screenName
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match.group(0)!}')
        .toLowerCase()
        .replaceFirst(RegExp(r'^_'), '');

    // Check if screen directory exists using the template-specific path
    final screenPath = '$projectRoot/$screenBasePath/$snakeCaseName';
    final screenDir = Directory(screenPath);

    if (!screenDir.existsSync()) {
      if (toUserMessage) {
        throw ValidationException(
          'Screen "$screenName" does not exist in project structure.\n'
          'Expected path: $screenBasePath/$snakeCaseName/\n'
          'Create the screen first using: gexd make screen $screenName',
          code: ValidationErrorCode.notFound,
          field: field,
          value: screenName,
        ).toUserMessage();
      } else {
        throw ValidationException(
          'Screen "$screenName" does not exist in project structure.\n'
          'Expected path: $screenBasePath/$snakeCaseName/\n'
          'Create the screen first using: gexd make screen $screenName',
          code: ValidationErrorCode.notFound,
          field: field,
          value: screenName,
        );
      }
    }

    // Get controllers path from ArchitectureCoordinator
    final controllersBasePath = ArchitectureCoordinator.getComponentPath(
      NameComponent.screenControllers,
      template,
    );

    // Check if it's a screen-specific controller path (contains screen placeholder)
    if (controllersBasePath.contains('{screen}')) {
      final controllersPath = controllersBasePath.replaceAll(
        '{screen}',
        snakeCaseName,
      );
      final fullControllersPath = '$projectRoot/$controllersPath';
      final controllersDir = Directory(fullControllersPath);

      if (!controllersDir.existsSync()) {
        if (toUserMessage) {
          throw ValidationException(
            'Screen "$screenName" exists but controllers directory is missing.\n'
            'Expected path: $controllersPath/\n'
            'This screen structure appears to be incomplete.',
            code: ValidationErrorCode.invalidFormat,
            field: field,
            value: screenName,
          ).toUserMessage();
        } else {
          throw ValidationException(
            'Screen "$screenName" exists but controllers directory is missing.\n'
            'Expected path: $controllersPath/\n'
            'This screen structure appears to be incomplete.',
            code: ValidationErrorCode.invalidFormat,
            field: field,
            value: screenName,
          );
        }
      }
    }
  }

  /// Validates that a controller doesn't already exist for the given name and location
  void controllerNotExists(
    String controllerName, {
    String location = 'shared',
    String? screenName,
    String projectRoot = '.',
    bool toUserMessage = false,
  }) {
    // Basic validation
    notEmpty(controllerName, toUserMessage);

    // Convert to snake_case for file checking
    final snakeCaseName = controllerName
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match.group(0)!}')
        .toLowerCase()
        .replaceFirst(RegExp(r'^_'), '');

    String controllerPath;

    if (location == 'shared') {
      controllerPath =
          '$projectRoot/lib/app/shared/controllers/${snakeCaseName}_controller.dart';
    } else if (location == 'screen' && screenName != null) {
      final screenSnakeCase = screenName
          .replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match.group(0)!}')
          .toLowerCase()
          .replaceFirst(RegExp(r'^_'), '');
      controllerPath =
          '$projectRoot/lib/app/modules/$screenSnakeCase/controllers/${snakeCaseName}_controller.dart';
    } else {
      if (toUserMessage) {
        throw ValidationException(
          'Invalid location or missing screen name for screen controller',
          code: ValidationErrorCode.invalidFormat,
          field: field,
          value: controllerName,
        ).toUserMessage();
      } else {
        throw ValidationException(
          'Invalid location or missing screen name for screen controller',
          code: ValidationErrorCode.invalidFormat,
          field: field,
          value: controllerName,
        );
      }
    }

    final controllerFile = File(controllerPath);

    if (controllerFile.existsSync()) {
      if (toUserMessage) {
        throw ValidationException(
          'Controller "$controllerName" already exists at:\n'
          '$controllerPath\n'
          'Use --force to overwrite or choose a different name.',
          code: ValidationErrorCode.duplicate,
          field: field,
          value: controllerName,
        ).toUserMessage();
      } else {
        throw ValidationException(
          'Controller "$controllerName" already exists at:\n'
          '$controllerPath\n'
          'Use --force to overwrite or choose a different name.',
          code: ValidationErrorCode.duplicate,
          field: field,
          value: controllerName,
        );
      }
    }
  }

  /// Validates project structure exists (checks for Gexd project)
  void validProjectStructure({
    String projectRoot = '.',
    bool toUserMessage = false,
  }) {
    // Check for main Gexd indicators
    final configFile = File('$projectRoot/.gexd/config.yaml');
    final libDir = Directory('$projectRoot/lib');
    final appDir = Directory('$projectRoot/lib/app');

    if (!configFile.existsSync()) {
      if (toUserMessage) {
        throw ValidationException(
          'Not in a Gexd project directory.\n'
          'Missing .gexd/config.yaml file.\n'
          'Initialize with: gexd init or create new project with: gexd create <project_name>',
          code: ValidationErrorCode.notFound,
          field: 'project',
          value: projectRoot,
        ).toUserMessage();
      } else {
        throw ValidationException(
          'Not in a Gexd project directory.\n'
          'Missing .gexd/config.yaml file.\n'
          'Initialize with: gexd init or create new project with: gexd create <project_name>',
          code: ValidationErrorCode.notFound,
          field: 'project',
          value: projectRoot,
        );
      }
    }

    if (!libDir.existsSync() || !appDir.existsSync()) {
      if (toUserMessage) {
        throw ValidationException(
          'Invalid project structure.\n'
          'Missing lib/app directory structure.\n'
          'This appears to be an incomplete Gexd project.',
          code: ValidationErrorCode.invalidFormat,
          field: 'project',
          value: projectRoot,
        ).toUserMessage();
      } else {
        throw ValidationException(
          'Invalid project structure.\n'
          'Missing lib/app directory structure.\n'
          'This appears to be an incomplete Gexd project.',
          code: ValidationErrorCode.invalidFormat,
          field: 'project',
          value: projectRoot,
        );
      }
    }
  }
}

extension StringCasingExtension on String {
  String get toCapitalized => length > 0 ? StringHelpers.capitalize(this) : '';
  String get toTitleCase => StringHelpers.toTitleCase(this);
}
