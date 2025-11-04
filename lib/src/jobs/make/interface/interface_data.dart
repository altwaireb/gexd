import 'dart:io';

import 'package:gexd/gexd.dart';

class InterfaceData {
  final String name;
  final Directory targetDir;
  final ProjectTemplate template;
  final String projectName;
  final InterfaceLocation location;
  final InterfaceType type;
  final NameComponent component;
  final String? onPath;
  final bool force;
  final String? modelName;
  final ModelDetectionData? modelData;

  InterfaceData({
    required this.name,
    required this.targetDir,
    required this.template,
    required this.projectName,
    required this.location,
    required this.type,
    required this.onPath,
    required this.force,
    required this.component,
    this.modelName,
    this.modelData,
  });

  /// Check if interface has model
  bool get hasModel => modelName != null && modelName!.isNotEmpty;

  Map<String, dynamic> toVars() => {
    'name': name,
    'is_crud': type.key == InterfaceType.crud.key,
    'is_empty': type.key == InterfaceType.empty.key,
    'hasModel': hasModel,
    'modelName': modelName,
    'modelExists': modelData?.exists ?? false,
    'modelImport': modelData?.importPath != null && modelData!.exists
        ? modelData!.importPath
        : null,
    'packageName': projectName,
  };
}
