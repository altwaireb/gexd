/// 🔧 Configuration Service - Fast project config detection
/// Handles .gexd/config.yaml reading with caching for performance
library;

import 'dart:io';
import 'package:gexd/src/core/enums/project_template.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';
import '../models/project_config.dart';
import '../version.dart' as version;

/// Fast configuration service with caching
class ConfigService {
  static const String _configFileName = '.gexd/config.yaml';
  static String? _cachedProjectRoot;
  static ProjectTemplate? _cachedTemplate;
  static DateTime? _lastRead;

  /// Get project template from .gexd/config.yaml
  /// Returns null if not in Gexd project
  static Future<ProjectTemplate?> getProjectTemplate() async {
    try {
      final configFile = await _findConfigFile();
      if (configFile == null) return null;

      // Cache optimization - avoid re-reading if file hasn't changed
      final lastModified = await configFile.lastModified();
      if (_cachedTemplate != null &&
          _lastRead != null &&
          lastModified.isBefore(_lastRead!)) {
        return _cachedTemplate;
      }

      final content = await configFile.readAsString();
      final yaml = loadYaml(content) as Map;

      final templateType = yaml['template'] as String?;
      if (templateType == null) return null;

      // Cache the result
      _cachedTemplate = ProjectTemplate.fromKey(templateType);
      _lastRead = DateTime.now();

      return _cachedTemplate;
    } catch (e) {
      // Silent fail - not in Gexd project
      return null;
    }
  }

  /// Get project name from .gexd/config.yaml
  /// Returns null if not in Gexd project
  static Future<String?> getProjectName() async {
    try {
      final configFile = await _findConfigFile();
      if (configFile == null) return null;

      final content = await configFile.readAsString();
      final yaml = loadYaml(content) as Map;

      return yaml['project_name'] as String?;
    } catch (e) {
      // Silent fail - not in Gexd project
      return null;
    }
  }

  /// Check if current directory is a Gexd project
  static Future<bool> isInGexdProject() async {
    final configFile = await _findConfigFile();
    return configFile != null && await configFile.exists();
  }

  /// Get project root directory (where .gexd/config.yaml exists)
  static Future<String?> getProjectRoot() async {
    final configFile = await _findConfigFile();
    if (configFile == null) return null;

    return path.dirname(path.dirname(configFile.path));
  }

  /// Find .gexd/config.yaml by walking up directory tree
  static Future<File?> _findConfigFile() async {
    if (_cachedProjectRoot != null) {
      final file = File(path.join(_cachedProjectRoot!, _configFileName));
      if (await file.exists()) return file;
    }

    var current = Directory.current;

    while (current.path != current.parent.path) {
      final configFile = File(path.join(current.path, _configFileName));

      if (await configFile.exists()) {
        _cachedProjectRoot = current.path;
        return configFile;
      }

      current = current.parent;
    }

    return null;
  }

  /// Clear cache (useful for testing)
  static void clearCache() {
    _cachedProjectRoot = null;
    _cachedTemplate = null;
    _lastRead = null;
  }

  /// Create .gexd/config.yaml for new projects
  static Future<void> createConfig({
    required String projectPath,
    required ProjectTemplate template,
    Map<String, dynamic>? additionalConfig,
  }) async {
    final configDir = Directory(path.join(projectPath, '.gexd'));
    await configDir.create(recursive: true);

    final configFile = File(path.join(configDir.path, 'config.yaml'));

    final config = <String, dynamic>{
      'generated_by': 'Gexd CLI',
      'creation_version': version.packageVersion,
      'current_version': version.packageVersion,
      'generated_date': DateTime.now().toIso8601String(),
      'last_updated': null,
      'project_name': additionalConfig?['project_name'] ?? 'unknown',
      'template': template.key,
      ...?additionalConfig,
    };

    final yamlContent = _mapToYaml(config);
    await configFile.writeAsString(yamlContent);
  }

  /// Read project configuration from config.yaml
  static Future<ProjectConfig?> readProjectConfig([String? projectPath]) async {
    try {
      final File configFile;
      if (projectPath != null) {
        configFile = File(path.join(projectPath, '.gexd', 'config.yaml'));
      } else {
        final foundFile = await _findConfigFile();
        if (foundFile == null) return null;
        configFile = foundFile;
      }

      if (!await configFile.exists()) return null;

      final content = await configFile.readAsString();
      final yaml = loadYaml(content) as Map;
      return ProjectConfig.fromYaml(yaml);
    } catch (e) {
      return null;
    }
  }

  /// Update project configuration
  static Future<bool> updateProjectConfig({
    required String projectPath,
    required ProjectConfig updatedConfig,
  }) async {
    try {
      final configFile = File(path.join(projectPath, '.gexd', 'config.yaml'));
      if (!await configFile.exists()) return false;

      final yamlContent = _mapToYaml(updatedConfig.toYaml());
      await configFile.writeAsString(yamlContent);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Find all Gexd projects recursively in a directory
  static Future<List<String>> findGexdProjects(Directory directory) async {
    final projects = <String>[];

    try {
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.gexd/config.yaml')) {
          // Skip template/brick directories
          if (entity.path.contains('/bricks/') ||
              entity.path.contains('/__brick__/')) {
            continue;
          }

          // Return project root path (parent of .gexd directory)
          final projectRoot = path.dirname(path.dirname(entity.path));
          projects.add(projectRoot);
        }
      }
    } catch (e) {
      // Ignore permission errors, etc.
    }

    return projects;
  }

  /// Update project version and track the update
  static Future<bool> updateProjectVersion({
    required String projectPath,
    required String newVersion,
  }) async {
    try {
      final config = await readProjectConfig(projectPath);
      if (config == null) return false;

      final updatedConfig = config.copyWith(
        currentVersion: newVersion,
        lastUpdated: DateTime.now(),
        updateCount: (config.updateCount ?? 0) + 1,
      );

      return await updateProjectConfig(
        projectPath: projectPath,
        updatedConfig: updatedConfig,
      );
    } catch (e) {
      return false;
    }
  }

  /// Convert Map to YAML string (simple implementation)
  static String _mapToYaml(Map<String, dynamic> map) {
    final buffer = StringBuffer();

    // Generation Details section
    buffer.writeln('# Generation Details');
    if (map.containsKey('generated_by')) {
      buffer.writeln('generated_by: ${map['generated_by']}');
    }
    if (map.containsKey('creation_version')) {
      buffer.writeln('creation_version: ${map['creation_version']}');
    }
    if (map.containsKey('current_version')) {
      buffer.writeln('current_version: ${map['current_version']}');
    }
    if (map.containsKey('generated_date')) {
      buffer.writeln('generated_date: ${map['generated_date']}');
    }
    if (map.containsKey('last_updated')) {
      buffer.writeln('last_updated: ${map['last_updated']}');
    }
    if (map.containsKey('update_count')) {
      buffer.writeln('update_count: ${map['update_count']}');
    }
    buffer.writeln();

    // Project Information section
    buffer.writeln('# Project Information');
    if (map.containsKey('project_name')) {
      buffer.writeln('project_name: ${map['project_name']}');
    }
    if (map.containsKey('template')) {
      buffer.writeln('template: ${map['template']}');
    }

    return buffer.toString();
  }
}
