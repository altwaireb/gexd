import 'dart:io';
import 'package:gexd/src/services/interfaces/mason_service_interface.dart';

class MasonServiceMock implements MasonServiceInterface {
  final List<String> _generatedBricks = [];
  bool _shouldSucceed = true;

  /// Configure whether operations should succeed or fail
  void setShouldSucceed(bool succeed) {
    _shouldSucceed = succeed;
  }

  /// Get list of bricks that were "generated" during testing
  List<String> get generatedBricks => List.unmodifiable(_generatedBricks);

  /// Clear the list of generated bricks
  void clearGeneratedBricks() {
    _generatedBricks.clear();
  }

  @override
  Future<void> generateFromBrick({
    required String brickPath,
    required Directory targetDir,
    required Map<String, dynamic> vars,
    bool hooks = true,
    bool overwrite = false,
  }) async {
    if (!_shouldSucceed) {
      throw Exception('Mock Mason brick generation failed');
    }

    // Simulate brick generation
    await Future.delayed(const Duration(milliseconds: 50));

    _generatedBricks.add('$brickPath:${targetDir.path}');

    print('🧪 Mock: Generated brick from $brickPath to ${targetDir.path}');
    print('🧪 Mock: Variables: ${vars.keys.join(', ')}');
    print('🧪 Mock: Hooks: $hooks, Overwrite: $overwrite');
  }

  @override
  Future<void> generateFromPackageBrick({
    required String brickName,
    required Directory targetDir,
    required Map<String, dynamic> vars,
    bool hooks = true,
    bool overwrite = false,
  }) async {
    if (!_shouldSucceed) {
      throw Exception('Mock Mason package brick generation failed');
    }

    // Simulate package brick generation
    await Future.delayed(const Duration(milliseconds: 50));

    _generatedBricks.add('package:$brickName:${targetDir.path}');

    print('🧪 Mock: Generated package brick $brickName to ${targetDir.path}');
    print('🧪 Mock: Variables: ${vars.keys.join(', ')}');
    print('🧪 Mock: Hooks: $hooks, Overwrite: $overwrite');
  }

  // Additional helper methods for testing (not part of interface)

  /// Check if a brick was generated from a specific path
  bool wasBrickGeneratedFrom(String brickPath) {
    return _generatedBricks.any((entry) => entry.startsWith('$brickPath:'));
  }

  /// Check if a package brick was generated
  bool wasPackageBrickGenerated(String brickName) {
    return _generatedBricks.any(
      (entry) => entry.startsWith('package:$brickName:'),
    );
  }

  /// Get generation count for a specific brick path
  int getBrickGenerationCount(String brickPath) {
    return _generatedBricks
        .where((entry) => entry.startsWith('$brickPath:'))
        .length;
  }

  /// Get generation count for a specific package brick
  int getPackageBrickGenerationCount(String brickName) {
    return _generatedBricks
        .where((entry) => entry.startsWith('package:$brickName:'))
        .length;
  }
}
