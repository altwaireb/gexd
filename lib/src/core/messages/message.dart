/// Base message class for template-based string formatting
///
/// This class provides a simple and efficient way to create reusable
/// message templates with parameter substitution.
///
/// Example:
/// ```dart
/// const greeting = Message("Hello {name}, welcome to {app}!");
/// print(greeting.format({'name': 'John', 'app': 'Gexd'}));
/// // Output: Hello John, welcome to Gexd!
///
/// // Or use directly without parameters:
/// const simple = Message("Hello World!");
/// print(simple); // Output: Hello World!
/// ```
class Message {
  /// The message template with placeholders in {key} format
  final String template;

  /// Creates a new message with the given template
  const Message(this.template);

  /// Formats the message by replacing placeholders with provided parameters
  /// If [params] is empty, it returns the template as-is
  String format([Map<String, String> params = const {}]) {
    if (params.isEmpty) return template;
    var result = template;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }

  /// Override call operator to allow using Message(...)({...}) syntax
  String call([Map<String, String> params = const {}]) => format(params);

  @override
  String toString() => template;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          runtimeType == other.runtimeType &&
          template == other.template;

  @override
  int get hashCode => template.hashCode;
}
