/// {{name.pascalCase()}} Exception
///
/// A custom exception for {{name.camelCase()}}-related errors.
///
/// Example:
/// ```dart
/// throw {{name.pascalCase()}}Exception('Invalid {{name.camelCase()}} data');
/// ```
class {{name.pascalCase()}}Exception implements Exception {
  /// Error message describing what went wrong.
  final String message;

  /// Optional error code for identifying the specific failure type.
  final String? code;

  const {{name.pascalCase()}}Exception(this.message, {this.code});

  @override
  String toString() {
    final codePart = code != null ? ' (code: $code)' : '';
    return '{{name.pascalCase()}}Exception$message$codePart';
  }
}
