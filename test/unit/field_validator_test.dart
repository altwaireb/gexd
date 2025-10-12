@Tags(['unit'])
library;

import 'package:test/test.dart';
import 'package:gexd/src/core/utils/field_validator.dart';
import 'package:gexd/src/core/exceptions/validation_exception.dart';

void main() {
  group('FieldValidator Tests', () {
    group('Project Name Validation', () {
      test('should accept valid project names', () {
        final validator = FieldValidator("Project Name", example: "my_project");
        final validNames = [
          'test_app',
          'my_app',
          'flutter_project',
          'simple_name',
          'package_name',
        ];

        for (final name in validNames) {
          expect(
            () {
              validator.notEmpty(name);
              validator.minLength(name, 3);
              validator.maxLength(name, 30);
              validator.asciiOnly(name);
              validator.snakeCase(name, 'my_project');
              validator.startAlpha(name);
            },
            returnsNormally,
            reason: 'Should accept valid name: $name',
          );
        }
      });

      test('should reject invalid project names', () {
        final validator = FieldValidator("Project Name", example: "my_project");
        final invalidNames = [
          'Invalid Name', // spaces - not snake_case
          'invalid-name', // hyphens - not snake_case
          'INVALID_NAME', // uppercase - not snake_case
          'invalid.name', // dots - not snake_case
          '', // empty
          'ab', // too short (< 3)
        ];

        for (final name in invalidNames) {
          expect(
            () {
              validator.notEmpty(name);
              validator.minLength(name, 3);
              validator.maxLength(name, 30);
              validator.asciiOnly(name);
              validator.snakeCase(name, 'my_project');
              validator.startAlpha(name);
            },
            throwsA(isA<ValidationException>()),
            reason: 'Should reject invalid name: $name',
          );
        }
      });

      test('should provide clear error messages', () {
        final validator = FieldValidator("Project Name", example: "my_project");

        try {
          validator.snakeCase('Invalid Name', 'my_project');
          fail('Should have thrown ValidationException');
        } catch (e) {
          expect(e, isA<ValidationException>());
          final validationError = e as ValidationException;
          expect(
            validationError.message.toLowerCase(),
            anyOf([
              contains('project name'),
              contains('snake_case'),
              contains('format'),
            ]),
          );
        }
      });
    });

    group('Organization Validation', () {
      test('should accept valid organization identifiers', () {
        final validator = FieldValidator(
          "Organization",
          example: "com.example",
        );
        final validOrgs = [
          'com.example',
          'com.company.app',
          'org.flutter',
          'io.github.user',
          'dev.company',
        ];

        for (final org in validOrgs) {
          expect(
            () {
              validator.notEmpty(org);
              validator.minLength(org, 5);
              validator.maxLength(org, 50);
              validator.dotCase(org, 'com.example');
            },
            returnsNormally,
            reason: 'Should accept valid organization: $org',
          );
        }
      });

      test('should reject invalid organization identifiers', () {
        final validator = FieldValidator(
          "Organization",
          example: "com.example",
        );
        final invalidOrgs = [
          'invalid.', // ends with dot
          '.invalid', // starts with dot
          'invalid..name', // double dots
          '', // empty
          'ab', // too short
          'INVALID.NAME', // uppercase (not lowercase)
        ];

        for (final org in invalidOrgs) {
          expect(
            () {
              validator.notEmpty(org);
              validator.minLength(org, 5);
              validator.maxLength(org, 50);
              validator.dotCase(org, 'com.example');
            },
            throwsA(isA<ValidationException>()),
            reason: 'Should reject invalid organization: $org',
          );
        }
      });
    });

    group('General Validation Methods', () {
      test('should validate not empty correctly', () {
        final validator = FieldValidator("Test Field", example: "example");

        expect(() => validator.notEmpty('valid'), returnsNormally);
        expect(
          () => validator.notEmpty(''),
          throwsA(isA<ValidationException>()),
        );
        expect(
          () => validator.notEmpty('   '),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should validate minimum length correctly', () {
        final validator = FieldValidator("Test Field", example: "example");

        expect(() => validator.minLength('hello', 3), returnsNormally);
        expect(
          () => validator.minLength('hi', 3),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should validate maximum length correctly', () {
        final validator = FieldValidator("Test Field", example: "example");

        expect(() => validator.maxLength('hi', 5), returnsNormally);
        expect(
          () => validator.maxLength('hello world', 5),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should validate ASCII only correctly', () {
        final validator = FieldValidator("Test Field", example: "example");

        expect(() => validator.asciiOnly('hello'), returnsNormally);
        expect(() => validator.asciiOnly('hello123'), returnsNormally);
        expect(() => validator.asciiOnly('hello_world'), returnsNormally);
      });

      test('should validate start with alpha correctly', () {
        final validator = FieldValidator("Test Field", example: "example");

        expect(() => validator.startAlpha('hello'), returnsNormally);
        expect(() => validator.startAlpha('Hello'), returnsNormally);
        expect(
          () => validator.startAlpha('123hello'),
          throwsA(isA<ValidationException>()),
        );
        expect(
          () => validator.startAlpha('_hello'),
          throwsA(isA<ValidationException>()),
        );
      });
    });
  });
}
