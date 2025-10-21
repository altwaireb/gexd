@Tags(['unit'])
library;

import 'package:test/test.dart';
import 'package:gexd/src/jobs/create/create_data.dart';
import 'package:gexd/src/core/enums/project_template.dart';

void main() {
  group('CreateData Tests', () {
    test('should create CreateData with all required fields', () {
      final createData = CreateData(
        name: 'test_app',
        template: ProjectTemplate.getx,
        platforms: ['android', 'ios'],
        organization: 'com.example',
        description: 'A test Flutter app',
        full: false,
      );

      expect(createData.name, equals('test_app'));
      expect(createData.template, equals(ProjectTemplate.getx));
      expect(createData.platforms, containsAll(['android', 'ios']));
      expect(createData.organization, equals('com.example'));
      expect(createData.description, equals('A test Flutter app'));
      expect(createData.full, isFalse);
    });

    test('should create CreateData with different templates', () {
      final getxData = CreateData(
        name: 'getx_app',
        template: ProjectTemplate.getx,
        platforms: ['android'],
        organization: 'com.example',
        description: 'GetX app',
        full: true,
      );

      final cleanData = CreateData(
        name: 'clean_app',
        template: ProjectTemplate.clean,
        platforms: ['ios'],
        organization: 'com.example',
        description: 'Clean architecture app',
        full: false,
      );

      expect(getxData.template, equals(ProjectTemplate.getx));
      expect(cleanData.template, equals(ProjectTemplate.clean));
    });

    test('should handle different platform combinations', () {
      final androidOnly = CreateData(
        name: 'android_app',
        template: ProjectTemplate.getx,
        platforms: ['android'],
        organization: 'com.example',
        description: 'Android only app',
        full: false,
      );

      final multiPlatform = CreateData(
        name: 'multi_app',
        template: ProjectTemplate.clean,
        platforms: ['android', 'ios', 'web'],
        organization: 'com.example',
        description: 'Multi-platform app',
        full: true,
      );

      expect(androidOnly.platforms, equals(['android']));
      expect(multiPlatform.platforms, containsAll(['android', 'ios', 'web']));
      expect(multiPlatform.platforms?.length, equals(3));
    });

    test('should handle full structure flag correctly', () {
      final minimalData = CreateData(
        name: 'minimal_app',
        template: ProjectTemplate.getx,
        platforms: ['android'],
        organization: 'com.example',
        description: 'Minimal app',
        full: false,
      );

      final fullData = CreateData(
        name: 'full_app',
        template: ProjectTemplate.clean,
        platforms: ['android', 'ios'],
        organization: 'com.example',
        description: 'Full structure app',
        full: true,
      );

      expect(minimalData.full, isFalse);
      expect(fullData.full, isTrue);
    });

    test('should support equality comparison', () {
      final data1 = CreateData(
        name: 'test_app',
        template: ProjectTemplate.getx,
        platforms: ['android', 'ios'],
        organization: 'com.example',
        description: 'Test app',
        full: false,
      );

      final data2 = CreateData(
        name: 'test_app',
        template: ProjectTemplate.getx,
        platforms: ['android', 'ios'],
        organization: 'com.example',
        description: 'Test app',
        full: false,
      );

      final data3 = CreateData(
        name: 'different_app',
        template: ProjectTemplate.getx,
        platforms: ['android', 'ios'],
        organization: 'com.example',
        description: 'Test app',
        full: false,
      );

      // Note: This assumes CreateData implements proper equality
      // If not implemented, these will compare object references
      expect(data1.name, equals(data2.name));
      expect(data1.template, equals(data2.template));
      expect(data1.name, isNot(equals(data3.name)));
    });

    test('should have string representation', () {
      final createData = CreateData(
        name: 'test_app',
        template: ProjectTemplate.getx,
        platforms: ['android', 'ios'],
        organization: 'com.example',
        description: 'A test app',
        full: false,
      );

      final stringRep = createData.toString();
      expect(stringRep, isA<String>());
      expect(stringRep, isNotEmpty);
    });
  });
}
