import 'package:gexd/src/core/enums/project_template.dart';
import 'package:gexd/src/version.dart';

/// Data required for creating a new project
/// Includes project name, template, platforms, organization, and description
/// Provides a method to convert data into a map of variables for templating
class CreateData {
  final String name;
  final ProjectTemplate template;
  final List<String>? platforms;
  final String? organization;
  final String? description;
  final bool? full;

  CreateData({
    required this.name,
    required this.template,
    this.platforms,
    this.organization,
    this.description,
    this.full = false,
  });

  Map<String, dynamic> toVars() {
    return {
      'project_name': name, // Mason expects project_name
      'name': name,
      'template': template.key,
      'platforms': platforms ?? ['android', 'ios'],
      'organization': organization ?? 'com.example',
      'description': description ?? 'A new Flutter project.',
      'full': full ?? false,
      'is_getx': template == ProjectTemplate.getx,
      'is_clean': template == ProjectTemplate.clean,
      'is_create': true,
      'version': packageVersion,
    };
  }
}
