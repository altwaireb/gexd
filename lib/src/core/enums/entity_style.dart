/// Enumeration of different entity styles
/// for domain entities in Clean Architecture.
/// Each style defines its key, display name,
/// description, required dependencies, and dev dependencies.
enum EntityStyle {
  plain(
    key: 'plain',
    displayName: 'Plain Entity',
    description: 'Simple abstract entity classes for domain logic',
    requiresEquatable: true,
    dependencies: ['equatable'],
    devDependencies: [],
  ),
  immutable(
    key: 'immutable',
    displayName: 'Immutable Entity',
    description: 'Immutable entities with copyWith methods',
    requiresEquatable: true,
    dependencies: ['equatable'],
    devDependencies: [],
  ),
  freezed(
    key: 'freezed',
    displayName: 'Freezed Entity',
    description: 'Freezed-based immutable entities for complex domain logic',
    requiresEquatable: false,
    dependencies: ['freezed', 'json_annotation'],
    devDependencies: ['freezed', 'json_serializable', 'build_runner'],
  );

  final String key;
  final String displayName;
  final String description;
  final bool requiresEquatable;
  final List<String> dependencies;
  final List<String> devDependencies;

  const EntityStyle({
    required this.key,
    required this.displayName,
    required this.description,
    required this.requiresEquatable,
    required this.dependencies,
    required this.devDependencies,
  });

  /// Creates EntityStyle from key
  static EntityStyle fromKey(String key) {
    return values.firstWhere(
      (s) => s.key.toLowerCase() == key.toLowerCase(),
      orElse: () => throw ArgumentError('Unknown entity style: $key'),
    );
  }

  /// Returns all available style keys
  static List<String> get allKeys => values.map((e) => e.key).toList();

  /// Returns all display names for UI
  static List<String> get allDisplayNames =>
      values.map((e) => e.displayName).toList();

  /// Automatically generate allowedHelp map for argParser
  static Map<String, String> get allowedHelp {
    return {for (var s in values) s.key: s.description};
  }

  /// Returns required dependencies for this style
  List<String> get requiredDependencies => dependencies;

  /// Returns required dev dependencies for this style
  List<String> get requiredDevDependencies => devDependencies;

  /// Returns display list for UI selection
  static List<String> get toList =>
      values.map((e) => '${e.key} - ${e.description}').toList();
}
