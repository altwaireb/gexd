@Tags(['unit'])
library;

import 'package:test/test.dart';
import 'package:gexd/src/core/enums/project_template.dart';

void main() {
  group('ProjectTemplate Tests', () {
    test('should have correct enum values', () {
      expect(ProjectTemplate.getx.name, equals('getx'));
      expect(ProjectTemplate.clean.name, equals('clean'));
      expect(ProjectTemplate.values.length, equals(2));
    });

    test('should find templates by name', () {
      // Test finding GetX template
      final getxTemplate = ProjectTemplate.values
          .where((template) => template.name == 'getx')
          .firstOrNull;
      expect(getxTemplate, equals(ProjectTemplate.getx));

      // Test finding Clean template
      final cleanTemplate = ProjectTemplate.values
          .where((template) => template.name == 'clean')
          .firstOrNull;
      expect(cleanTemplate, equals(ProjectTemplate.clean));
    });

    test('should return null for invalid template names', () {
      final invalidTemplate = ProjectTemplate.values
          .where((template) => template.name == 'invalid')
          .firstOrNull;
      expect(invalidTemplate, isNull);
    });

    test('should have unique template names', () {
      final names = ProjectTemplate.values.map((t) => t.name).toList();
      final uniqueNames = names.toSet().toList();
      expect(names.length, equals(uniqueNames.length));
    });

    test('should support all expected templates', () {
      final expectedTemplates = ['getx', 'clean'];
      final actualTemplates = ProjectTemplate.values
          .map((t) => t.name)
          .toList();

      for (final expected in expectedTemplates) {
        expect(actualTemplates, contains(expected));
      }
    });

    test('should provide string representation', () {
      expect(ProjectTemplate.getx.toString(), contains('getx'));
      expect(ProjectTemplate.clean.toString(), contains('clean'));
    });

    test('should be comparable', () {
      expect(ProjectTemplate.getx == ProjectTemplate.getx, isTrue);
      expect(ProjectTemplate.getx == ProjectTemplate.clean, isFalse);
      expect(ProjectTemplate.clean == ProjectTemplate.clean, isTrue);
    });

    test('should have consistent index values', () {
      expect(ProjectTemplate.getx.index, isA<int>());
      expect(ProjectTemplate.clean.index, isA<int>());
      expect(ProjectTemplate.getx.index != ProjectTemplate.clean.index, isTrue);
    });
  });
}
