import 'dart:io';

import 'package:gexd/gexd.dart';

/// Data class for controller job
/// Holds necessary information to generate controller files
/// using Mason templates
class ControllerData {
  final String name;
  final Directory targetDir;
  final ProjectTemplate template;
  final ControllerLocation location;
  final NameComponent component;
  final String? screenName;
  final String? onPath;
  final bool force;

  ControllerData({
    required this.name,
    required this.targetDir,
    required this.template,
    required this.location,
    required this.onPath,
    required this.force,
    required this.component,
    required this.screenName,
  });

  Map<String, dynamic> toVars() => {
    'name': name,
    'screenName': screenName,
    'is_shared': location.key == ControllerLocation.shared.key,
    'is_screen': location.key == ControllerLocation.screen.key,
  };
}
