import 'dart:io';

/// Interface for MasonService
/// Defines methods for generating files
/// from Mason bricks and package bricks
abstract class MasonServiceInterface {
  /// Generates files from a local Mason brick
  /// [brickPath]: Path to the local brick
  /// [targetDir]: Directory where files will be generated
  /// [vars]: Variables to pass to the brick
  /// [hooks]: Whether to run hooks during generation
  /// [overwrite]: Whether to overwrite existing files
  Future<void> generateFromBrick({
    required String brickPath,
    required Directory targetDir,
    required Map<String, dynamic> vars,
    bool hooks = true,
    bool overwrite = false,
  });

  /// Generates files from a Mason package brick
  /// [brickName]: Name of the package brick
  /// [targetDir]: Directory where files will be generated
  /// [vars]: Variables to pass to the brick
  /// [hooks]: Whether to run hooks during generation
  /// [overwrite]: Whether to overwrite existing files
  Future<void> generateFromPackageBrick({
    required String brickName,
    required Directory targetDir,
    required Map<String, dynamic> vars,
    bool hooks = true,
    bool overwrite = false,
  });
}
