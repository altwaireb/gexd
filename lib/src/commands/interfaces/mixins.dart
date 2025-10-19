import 'dart:io';

import 'package:gexd/gexd.dart';

mixin HasTargetDirectory {
  Directory get targetDirectory => Directory(Directory.current.path);

  /// إنشاء مجلد فرعي داخل current directory
  Directory subDir(String relativePath) {
    final dir = Directory('${targetDirectory.path}/$relativePath');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }
}

mixin HasProjectData {
  Future<ProjectData?> get projectData async => await ProjectHelpers.getdata();

  Future<ProjectTemplate?> get projectTemplate async =>
      (await projectData)?.template;

  Future<String?> get projectName async => (await projectData)?.name;

  Future<bool> get isInGexdProject async =>
      await ProjectHelpers.isInGexdProject();
}
