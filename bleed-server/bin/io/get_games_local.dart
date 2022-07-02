
import 'dart:io';

import 'save_directory.dart';

Future<List<String>> getSaveDirectoryFileNames() async {
  final files = await saveDirectoryFileSystemEntities;
  return files
      .map(getFileSystemEntityFileName)
      .map(fileNameRemoveExtension)
      .toList();
}

String getFileSystemEntityFileName(FileSystemEntity entity) =>
    entity.path.split("\\").last;


String fileNameRemoveExtension(String fileName) =>
   fileName.split(".").first;