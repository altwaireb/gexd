import 'package:mason_logger/mason_logger.dart';
import '../messages/message.dart';

/// Extension on Logger to provide convenient methods for Message objects
///
/// This extension allows using Message objects directly with Logger methods
/// without explicitly calling toString(), providing better type safety and
/// developer experience.
///
/// Example usage:
/// ```dart
/// logger.infoMessage(CommandMessages.retryPrompt);
/// logger.errMessage(ValidationMessages.empty, {'field': 'projectName'});
/// ```
extension LoggerMessageExtension on Logger {
  /// Log an info message using a Message object
  ///
  /// If [params] is provided, it will format the message with the parameters.
  /// Otherwise, it uses the message template as-is.
  void infoMessage(Message message, [Map<String, String>? params]) {
    info(params != null ? message.format(params) : message.toString());
  }

  /// Log an error message using a Message object
  ///
  /// If [params] is provided, it will format the message with the parameters.
  /// Otherwise, it uses the message template as-is.
  void errMessage(Message message, [Map<String, String>? params]) {
    err(params != null ? message.format(params) : message.toString());
  }

  /// Log a success message using a Message object
  ///
  /// If [params] is provided, it will format the message with the parameters.
  /// Otherwise, it uses the message template as-is.
  void successMessage(Message message, [Map<String, String>? params]) {
    success(params != null ? message.format(params) : message.toString());
  }

  /// Log a warning message using a Message object
  ///
  /// If [params] is provided, it will format the message with the parameters.
  /// Otherwise, it uses the message template as-is.
  void warnMessage(Message message, [Map<String, String>? params]) {
    warn(params != null ? message.format(params) : message.toString());
  }

  /// Log a detail message using a Message object
  ///
  /// If [params] is provided, it will format the message with the parameters.
  /// Otherwise, it uses the message template as-is.
  void detailMessage(Message message, [Map<String, String>? params]) {
    detail(params != null ? message.format(params) : message.toString());
  }

  /// Create a progress with a Message object
  ///
  /// If [params] is provided, it will format the message with the parameters.
  /// Otherwise, it uses the message template as-is.
  Progress progressMessage(Message message, [Map<String, String>? params]) {
    return progress(
      params != null ? message.format(params) : message.toString(),
    );
  }
}
