#!/usr/bin/env dart
// ignore: dangling_library_doc_comments
/// Documentation Publishing Script
///
/// This script helps copy reviewed documentation from draft location
/// (doc/.version/) to published location (doc/version/) for git tracking.

import 'dart:io';

void main(List<String> arguments) async {
  final version = arguments.isNotEmpty ? arguments.first : '1.x';

  final draftDir = Directory('doc/.$version');
  final publishDir = Directory('doc/$version');

  if (!draftDir.existsSync()) {
    print('❌ Draft directory doc/.$version does not exist');
    print('💡 Run: dart tool/gexd_doc/generate_doc.dart first');
    exit(1);
  }

  print('📋 Publishing documentation from doc/.$version to doc/$version...');

  // Remove existing published directory
  if (publishDir.existsSync()) {
    print('🗑️  Removing existing published directory...');
    await publishDir.delete(recursive: true);
  }

  // Create published directory
  await publishDir.create(recursive: true);

  // Copy all files
  await _copyDirectory(draftDir, publishDir);

  print('✅ Documentation published successfully!');
  print('📁 Published files are now in: doc/$version/');
  print('');
  print('📋 Next steps:');
  print('1. Review the published documentation');
  print('2. Make any final adjustments in doc/$version/');
  print('3. Commit the changes to git');
  print('4. The draft doc/.$version/ will remain hidden from git');
}

Future<void> _copyDirectory(Directory source, Directory destination) async {
  await for (final entity in source.list(recursive: false)) {
    final path = entity.path;
    final name = path.split('/').last;

    if (entity is Directory) {
      final newDir = Directory('${destination.path}/$name');
      await newDir.create();
      await _copyDirectory(entity, newDir);
    } else if (entity is File) {
      final newFile = File('${destination.path}/$name');
      await entity.copy(newFile.path);
      print('📄 Copied: $name');
    }
  }
}
