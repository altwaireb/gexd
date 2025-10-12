import 'dart:io';

abstract class MasonServiceInterface {
  Future<void> generateFromBrick({
    required String brickPath,
    required Directory targetDir,
    required Map<String, dynamic> vars,
    bool hooks = true,
    bool overwrite = false,
  });

  Future<void> generateFromPackageBrick({
    required String brickName,
    required Directory targetDir,
    required Map<String, dynamic> vars,
    bool hooks = true,
    bool overwrite = false,
  });
}
