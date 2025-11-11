/// Widget locations supported by Gexd
enum WidgetLocation {
  shared(
    key: 'shared',
    displayName: "Shared",
    description: "Shared widgets in shared folder.",
  ),
  screen(
    key: 'screen',
    displayName: "Screen",
    description: "Screen-specific widgets in screen folder.",
  );

  const WidgetLocation({
    required this.key,
    required this.displayName,
    required this.description,
  });

  final String key;
  final String displayName;
  final String description;

  /// Get all allowed keys
  static List<String> get allKeys => values.map((e) => e.key).toList();

  static List<String> get allDisplayNames =>
      values.map((e) => e.displayName).toList();

  /// Get help description for each location
  static Map<String, String> get allowedHelp {
    return {for (var t in values) t.key: t.description};
  }

  /// Create from string key
  static WidgetLocation fromKey(String key) {
    return values.firstWhere(
      (location) => location.key == key,
      orElse: () => throw ArgumentError('Invalid widget location: $key'),
    );
  }

  /// Get a list of formatted strings for display in prompts
  static List<String> get toList =>
      values.map((e) => '${e.key} - ${e.description}').toList();

  /// Check if a given key is valid (case-sensitive)
  static bool isValidKey(String key) {
    return allKeys.contains(key.toLowerCase());
  }
}
