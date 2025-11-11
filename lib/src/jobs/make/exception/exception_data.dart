import 'dart:io';

import 'package:gexd/gexd.dart';

/// Data class for exception job
/// Holds necessary information to generate exception files
/// using Mason templates
class ExceptionData {
  final String name;
  final Directory targetDir;
  final ProjectTemplate template;
  final NameComponent component;
  final String? onPath;
  final bool force;

  ExceptionData({
    required this.name,
    required this.targetDir,
    required this.template,
    required this.onPath,
    required this.force,
    required this.component,
  });

  Map<String, dynamic> toVars() => {'name': name};
}
