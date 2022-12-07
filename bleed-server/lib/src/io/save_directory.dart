import 'dart:io';

import 'package:bleed_server/gamestream.dart';


final saveDirectoryPath = '${Directory.current.path}/scenes';
final saveDirectory = Directory(saveDirectoryPath);

Future<List<FileSystemEntity>> get saveDirectoryFileSystemEntities =>
    saveDirectory.list().toList();

Future<List<String>> getSaveDirectoryFileNames() async {
  final files = await saveDirectoryFileSystemEntities;
  return files
      .map(getFileSystemEntityFileName)
      .map(fileNameRemoveExtension)
      .toList();
}
