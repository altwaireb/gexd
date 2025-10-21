import 'package:gexd/src/core/enums/project_template.dart';

import 'component_registry.dart';

class ArchitectureHelpers {
  ArchitectureHelpers._();

  /// Generate detailed nested tree for a given template including modules/submodules
  static String getTreeStructure(
    ProjectTemplate template, {
    bool full = false,
  }) {
    final buffer = StringBuffer();
    final templateName = template.displayName;

    buffer.writeln('📁 $templateName Template Structure');

    // Collect all paths first
    final components = ComponentRegistry.getComponentsForTemplate(
      template,
      onlyEssential: !full,
    );

    final allPaths = <String, String>{};

    for (var comp in components) {
      final meta = ComponentRegistry.get(comp);
      if (meta == null) continue;

      final path = meta.defaultPath[template];
      if (path == null) continue;

      allPaths[path] = meta.description;
    }

    // Build the complete tree structure
    final tree = _buildCompleteTree(allPaths);

    // Render with proper tree structure
    _renderCompleteTree(buffer, tree, []);

    // Always add assets at the end
    buffer.writeln('└── 📁 assets/   # Project assets');

    return buffer.toString();
  }

  /// Build a complete tree with proper hierarchy
  static Map<String, dynamic> _buildCompleteTree(Map<String, String> paths) {
    final tree = <String, dynamic>{};

    // Sort paths to ensure consistent ordering
    final sortedPaths = paths.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    for (final entry in sortedPaths) {
      final path = entry.key;
      final description = entry.value;

      final segments = path.split('/').where((s) => s.isNotEmpty).toList();

      var current = tree;
      for (int i = 0; i < segments.length; i++) {
        final segment = segments[i];

        if (current[segment] == null) {
          current[segment] = <String, dynamic>{};
        }

        // If this is the last segment, add description
        if (i == segments.length - 1) {
          (current[segment] as Map<String, dynamic>)['_description'] =
              description;
        }

        current = current[segment] as Map<String, dynamic>;
      }
    }

    return tree;
  }

  /// Render the complete tree with proper indentation
  static void _renderCompleteTree(
    StringBuffer buffer,
    Map<String, dynamic> tree,
    List<bool> isLastAtLevel, {
    int depth = 0,
  }) {
    final entries = tree.entries.where((e) => e.key != '_description').toList();

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final isLast = i == entries.length - 1;

      // Build indentation string
      final indent = StringBuffer();

      // Add indentations for parent levels
      for (int level = 0; level < depth; level++) {
        if (level < isLastAtLevel.length && isLastAtLevel[level]) {
          indent.write('    '); // Space for completed branch
        } else {
          indent.write('│   '); // Continuation line
        }
      }

      // Add current level connector
      if (depth == 0) {
        // Root level
        indent.write(isLast ? '└── 📁' : '├── 📁');
      } else {
        indent.write(isLast ? '└── 📁' : '├── 📁');
      }

      // Get description if available
      final description = entry.value['_description'] as String?;
      final line = description != null
          ? '$indent ${entry.key}   # $description'
          : '$indent ${entry.key}';

      buffer.writeln(line);

      // Process children
      final children = Map<String, dynamic>.from(entry.value)
        ..remove('_description');
      if (children.isNotEmpty) {
        final newIsLastAtLevel = List<bool>.from(isLastAtLevel);
        newIsLastAtLevel.add(isLast);
        _renderCompleteTree(
          buffer,
          children,
          newIsLastAtLevel,
          depth: depth + 1,
        );
      }
    }
  }

  /// Get description for a given template
  static String getDescription(ProjectTemplate template) {
    switch (template) {
      case ProjectTemplate.getx:
        return '''
GetX Template - Feature-based modular architecture
Perfect for medium to large applications using GetX state management.
Organizes code by features/modules with clear separation of concerns.
Includes domain layer for business logic and data layer for external dependencies.
''';
      case ProjectTemplate.clean:
        return '''
Clean Architecture Template - Domain-driven design with clear layer separation
Follows Uncle Bob's Clean Architecture principles with strict dependency rules.
Perfect for large, complex applications requiring high maintainability.
Separates business logic from framework details and external dependencies.
''';
    }
  }

  // Keep utility functions for backward compatibility
  static String toSnakeCase(String s) {
    return s.replaceAll(RegExp(r'\s+'), '_').toLowerCase();
  }

  static String pascalCase(String s) {
    return s
        .split(RegExp(r'[_\s-]'))
        .map((p) => p.isEmpty ? '' : '${p[0].toUpperCase()}${p.substring(1)}')
        .join();
  }

  static bool isValidProjectName(String name) {
    final regex = RegExp(r'^[a-z][a-z0-9_]*$');
    return regex.hasMatch(name);
  }
}
