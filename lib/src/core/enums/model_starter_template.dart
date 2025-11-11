/// Enumeration of model starter templates
/// Each template includes key, display name,
/// description, field count, and JSON content.
enum ModelStarterTemplate {
  basic(
    key: 'basic',
    displayName: 'Basic fields (id, name, createdAt)',
    description: 'Simple model with essential fields for most use cases',
    fieldCount: 3,
    json: '''
{
  "id": 1,
  "name": "Example Name",
  "createdAt": "2024-01-01T00:00:00.000Z"
}''',
  ),
  custom(
    key: 'custom',
    displayName: 'Custom interactive builder',
    description: 'Build your own model interactively with custom fields',
    fieldCount: 0,
    json: '',
  );

  final String key;
  final String displayName;
  final String description;
  final int fieldCount;
  final String json;

  const ModelStarterTemplate({
    required this.key,
    required this.displayName,
    required this.description,
    required this.fieldCount,
    required this.json,
  });

  /// Creates ModelStarterTemplate from key
  static ModelStarterTemplate fromKey(String key) {
    return values.firstWhere(
      (t) => t.key.toLowerCase() == key.toLowerCase(),
      orElse: () => throw ArgumentError('Unknown template: $key'),
    );
  }

  /// Creates ModelStarterTemplate from string (legacy support)
  static ModelStarterTemplate fromString(String name) {
    // Try by key first, then by display name
    try {
      return fromKey(name);
    } catch (_) {
      return values.firstWhere(
        (t) => t.displayName.toLowerCase() == name.toLowerCase(),
        orElse: () => throw ArgumentError('Unknown template: $name'),
      );
    }
  }

  /// Returns all available template keys
  static List<String> get allKeys => values.map((e) => e.key).toList();

  /// Returns all display names for UI
  static List<String> get allDisplayNames =>
      values.map((e) => e.displayName).toList();

  /// Checks if a key is valid
  static bool isValidKey(String key) {
    return allKeys.contains(key.toLowerCase());
  }

  /// Returns whether this template is interactive
  bool get isInteractive {
    return this == ModelStarterTemplate.custom;
  }

  /// Automatically generate allowedHelp map for argParser
  static Map<String, String> get allowedHelp {
    return {for (var t in values) t.key: t.description};
  }

  /// Returns the JSON template content
  String getJson() {
    return json;
  }

  /// Legacy getter for backward compatibility
  String get jsonTemplate => json;

  /// Get a list of formatted strings for display in prompts
  static List<String> get toList =>
      values.map((e) => '${e.key} - ${e.description}').toList();
}
