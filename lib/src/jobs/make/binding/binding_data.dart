import 'dart:io';

import 'package:gexd/gexd.dart';

/// Data class for binding job
/// Holds necessary information to generate binding files
/// using Mason templates
class BindingData {
  final String name;
  final Directory targetDir;
  final ProjectTemplate template;
  final BindingLocation location;
  final NameComponent component;
  final String? screenName;
  final String? onPath;
  final bool force;

  BindingData({
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
    'is_core': location.key == BindingLocation.core.key,
    'is_shared': location.key == BindingLocation.shared.key,
    'is_screen': location.key == BindingLocation.screen.key,
  };
}
