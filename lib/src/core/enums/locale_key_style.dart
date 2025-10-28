/// Supported key styles for flattened JSON keys
enum LocaleKeyStyle {
  /// Dot notation: buttons.login.title
  dot(
    key: 'dot',
    displayName: 'Dot Notation',
    description: 'Keys separated by dots',
  ),

  /// Snake case: buttons_login_title
  snake(
    key: 'snake',
    displayName: 'Snake Case',
    description: 'Keys separated by underscores',
  ),

  /// Camel case: buttonsLoginTitle
  camelCase(
    key: 'camelCase',
    displayName: 'Camel Case',
    description: 'Keys in camelCase format',
  );

  const LocaleKeyStyle({
    required this.key,
    required this.displayName,
    required this.description,
  });

  /// The key used for CLI arguments and configuration
  final String key;

  /// Human-readable display name for UI
  final String displayName;

  /// Description of what this key style provides
  final String description;

  @override
  String toString() => key;

  /// Get LocaleKeyStyle from string key (case-sensitive)
  static LocaleKeyStyle? fromKey(String key) {
    for (final style in LocaleKeyStyle.values) {
      if (style.key == key) {
        return style;
      }
    }
    return null;
  }

  /// Get LocaleKeyStyle from display name
  static LocaleKeyStyle fromString(String name) {
    return values.firstWhere(
      (s) => s.displayName.toLowerCase() == name.toLowerCase(),
      orElse: () => throw ArgumentError("Unknown key style: $name"),
    );
  }

  /// Get all available keys for CLI help
  static List<String> get allKeys =>
      LocaleKeyStyle.values.map((e) => e.key).toList();

  /// Get all available display names for CLI help
  static List<String> get allDisplayNames =>
      LocaleKeyStyle.values.map((e) => e.displayName).toList();

  /// Check if a given key is valid (case-sensitive)
  static bool isValidKey(String key) {
    return allKeys.contains(key);
  }

  /// Automatically generate allowedHelp map for argParser
  static Map<String, String> get allowedHelp {
    return {for (var style in values) style.key: style.description};
  }

  /// Get a list of formatted strings for display in prompts
  static List<String> get toList =>
      values.map((e) => '${e.key} - ${e.description}').toList();
}
