import 'dart:io';

import 'package:gexd/gexd.dart';

/// Data class for model job
/// Holds necessary information to generate model files
class ModelData {
  final String name;
  final Directory targetDir;
  final ProjectTemplate template;
  final ModelInputSourceType inputSourceType;
  final String? filePath;
  final String? urlPath;
  final ModelStyle style;
  final ModelStarterTemplate starterTemplate;
  final List<CustomField> customFields;
  final bool immutable;
  final bool copyWith;
  final bool equatable;
  final bool relationshipsInFolder;
  final NameComponent component;
  final String? onPath;
  final bool force;

  ModelData({
    required this.name,
    required this.targetDir,
    required this.template,
    required this.inputSourceType,
    required this.filePath,
    required this.urlPath,
    required this.style,
    required this.starterTemplate,
    this.customFields = const [],
    required this.immutable,
    required this.copyWith,
    required this.equatable,
    required this.relationshipsInFolder,
    required this.onPath,
    required this.force,
    required this.component,
  });

  Map<String, dynamic> toVars() => {'name': name};
}
