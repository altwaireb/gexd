import 'dart:io';

/// E2ETestSession
///
/// Represents an isolated temporary environment for each E2E test.
/// It holds a temp directory and provides automatic cleanup.
class E2ETestSession {
  final Directory tempDir;
  final bool verbose;

  E2ETestSession._(this.tempDir, this.verbose);

  static Future<E2ETestSession> create({bool verbose = false}) async {
    final dir = await Directory.systemTemp.createTemp('e2e_session_');
    print('🧪 Created E2E session: ${dir.path}');
    return E2ETestSession._(dir, verbose);
  }

  /// Delete all temporary files and folders created during the test
  Future<void> cleanup() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
      print('🧹 Cleaned up E2E session: ${tempDir.path}');
    }
  }

  @override
  String toString() => 'E2ETestSession(tempDir: ${tempDir.path})';
}
