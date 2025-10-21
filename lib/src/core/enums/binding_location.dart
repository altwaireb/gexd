/// Binding locations supported by SolidX
enum BindingLocation {
  core(
    key: 'core',
    displayName: "Core",
    description: "Global application bindings in core folder.",
  ),
  shared(
    key: 'shared',
    displayName: "Shared",
    description: "Shared bindings in shared folder.",
  ),
  screen(
    key: 'screen',
    displayName: "Screen",
    description: "Screen-specific bindings in screen folder.",
  );

  const BindingLocation({
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

  /// Get a list of formatted strings for display in prompts
  static List<String> get toList =>
      values.map((e) => '${e.key} - ${e.description}').toList();

  /// Get help description for each location
  static Map<String, String> get allowedHelp {
    return {for (var t in values) t.key: t.description};
  }

  /// Create from string key
  static BindingLocation fromKey(String key) {
    return values.firstWhere(
      (location) => location.key == key,
      orElse: () => throw ArgumentError('Invalid binding location: $key'),
    );
  }

  /// Check if a given key is valid (case-sensitive)
  static bool isValidKey(String key) {
    return allKeys.contains(key);
  }
}
