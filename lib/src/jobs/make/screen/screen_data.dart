import 'dart:io';

import 'package:gexd/gexd.dart';

class ScreenData {
  final String name;
  final Directory targetDir;
  final ProjectTemplate template;
  final String? onPath;
  final bool skipRoute;
  final ScreenType screenType;
  final String? modelName;
  final bool hasModelFlag;
  final bool hasModel;
  final ModelDetectionData? modelData;
  final bool force;

  ScreenData({
    required this.name,
    required this.targetDir,
    required this.template,
    this.onPath,
    this.skipRoute = false,
    this.screenType = ScreenType.basic,
    this.modelName,
    this.hasModelFlag = false,
    this.hasModel = false,
    this.modelData,
    this.force = false,
  });

  bool get isBasic => screenType == ScreenType.basic;
  bool get isForm => screenType == ScreenType.form;
  bool get isState => screenType == ScreenType.withState;

  // bool get hasModel => modelName != null && modelName!.isNotEmpty;

  Map<String, dynamic> toVars() => {
    'name': name,
    'screenType': screenType,
    'modelName': modelName,
    'is_basic': isBasic,
    'is_form': isForm,
    'is_state': isState,
    'has_model': modelData?.exists ?? false,
    'modelExists': modelData?.exists ?? false,
    'modelImport': modelData?.importPath != null && modelData!.exists
        ? modelData!.importPath
        : null,
  };

  ScreenDataValue get value => ScreenDataValue(this);
}

class ScreenDataValue {
  final ScreenData _data;
  ScreenDataValue(this._data);

  String get name => _data.name;
  String? get onPath => _data.onPath;
  bool get skipRoute => _data.skipRoute;
  ScreenType get screenType => _data.screenType;
  String? get modelName => _data.modelName;
  bool get hasModelFlag => _data.hasModelFlag;
  bool get isBasic => _data.isBasic;
  bool get isForm => _data.isForm;
  bool get isState => _data.isState;
  bool get hasModel => _data.modelData?.exists ?? false;
  bool get modelExists => _data.modelData?.exists ?? false;
  String? get modelImport => _data.modelData?.importPath;
  String? get modelFilePath => _data.modelData?.filePath;
}
