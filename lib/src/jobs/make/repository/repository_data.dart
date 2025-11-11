import 'dart:io';

import 'package:gexd/gexd.dart';

/// Data class for repository job
/// Holds necessary information to generate repository files
/// using Mason templates
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
  final String? entityName;
  final EntityDetectionData? entityData;

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
    this.entityName,
    this.entityData,
  });

  /// Check if repository has model
  bool get hasModel => modelName != null && modelName!.isNotEmpty;

  /// Check if repository has entity
  bool get hasEntity => entityName != null && entityName!.isNotEmpty;

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
    'hasEntity': hasEntity,
    'entityName': entityName,
    'entityExists': entityData?.exists ?? false,
    'entityImport': entityData?.importPath != null && entityData!.exists
        ? entityData!.importPath
        : null,
    'packageName': projectName,
  };
}
