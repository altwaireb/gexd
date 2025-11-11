import 'dart:io';

import 'package:gexd/gexd.dart';

/// Data class for constant job
/// Holds necessary information to generate constant files
/// using Mason templates
class ConstantData {
  final String name;
  final Directory targetDir;
  final ProjectTemplate template;
  final NameComponent component;
  final String? onPath;
  final bool force;

  ConstantData({
    required this.name,
    required this.targetDir,
    required this.template,
    required this.onPath,
    required this.force,
    required this.component,
  });

  Map<String, dynamic> toVars() => {'name': name};
}
