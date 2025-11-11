import 'dart:io';

import 'package:gexd/gexd.dart';

/// Data class for service job
/// Holds necessary information to generate service files
/// using Mason templates
class ServiceData {
  final String name;
  final Directory targetDir;
  final ProjectTemplate template;
  final NameComponent component;
  final String? onPath;
  final bool force;

  ServiceData({
    required this.name,
    required this.targetDir,
    required this.template,
    required this.onPath,
    required this.force,
    required this.component,
  });

  Map<String, dynamic> toVars() => {'name': name};
}
