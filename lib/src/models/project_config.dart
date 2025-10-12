/// 📄 Project Configuration Model
/// Represents a Gexd project configuration from .gexd/config.yaml
library;

import 'package:gexd/src/core/enums/project/project_template.dart';

/// Project configuration data model
class ProjectConfig {
  final String? generatedBy;
  final String? creationVersion;
  final String? currentVersion;
  final DateTime? generatedDate;
  final DateTime? lastUpdated;
  final int? updateCount;
  final String? projectName;
  final ProjectTemplate? template;
  final Map<String, dynamic> additionalFields;

  const ProjectConfig({
    this.generatedBy,
    this.creationVersion,
    this.currentVersion,
    this.generatedDate,
    this.lastUpdated,
    this.updateCount,
    this.projectName,
    this.template,
    this.additionalFields = const {},
  });

  /// Create ProjectConfig from YAML map
  factory ProjectConfig.fromYaml(Map<dynamic, dynamic> yaml) {
    final map = yaml.cast<String, dynamic>();

    return ProjectConfig(
      generatedBy: map['generated_by'] as String?,
      creationVersion: map['creation_version'] as String?,
      currentVersion: map['current_version'] as String?,
      generatedDate: _parseDateTime(map['generated_date']),
      lastUpdated: _parseDateTime(map['last_updated']),
      updateCount: map['update_count'] as int?,
      projectName: map['project_name'] as String?,
      template: map['template'] != null
          ? ProjectTemplate.fromKey(map['template'] as String)
          : null,
      additionalFields: Map<String, dynamic>.from(map)
        ..removeWhere((key, value) => _isKnownField(key)),
    );
  }

  /// Convert to YAML map
  Map<String, dynamic> toYaml() {
    final map = <String, dynamic>{
      if (generatedBy != null) 'generated_by': generatedBy,
      if (creationVersion != null) 'creation_version': creationVersion,
      if (currentVersion != null) 'current_version': currentVersion,
      if (generatedDate != null)
        'generated_date': generatedDate!.toIso8601String(),
      if (lastUpdated != null) 'last_updated': lastUpdated!.toIso8601String(),
      if (updateCount != null) 'update_count': updateCount,
      if (projectName != null) 'project_name': projectName,
      if (template != null) 'template': template!.key,
      ...additionalFields,
    };

    return map;
  }

  /// Create a copy with updated fields
  ProjectConfig copyWith({
    String? generatedBy,
    String? creationVersion,
    String? currentVersion,
    DateTime? generatedDate,
    DateTime? lastUpdated,
    int? updateCount,
    String? projectName,
    ProjectTemplate? template,
    Map<String, dynamic>? additionalFields,
  }) {
    return ProjectConfig(
      generatedBy: generatedBy ?? this.generatedBy,
      creationVersion: creationVersion ?? this.creationVersion,
      currentVersion: currentVersion ?? this.currentVersion,
      generatedDate: generatedDate ?? this.generatedDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      updateCount: updateCount ?? this.updateCount,
      projectName: projectName ?? this.projectName,
      template: template ?? this.template,
      additionalFields: additionalFields ?? this.additionalFields,
    );
  }

  /// Get effective version (current_version, creation_version, or gexd_version)
  String? get effectiveVersion =>
      currentVersion ??
      creationVersion ??
      additionalFields['gexd_version'] as String?;

  /// Check if project needs update
  bool needsUpdate(String targetVersion) {
    final current = effectiveVersion;
    return current != null && current != targetVersion;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static bool _isKnownField(String key) {
    return {
      'generated_by',
      'creation_version',
      'current_version',
      'generated_date',
      'last_updated',
      'update_count',
      'project_name',
      'template',
    }.contains(key);
  }

  @override
  String toString() {
    return 'ProjectConfig('
        'projectName: $projectName, '
        'template: ${template?.key}, '
        'version: $effectiveVersion'
        ')';
  }
}
