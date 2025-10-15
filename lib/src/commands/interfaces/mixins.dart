import 'dart:io';

import 'package:args/args.dart';
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

mixin HasArgResults {
  ArgResults get argResults;
}

mixin HasName on HasArgResults {
  String? get nameFromArgs =>
      argResults.rest.isNotEmpty ? argResults.rest.first : null;
}

mixin HasInteractiveMode on HasName {
  bool get isInteractiveMode => nameFromArgs == null;
}

mixin HasProjectData {
  Future<ProjectData?> get projectData async => await ProjectHelpers.getdata();

  Future<ProjectTemplate?> get projectTemplate async =>
      (await projectData)?.template;

  Future<String?> get projectName async => (await projectData)?.name;

  Future<bool> get isInGexdProject async =>
      await ProjectHelpers.isInGexdProject();
}
