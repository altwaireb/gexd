import 'dart:io';
import 'package:gexd/gexd.dart';

/// Service responsible for detecting models within the project structure.
class ModelDetectionService {
  /// Check if a model exists within the project by its name.
  ///
  /// This will:
  /// - Convert the model name to `snake_case`
  /// - Append `_model.dart`
  /// - Search in the model directory based on the project template.
  static Future<bool> exists({
    required String modelName,
    required ProjectTemplate template,
    required Directory basePath,
    List<String> suffixes = const ['Model'],
  }) async {
    final result = await ModelDetectionService.getModelPath(
      modelName: modelName,
      template: template,
      basePath: basePath,
      suffixes: suffixes,
    );

    return result != null && result.isNotEmpty;
  }

  /// Get the absolute path for the model (if it exists), otherwise null.
  static Future<String?> getModelPath({
    required String modelName,
    required ProjectTemplate template,
    required Directory basePath,
    List<String> suffixes = const ['Model'],
  }) async {
    final modelsPath = ArchitectureCoordinator.getComponentPath(
      NameComponent.models,
      template,
    );

    if (modelsPath.isEmpty) return null;

    final dir = Directory('${basePath.path}/$modelsPath');
    if (!await dir.exists()) return null;

    // 🧠 تحديد baseName (اسم بدون أي suffix)
    String baseName = modelName;
    for (final suffix in suffixes) {
      if (modelName.endsWith(suffix)) {
        baseName = modelName.substring(0, modelName.length - suffix.length);
        break;
      }
    }

    final snakeName = StringHelpers.toSnakeCase(baseName);

    final suffixesFileNames = [
      for (final suffix in suffixes)
        '${snakeName}_${suffix.toLowerCase()}.dart',
    ];

    final possibleFileNames = [...suffixesFileNames, '$snakeName.dart'];

    // 🧠 الخطوة 1: البحث عن الكلاس بالاسم الكامل (كما كتبه المستخدم)
    final classPattern = RegExp(
      r'\bclass\s+' + RegExp.escape(modelName) + r'\b',
    );
    String? foundPath = await _findInFiles(
      dir,
      possibleFileNames,
      classPattern,
    );
    if (foundPath != null) return foundPath;

    // 🧠 الخطوة 2: البحث عن الكلاس بدون suffix (إن وجد)
    if (baseName != modelName) {
      final altClassPattern = RegExp(
        r'\bclass\s+' + RegExp.escape(baseName) + r'\b',
      );
      foundPath = await _findInFiles(dir, possibleFileNames, altClassPattern);
      if (foundPath != null) return foundPath;
    }

    // 🧠 الخطوة 3 (اختيارية): البحث في جميع ملفات models لو لم نجد شيء
    final looseClassPattern = RegExp(
      r'\bclass\s+' + RegExp.escape(modelName) + r'\b',
    );
    foundPath = await _findInFiles(dir, null, looseClassPattern);
    if (foundPath != null) return foundPath;

    // 🧠 الخطوة 4: البحث بالـ baseName فقط (بدون suffix)
    if (baseName != modelName) {
      final looseAltPattern = RegExp(
        r'\bclass\s+' + RegExp.escape(baseName) + r'\b',
      );
      foundPath = await _findInFiles(dir, null, looseAltPattern);
      if (foundPath != null) return foundPath;
    }

    return null;
  }

  /// 🧰 دالة مساعدة للبحث داخل الملفات
  static Future<String?> _findInFiles(
    Directory dir,
    List<String>? fileNames,
    RegExp pattern,
  ) async {
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;

      if (fileNames != null &&
          !fileNames.any((name) => entity.path.endsWith(name))) {
        continue;
      }

      final content = await entity.readAsString();
      if (pattern.hasMatch(content)) {
        return entity.path;
      }
    }
    return null;
  }

  /// Get detailed model data including class name, file name, path, import path, and existence.
  static Future<ModelDetectionData> getModelData({
    required String modelName,
    required ProjectTemplate template,
    required Directory basePath,
    List<String> suffixes = const ['Model'],
  }) async {
    final result = await getModelPath(
      modelName: modelName,
      template: template,
      basePath: basePath,
      suffixes: suffixes,
    );
    final className = StringHelpers.toPascalCase(modelName);
    final exists = result != null && result.isNotEmpty;

    if (!exists) {
      return ModelDetectionData(
        className: className,
        fileName: '',
        filePath: '',
        importPath: '',
        exists: false,
      );
    }

    final fileName = result.split('/').last;
    final filePath = result.startsWith('/lib')
        ? result.substring(1) // remove leading '/'
        : result;
    final importPath = _generateImportPath(result);

    return ModelDetectionData(
      className: className,
      fileName: fileName,
      filePath: filePath, // shows only to the developer
      importPath: importPath,
      exists: true,
    );
  }

  /// Return model name variations (PascalCase, snake_case, file name)
  static Map<String, String> nameFormats(String modelName) {
    final pascal = StringHelpers.toPascalCase(modelName);
    final snake = StringHelpers.toSnakeCase(modelName);
    return {'pascal': pascal, 'snake': snake, 'file': '${snake}_model.dart'};
  }

  /// Get project name synchronously from pubspec.yaml
  static String _getProjectNameSync(String basePath) {
    try {
      final pubspecFile = File('$basePath/pubspec.yaml');
      if (pubspecFile.existsSync()) {
        final content = pubspecFile.readAsStringSync();
        final lines = content.split('\n');
        for (final line in lines) {
          if (line.startsWith('name:')) {
            return line.split(':').last.trim();
          }
        }
      }
    } catch (e) {
      // Fallback to directory name
    }
    return Directory.current.path.split('/').last;
  }

  static String _generateImportPath(String filePath) {
    final projectRoot = Directory.current.path;
    if (filePath.startsWith(projectRoot)) {
      final relativePath = filePath.substring(projectRoot.length + 1);

      // Remove 'lib/' prefix if present for package imports
      final packagePath = relativePath.startsWith('lib/')
          ? relativePath.substring(4)
          : relativePath;

      final projectName = _getProjectNameSync(filePath);
      return 'package:$projectName/$packagePath';
    }
    return '';
  }
}

class ModelDetectionData {
  // PascalCase
  final String className;
  // file name with extension
  final String fileName;
  // full file path
  final String filePath;
  // import path to be used in Dart files
  final String importPath;
  // whether the model file actually exists
  final bool exists;

  ModelDetectionData({
    required this.className,
    required this.fileName,
    required this.filePath,
    required this.importPath,
    required this.exists,
  });
}
