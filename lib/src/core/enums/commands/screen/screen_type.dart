/// Defines the different types of screens that can be generated
/// Each type provides different controller patterns and starting points
enum ScreenType {
  /// Basic screen with minimal controller functionality
  basic(
    key: 'basic',
    displayName: 'Basic Screen',
    description: 'Simple screen setup.',
  ),

  /// Form screen with validation and form handling capabilities
  form(
    key: 'form',
    displayName: 'Form Screen',
    description: 'Form with validation.',
  ),

  /// Stateful screen with advanced state management
  withState(
    key: 'withState',
    displayName: 'Stateful Screen',
    description: 'Reactive data screen.',
  );

  const ScreenType({
    required this.key,
    required this.displayName,
    required this.description,
  });

  /// The key used for mason brick templates and CLI arguments
  final String key;

  /// Human-readable display name for UI
  final String displayName;

  /// Description of what this screen type provides
  final String description;

  @override
  String toString() => key;

  /// Get ScreenType from string key (case-sensitive)
  static ScreenType? fromKey(String key) {
    for (final type in ScreenType.values) {
      if (type.key == key) {
        return type;
      }
    }
    return null;
  }

  /// Get ScreenType from display name
  static ScreenType fromString(String name) {
    return values.firstWhere(
      (t) => t.displayName.toLowerCase() == name.toLowerCase(),
      orElse: () => throw ArgumentError("Unknown template: $name"),
    );
  }

  /// Get all available keys for CLI help
  static List<String> get allKeys =>
      ScreenType.values.map((e) => e.key).toList();

  /// Get all available display names for CLI help
  static List<String> get allDisplayNames =>
      ScreenType.values.map((e) => e.displayName).toList();

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
