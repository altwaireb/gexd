/// Defines the source of input data for model generation
enum ModelInputSourceType {
  /// Read JSON data from a local file
  file(
    key: 'file',
    displayName: 'File - Load from local JSON file',
    description: 'Read JSON data from a local file on your system',
    icon: '📁',
    requiresNetwork: false,
    isInteractive: false,
  ),

  /// Download JSON data from a URL
  url(
    key: 'url',
    displayName: 'URL - Fetch from web endpoint',
    description: 'Download JSON data from a web URL or API endpoint',
    icon: '🌐',
    requiresNetwork: true,
    isInteractive: false,
  ),

  /// Use a starter template (interactive)
  template(
    key: 'template',
    displayName: 'Template - Use built-in JSON template',
    description: 'Choose from predefined JSON templates for quick start',
    icon: '📋',
    requiresNetwork: false,
    isInteractive: true,
  );

  const ModelInputSourceType({
    required this.key,
    required this.displayName,
    required this.description,
    required this.icon,
    required this.requiresNetwork,
    required this.isInteractive,
  });

  final String key;
  final String displayName;
  final String description;
  final String icon;
  final bool requiresNetwork;
  final bool isInteractive;

  /// Creates ModelInputSourceType from key
  static ModelInputSourceType fromKey(String key) {
    return values.firstWhere(
      (t) => t.key.toLowerCase() == key.toLowerCase(),
      orElse: () => throw ArgumentError('Unknown input source type: $key'),
    );
  }

  /// Check if key is valid
  static bool isValidKey(String key) {
    return values.any((t) => t.key.toLowerCase() == key.toLowerCase());
  }

  /// Get all keys for CLI allowed options
  static List<String> get allKeys => values.map((t) => t.key).toList();

  /// Get allowed help for CLI
  static Map<String, String> get allowedHelp {
    return {for (final type in values) type.key: type.description};
  }

  static bool isInteractiveType(String key) {
    final type = fromKey(key);
    return type.isInteractive;
  }

  /// Get a list of formatted strings for display in prompts
  static List<String> get toList =>
      values.map((e) => '${e.key} - ${e.description}').toList();
}
