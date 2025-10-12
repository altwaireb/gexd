import 'message.dart';

/// Predefined validation error messages for consistent user feedback
///
/// This class contains all validation-related error messages used throughout
/// the application. Each message is a template that can be formatted with
/// specific parameters to provide context-aware error messages.
///
/// Example usage:
/// ```dart
/// final message = ValidationMessages.empty.format({'field': 'projectName'});
/// print(message); // "The projectName field is required and cannot be empty"
/// ```
class ValidationMessages {
  /// Message for empty field validation
  /// Parameters: {field}
  static const empty = Message(
    "The {field} field is required and cannot be empty",
  );

  /// Message for minimum length validation
  /// Parameters: {field}, {minLength}
  static const tooShort = Message(
    "The {field} must be at least {minLength} characters long",
  );

  /// Message for maximum length validation
  /// Parameters: {field}, {maxLength}
  static const tooLong = Message(
    "The {field} cannot exceed {maxLength} characters",
  );

  /// Message for format validation
  /// Parameters: {field}, {expectedFormat} (optional suffix)
  static const invalidFormat = Message(
    "The {field} has an invalid format{expectedFormat}",
  );

  /// Message for invalid option validation
  /// Parameters: {field}, {value}, {validOptions}
  static const invalidOption = Message(
    "Invalid {field} \"{value}\". Valid options are: {validOptions}",
  );

  /// Message for not found validation
  /// Parameters: {item}, {identifier} (optional suffix)
  static const notFound = Message("{item} not found{identifier}");

  /// Message for duplicate validation
  /// Parameters: {field}, {value}
  static const duplicate = Message("The {field} \"{value}\" already exists");

  /// Message for directory not found validation
  /// Parameters: {path}
  static const directoryNotFound = Message("Directory not found: {path}");

  /// Message for invalid Flutter project validation
  /// Parameters: {path}
  static const notFlutterProject = Message(
    "The directory \"{path}\" is not a valid Flutter project",
  );

  /// Message for invalid ASCII characters
  /// Parameters: {field}
  static const invalidAscii = Message(
    "The {field} contains non-ASCII characters",
  );

  /// Message for out of range validation
  /// Parameters: {field}, {value}, {min}, {max}
  static const outOfRange = Message(
    "The {field} value \"{value}\" is out of range ({min} - {max})",
  );

  /// Message for missing dependency validation
  /// Parameters: {dependency}
  static const missingDependency = Message(
    "Required dependency \"{dependency}\" is missing",
  );

  /// Flutter project validation success message
  static const flutterProjectValidated = Message(
    "✅ Flutter project structure validated successfully",
  );
}
