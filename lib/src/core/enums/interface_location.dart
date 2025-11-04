/// Interface locations supported by SolidX
enum InterfaceLocation {
  domain(
    key: 'domain',
    displayName: "Domain",
    description: "Domain interfaces in domain folder.",
  ),
  repositories(
    key: 'repositories',
    displayName: "Repositories",
    description: "Repository-specific interfaces in repositories folder.",
  ),
  datasources(
    key: 'datasources',
    displayName: "Datasources",
    description: "Datasource-specific interfaces in datasources folder.",
  );

  const InterfaceLocation({
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
  static InterfaceLocation fromKey(String key) {
    return values.firstWhere(
      (location) => location.key == key,
      orElse: () => throw ArgumentError('Invalid view location: $key'),
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
