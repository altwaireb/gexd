import 'dart:io';
import 'package:gexd/gexd.dart';

/// Data class for entity job
/// Holds necessary information to generate entity files
/// using Mason templates
class EntityData {
  final String name;
  final Directory targetDir;
  final ProjectTemplate template;
  final EntityInputSourceType inputSourceType;
  final String? filePath;
  final String? urlPath;
  final EntityStyle style;
  final bool withModel;
  final bool equatable;
  final NameComponent component;
  final String? onPath;
  final bool force;

  EntityData({
    required this.name,
    required this.targetDir,
    required this.template,
    required this.inputSourceType,
    required this.filePath,
    required this.urlPath,
    required this.style,
    required this.withModel,
    required this.equatable,
    required this.onPath,
    required this.force,
    required this.component,
  });

  Map<String, dynamic> toVars() => {'name': name};
}

/// Input source type for entity generation
enum EntityInputSourceType {
  template('template', 'Create from basic template'),
  file('file', 'Generate from JSON file'),
  url('url', 'Generate from API endpoint');

  const EntityInputSourceType(this.key, this.displayName);

  final String key;
  final String displayName;

  static EntityInputSourceType fromKey(String key) {
    return EntityInputSourceType.values.firstWhere(
      (template) => template.key == key,
      orElse: () => EntityInputSourceType.template,
    );
  }

  static List<String> get allKeys =>
      EntityInputSourceType.values.map((e) => e.key).toList();

  static Map<String, String> get allowedHelp => Map.fromEntries(
    EntityInputSourceType.values.map((e) => MapEntry(e.key, e.displayName)),
  );

  static List<String> get toList =>
      EntityInputSourceType.values.map((e) => e.displayName).toList();
}
