enum ProjectTemplate {
  getx(
    key: "getx",
    displayName: "GetX Standard Architecture",
    description: "GetX modular design.",
  ),
  clean(
    key: "clean",
    displayName: "Clean Architecture",
    description: "Layered DDD design.",
  );

  final String key;
  final String displayName;
  final String description;

  const ProjectTemplate({
    required this.key,
    required this.displayName,
    required this.description,
  });

  static ProjectTemplate fromKey(String key) {
    return values.firstWhere(
      (t) => t.key.toLowerCase() == key.toLowerCase(),
      orElse: () => throw ArgumentError("Unknown template: $key"),
    );
  }

  static ProjectTemplate fromString(String name) {
    return values.firstWhere(
      (t) => t.displayName.toLowerCase() == name.toLowerCase(),
      orElse: () => throw ArgumentError("Unknown template: $name"),
    );
  }

  static List<String> get allKeys =>
      ProjectTemplate.values.map((e) => e.key).toList();

  static List<String> get allDisplayNames =>
      ProjectTemplate.values.map((e) => e.displayName).toList();

  static bool isValidKey(String key) {
    return allKeys.contains(key.toLowerCase());
  }

  static List<String> get toList =>
      ProjectTemplate.values.map((t) => t.displayName).toList();

  /// Automatically generate allowedHelp map for argParser
  static Map<String, String> get allowedHelp {
    return {for (var t in values) t.key: t.description};
  }
}
