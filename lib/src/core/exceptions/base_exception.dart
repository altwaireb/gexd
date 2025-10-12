/// Base class for all Gexd exceptions.
///
/// Provides a common interface for handling errors throughout the application
/// with optional error codes for categorization and debugging.
abstract class BaseException implements Exception {
  /// The error message describing what went wrong
  final String message;

  /// Optional error code for categorization and debugging
  final int? code;

  /// Creates a new base exception with the given message and optional code
  BaseException(this.message, {this.code});

  /// String representation of the exception
  @override
  String toString() => message;

  /// Convert exception to user-friendly message
  ///
  /// Override this method in subclasses to provide context-specific
  /// user-friendly error messages.
  String toUserMessage() => message;
}
