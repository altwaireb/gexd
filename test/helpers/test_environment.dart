import 'dart:io';
import 'package:path/path.dart' as p;

/// Provides a clean, isolated test environment
class TestEnvironment {
  late final Directory tempDir;
  String get path => tempDir.path;

  /// Setup temporary directory for test
  Future<void> setup() async {
    tempDir = await Directory.systemTemp.createTemp('gexd_test_');
  }

  /// Cleanup temporary directory after test
  Future<void> cleanup() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  }

  /// Get file path within temp directory
  String filePath(String relativePath) => p.join(tempDir.path, relativePath);

  /// Get file object within temp directory
  File file(String relativePath) => File(filePath(relativePath));

  /// Create a file with content in temp directory
  Future<File> createFile(String relativePath, String content) async {
    final file = File(filePath(relativePath));
    await file.create(recursive: true);
    await file.writeAsString(content);
    return file;
  }

  /// Check if file exists in temp directory
  bool fileExists(String relativePath) => file(relativePath).existsSync();
}
