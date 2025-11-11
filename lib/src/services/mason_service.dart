import 'dart:io';
import 'package:gexd/gexd.dart';
import 'package:mason/mason.dart';

/// MasonService - Handles Mason brick generation
/// Implements MasonServiceInterface
/// Uses Mason to generate files from bricks
/// Supports both local bricks and package bricks
class MasonService implements MasonServiceInterface {
  final Logger logger;

  MasonService({Logger? logger}) : logger = logger ?? Logger();

  /// Generate from brick with path resolution
  @override
  Future<void> generateFromBrick({
    required String brickPath,
    required Directory targetDir,
    required Map<String, dynamic> vars,
    bool hooks = true,
    bool overwrite = false,
  }) async {
    final brick = Brick.path(brickPath);
    final generator = await MasonGenerator.fromBrick(brick);
    final target = DirectoryGeneratorTarget(targetDir);
    await generator.generate(
      target,
      vars: vars,
      logger: logger,
      fileConflictResolution: overwrite
          ? FileConflictResolution.overwrite
          : FileConflictResolution.skip,
    );
  }

  /// Generate from package brick with automatic path resolution
  @override
  Future<void> generateFromPackageBrick({
    required String brickName,
    required Directory targetDir,
    required Map<String, dynamic> vars,
    bool hooks = true,
    bool overwrite = false,
  }) async {
    final brickPath = await _findTemplatePath(brickName);
    await generateFromBrick(
      brickPath: brickPath,
      targetDir: targetDir,
      vars: vars,
      hooks: hooks,
      overwrite: overwrite,
    );
  }

  /// Find template path using the same logic as TemplateService
  Future<String> _findTemplatePath(String templateKey) async {
    // First, search for package path through executable file
    final packageRoot = await _findPackageRoot();

    if (packageRoot != null) {
      final templatePath = '$packageRoot/bricks/$templateKey';
      if (Directory(templatePath).existsSync()) {
        return templatePath;
      }
    }

    // Search in current directory
    String templatePath = 'bricks/$templateKey';
    if (Directory(templatePath).existsSync()) {
      return templatePath;
    }

    // Search in parent directory (for testing)
    templatePath = '../gexd/bricks/$templateKey';
    if (Directory(templatePath).existsSync()) {
      return templatePath;
    }

    // Search for package root in hierarchy
    String currentDir = Directory.current.path;
    while (currentDir != '/') {
      final testPath = '$currentDir/bricks/$templateKey';
      if (Directory(testPath).existsSync()) {
        return testPath;
      }
      currentDir = Directory(currentDir).parent.path;
    }

    throw MasonBrickException.brickNotFound(templateKey);

    // throw Exception(
    //   'Template not found. Searched all standard locations for: $templateKey',
    // );
  }

  /// Find package root directory
  Future<String?> _findPackageRoot() async {
    try {
      // Get current executable file path
      final scriptPath = Platform.script.toFilePath();
      final scriptDir = Directory(scriptPath).parent.path;

      // Search for pubspec.yaml in hierarchy
      String currentDir = scriptDir;
      while (currentDir != '/') {
        final pubspecPath = '$currentDir/pubspec.yaml';
        if (File(pubspecPath).existsSync()) {
          // Check that this is gexd directory
          final pubspecContent = await File(pubspecPath).readAsString();
          if (pubspecContent.contains('name: gexd')) {
            return currentDir;
          }
        }
        currentDir = Directory(currentDir).parent.path;
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
