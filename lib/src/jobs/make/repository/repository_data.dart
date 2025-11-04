import 'dart:io';

import 'package:gexd/gexd.dart';

class RepositoryData {
  final String name;
  final Directory targetDir;
  final ProjectTemplate template;
  final String projectName;
  final RepositoryType type;
  final bool hasInterface;
  final NameComponent component;
  final String? onPath;
  final bool force;
  final String? modelName;
  final ModelDetectionData? modelData;

  RepositoryData({
    required this.name,
    required this.targetDir,
    required this.template,
    required this.projectName,
    required this.type,
    required this.hasInterface,
    required this.onPath,
    required this.force,
    required this.component,
    this.modelName,
    this.modelData,
  });

  /// Check if repository has model
  bool get hasModel => modelName != null && modelName!.isNotEmpty;

  Map<String, dynamic> toVars() => {
    'name': name,
    'is_crud': type.key == RepositoryType.crud.key,
    'is_empty': type.key == RepositoryType.empty.key,
    'hasInterface': hasInterface,
    'hasModel': hasModel,
    'modelName': modelName,
    'modelExists': modelData?.exists ?? false,
    'modelImport': modelData?.importPath != null && modelData!.exists
        ? modelData!.importPath
        : null,
    'packageName': projectName,
  };
}
