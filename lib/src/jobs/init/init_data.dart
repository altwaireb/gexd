import 'package:gexd/gexd.dart';

class InitData {
  final String name;
  final ProjectTemplate template;
  final bool? full;
  final String targetDir;

  InitData({
    required this.name,
    required this.template,
    this.full,
    required this.targetDir,
  });

  Map<String, dynamic> toVars() {
    return {
      'project_name': name, // Mason expects project_name
      'name': name,
      'template': template.key,
      'full': full ?? false,
      'is_getx': template == ProjectTemplate.getx,
      'is_clean': template == ProjectTemplate.clean,
      'is_create': false,
      'version': packageVersion,
    };
  }
}
