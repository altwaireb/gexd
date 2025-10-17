import 'dart:io';
import 'package:gexd/gexd.dart';

/// E2EValidators
///
/// Contains reusable validators for verifying the generated project structure.
class E2EValidators {
  /// Validate the folder structure for a GetX architecture project
  static Future<void> validateGetXStructure(Directory dir) async {
    final appDir = Directory('${dir.path}/lib/app');
    if (!await appDir.exists()) {
      throw ValidationException.notFound('App directory');
    }

    final coreDir = Directory('${appDir.path}/core');
    final modulesDir = Directory('${appDir.path}/modules');

    if (!await coreDir.exists()) {
      throw ValidationException.notFound('core directory');
    }
    if (!await modulesDir.exists()) {
      throw ValidationException.notFound('modules directory');
    }

    print('✅ GetX structure validated successfully');
  }

  /// Validate the folder structure for a Clean architecture project
  static Future<void> validateCleanStructure(Directory dir) async {
    final presentationDir = Directory('${dir.path}/lib/presentation');
    if (!await presentationDir.exists()) {
      throw ValidationException.notFound('presentation directory');
    }

    final coreDir = Directory('${dir.path}/lib/core');
    if (!await coreDir.exists()) {
      throw ValidationException.notFound('core directory');
    }

    print('✅ Clean Architecture structure validated successfully');
  }

  /// Validate that basic Flutter project structure exists
  static Future<void> validateBasicStructure(Directory dir) async {
    final files = ['pubspec.yaml', 'lib/main.dart'];

    for (final file in files) {
      final fileToCheck = File('${dir.path}/$file');
      if (!await fileToCheck.exists()) {
        throw ValidationException.notFound(file);
      }
    }

    print('✅ Basic project structure validated successfully');
  }

  /// Validate that generated files exist
  static Future<void> validateGeneratedFiles(
    Directory dir,
    List<String> expectedFiles,
  ) async {
    final missing = <String>[];

    for (final file in expectedFiles) {
      final fileToCheck = File('${dir.path}/$file');
      if (!await fileToCheck.exists()) {
        missing.add(file);
      }
    }

    if (missing.isNotEmpty) {
      throw ValidationException.custom(
        'Generated files missing: ${missing.join(', ')}',
      );
    }

    print('✅ Generated files validated: ${expectedFiles.length} files found');
  }
}
