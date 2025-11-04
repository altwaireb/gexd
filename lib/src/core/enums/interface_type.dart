enum InterfaceType {
  /// Basic CRUD operations (getAll, getById, create, update, delete)
  crud(
    key: 'crud',
    displayName: 'CRUD Interface',
    description: 'Defines a contract with common CRUD operations.',
  ),

  /// Empty abstract interface (developer defines custom methods)
  empty(
    key: 'empty',
    displayName: 'Empty Interface',
    description:
        'Provides an empty interface ready for custom method definitions.',
  );

  final String key;
  final String displayName;
  final String description;

  const InterfaceType({
    required this.key,
    required this.displayName,
    required this.description,
  });

  /// Get ScreenType from string key (case-sensitive)
  static InterfaceType? fromKey(String key) {
    for (final type in InterfaceType.values) {
      if (type.key == key) {
        return type;
      }
    }
    return null;
  }

  /// Get InterfaceType from display name
  static InterfaceType fromString(String name) {
    return values.firstWhere(
      (t) => t.displayName.toLowerCase() == name.toLowerCase(),
      orElse: () => throw ArgumentError("Unknown template: $name"),
    );
  }

  /// Get all available keys for CLI help
  static List<String> get allKeys =>
      InterfaceType.values.map((e) => e.key).toList();

  /// Get all available display names for CLI help
  static List<String> get allDisplayNames =>
      InterfaceType.values.map((e) => e.displayName).toList();

  /// Get a list of formatted strings for display in prompts
  static List<String> get toList =>
      values.map((e) => '${e.key} - ${e.description}').toList();

  /// Check if a given key is valid (case-sensitive)
  static bool isValidKey(String key) {
    return allKeys.contains(key);
  }

  /// Automatically generate allowedHelp map for argParser
  static Map<String, String> get allowedHelp {
    return {for (var t in values) t.key: t.description};
  }
}
