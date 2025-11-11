import 'dart:io';

import 'package:gexd/gexd.dart';

/// Data class for view job
/// Holds necessary information to generate view files
/// using Mason templates
class WidgetData {
  final String name;
  final Directory targetDir;
  final ProjectTemplate template;
  final WidgetLocation location;
  final NameComponent component;
  final String? screenName;
  final String? onPath;
  final bool force;

  WidgetData({
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
    'is_shared': location.key == WidgetLocation.shared.key,
    'is_screen': location.key == WidgetLocation.screen.key,
  };
}
