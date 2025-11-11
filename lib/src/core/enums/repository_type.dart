/// Enumeration of different repository types
/// for repositories in Clean Architecture.
/// Each type defines its key, display name, and description.
/// Used in code generation for repository classes.
enum RepositoryType {
  /// Basic CRUD operations (getAll, getById, create, update, delete)
  crud(
    key: 'crud',
    displayName: 'CRUD Repository',
    description: 'Defines a contract with common CRUD operations.',
  ),

  /// Empty abstract repository (developer defines custom methods)
  empty(
    key: 'empty',
    displayName: 'Empty Repository',
    description:
        'Provides an empty repository ready for custom method definitions.',
  );

  final String key;
  final String displayName;
  final String description;

  const RepositoryType({
    required this.key,
    required this.displayName,
    required this.description,
  });

  /// Get ScreenType from string key (case-sensitive)
  static RepositoryType? fromKey(String key) {
    for (final type in RepositoryType.values) {
      if (type.key == key) {
        return type;
      }
    }
    return null;
  }

  /// Get RepositoryType from display name
  static RepositoryType fromString(String name) {
    return values.firstWhere(
      (t) => t.displayName.toLowerCase() == name.toLowerCase(),
      orElse: () => throw ArgumentError("Unknown template: $name"),
    );
  }

  /// Get all available keys for CLI help
  static List<String> get allKeys =>
      RepositoryType.values.map((e) => e.key).toList();

  /// Get all available display names for CLI help
  static List<String> get allDisplayNames =>
      RepositoryType.values.map((e) => e.displayName).toList();

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
