import 'dart:io';

import 'package:gexd/gexd.dart';

/// Mixin to provide target directory functionality
mixin HasTargetDirectory {
  Directory get targetDirectory => Directory(Directory.current.path);

  /// Get or create a subdirectory within the target directory
  Directory subDir(String relativePath) {
    final dir = Directory('${targetDirectory.path}/$relativePath');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }
}

/// Mixin to provide project data functionality
mixin HasProjectData {
  Future<ProjectData?> get projectData async => await ProjectHelpers.getdata();

  Future<ProjectTemplate?> get projectTemplate async =>
      (await projectData)?.template;

  Future<String?> get projectName async => (await projectData)?.name;

  Future<bool> get isInGexdProject async =>
      await ProjectHelpers.isInGexdProject();
}
