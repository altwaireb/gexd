/// Enumeration of different model styles
/// Each style defines its key, display name,
/// description, required dependencies, and dev dependencies.
/// Used in code generation for model classes.
enum ModelStyle {
  plain(
    key: 'plain',
    displayName: 'Plain Dart model',
    description: 'Simple Dart classes without serialization annotations',
    requiresBuildRunner: false,
    dependencies: [],
    devDependencies: [],
  ),
  json(
    key: 'json',
    displayName: 'JSON serializable model',
    description: 'Models with json_annotation for JSON serialization',
    requiresBuildRunner: true,
    dependencies: ['json_annotation'],
    devDependencies: ['json_serializable', 'build_runner'],
  ),
  freezed(
    key: 'freezed',
    displayName: 'Freezed model',
    description: 'Immutable models with Freezed and JSON serialization',
    requiresBuildRunner: true,
    dependencies: ['freezed', 'json_annotation'],
    devDependencies: ['freezed', 'json_serializable', 'build_runner'],
  );

  final String key;
  final String displayName;
  final String description;
  final bool requiresBuildRunner;
  final List<String> dependencies;
  final List<String> devDependencies;

  const ModelStyle({
    required this.key,
    required this.displayName,
    required this.description,
    required this.requiresBuildRunner,
    required this.dependencies,
    required this.devDependencies,
  });

  /// Creates ModelStyle from key
  static ModelStyle fromKey(String key) {
    return values.firstWhere(
      (s) => s.key.toLowerCase() == key.toLowerCase(),
      orElse: () => throw ArgumentError('Unknown model style: $key'),
    );
  }

  /// Creates ModelStyle from string (legacy support)
  static ModelStyle fromString(String value) {
    return fromKey(value);
  }

  /// Returns all available style keys
  static List<String> get allKeys => values.map((e) => e.key).toList();

  /// Returns all display names for UI
  static List<String> get allDisplayNames =>
      values.map((e) => e.displayName).toList();

  /// Checks if a key is valid
  static bool isValidKey(String key) {
    return allKeys.contains(key.toLowerCase());
  }

  /// Automatically generate allowedHelp map for argParser
  static Map<String, String> get allowedHelp {
    return {for (var s in values) s.key: s.description};
  }

  /// Get a list of formatted strings for display in prompts
  static List<String> get toList =>
      values.map((e) => '${e.key} - ${e.description}').toList();

  /// Returns required dependencies for this style
  List<String> get requiredDependencies => dependencies;

  /// Returns required dev dependencies for this style
  List<String> get requiredDevDependencies => devDependencies;

  /// Returns whether this style needs any dependencies
  bool get needsDependencies =>
      requiredDependencies.isNotEmpty || requiredDevDependencies.isNotEmpty;
}
