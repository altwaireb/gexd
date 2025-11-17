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

  /// Generate from package brick using package-relative path
  @override
  Future<void> generateFromPackageBrick({
    required String brickName,
    required Directory targetDir,
    required Map<String, dynamic> vars,
    bool hooks = true,
    bool overwrite = false,
  }) async {
    try {
      // First try the new assets/bricks location (for published packages)
      var brickPath = 'assets/bricks/$brickName';
      if (!Directory(brickPath).existsSync()) {
        // Fallback to package-relative path
        brickPath = await _findPackageBrickPath(brickName);
      }

      await generateFromBrick(
        brickPath: brickPath,
        targetDir: targetDir,
        vars: vars,
        hooks: hooks,
        overwrite: overwrite,
      );
    } catch (e) {
      // Final fallback to legacy path resolution
      final brickPath = await _findTemplatePath(brickName);
      await generateFromBrick(
        brickPath: brickPath,
        targetDir: targetDir,
        vars: vars,
        hooks: hooks,
        overwrite: overwrite,
      );
    }
  }

  /// Find brick path within the package
  Future<String> _findPackageBrickPath(String brickName) async {
    // Try to locate the package through the script path
    final packageRoot = await _findPackageRoot();

    if (packageRoot != null) {
      // Check assets/bricks first (published package location)
      final assetsPath = '$packageRoot/assets/bricks/$brickName';
      if (Directory(assetsPath).existsSync()) {
        return assetsPath;
      }

      // Check new assets/bricks location (development)
      final newPath = '$packageRoot/assets/bricks/$brickName';
      if (Directory(newPath).existsSync()) {
        return newPath;
      }

      // Check old lib/src/bricks location as fallback
      final oldPath = '$packageRoot/lib/src/bricks/$brickName';
      if (Directory(oldPath).existsSync()) {
        return oldPath;
      }

      // Check legacy bricks/ location
      final legacyPath = '$packageRoot/bricks/$brickName';
      if (Directory(legacyPath).existsSync()) {
        return legacyPath;
      }
    }

    // Local development paths
    if (Directory('assets/bricks/$brickName').existsSync()) {
      return 'assets/bricks/$brickName';
    }

    if (Directory('assets/bricks/$brickName').existsSync()) {
      return 'assets/bricks/$brickName';
    }

    if (Directory('lib/src/bricks/$brickName').existsSync()) {
      return 'lib/src/bricks/$brickName';
    }

    if (Directory('bricks/$brickName').existsSync()) {
      return 'bricks/$brickName';
    }

    throw MasonBrickException.brickNotFound(brickName);
  }

  /// Find template path using the same logic as TemplateService
  Future<String> _findTemplatePath(String templateKey) async {
    // First, search for package path through executable file
    final packageRoot = await _findPackageRoot();

    if (packageRoot != null) {
      // Check assets/bricks first
      final toolPath = '$packageRoot/assets/bricks/$templateKey';
      if (Directory(toolPath).existsSync()) {
        return toolPath;
      }

      // Check lib/src/bricks as fallback
      final libPath = '$packageRoot/lib/src/bricks/$templateKey';
      if (Directory(libPath).existsSync()) {
        return libPath;
      }

      // Check legacy bricks location
      final legacyPath = '$packageRoot/bricks/$templateKey';
      if (Directory(legacyPath).existsSync()) {
        return legacyPath;
      }
    }

    // Search in current directory
    String templatePath = 'assets/bricks/$templateKey';
    if (Directory(templatePath).existsSync()) {
      return templatePath;
    }

    templatePath = 'lib/src/bricks/$templateKey';
    if (Directory(templatePath).existsSync()) {
      return templatePath;
    }

    templatePath = 'bricks/$templateKey';
    if (Directory(templatePath).existsSync()) {
      return templatePath;
    }

    // Search in parent directory (for testing)
    templatePath = '../gexd/assets/bricks/$templateKey';
    if (Directory(templatePath).existsSync()) {
      return templatePath;
    }

    templatePath = '../gexd/bricks/$templateKey';
    if (Directory(templatePath).existsSync()) {
      return templatePath;
    }

    // Search for package root in hierarchy
    String currentDir = Directory.current.path;
    while (currentDir != '/') {
      final testPath = '$currentDir/assets/bricks/$templateKey';
      if (Directory(testPath).existsSync()) {
        return testPath;
      }
      currentDir = Directory(currentDir).parent.path;
    }

    throw MasonBrickException.brickNotFound(templateKey);
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
