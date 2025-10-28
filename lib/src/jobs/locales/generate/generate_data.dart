import 'dart:io';

import 'package:gexd/gexd.dart';

class GenerateData {
  final String from;
  final String outputPath;
  final Directory targetDir;
  final LocaleKeyStyle keyStyle;
  final bool sortKeys;
  final bool force;
  final ProjectTemplate template;
  final NameComponent component;

  GenerateData({
    required this.from,
    required this.outputPath,
    required this.targetDir,
    required this.keyStyle,
    required this.sortKeys,
    required this.force,
    required this.template,
    required this.component,
  });

  /// Convert to variables for Mason template (if needed)
  Map<String, dynamic> toVars() => {
    'inputDir': from,
    'outputPath': outputPath,
    'keyStyle': keyStyle.key,
    'useDotNotation': keyStyle == LocaleKeyStyle.dot,
    'sortKeys': sortKeys,
  };
}
