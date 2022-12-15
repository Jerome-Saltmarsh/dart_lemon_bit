import 'dart:io';

import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/system.dart';

final Scene_Directory_Path =  isLocalMachine ? '${Directory.current.path}/scenes' : '/app/bin/scenes';
final Scene_Directory = Directory(Scene_Directory_Path);

Future<List<FileSystemEntity>> get saveDirectoryFileSystemEntities =>
    Scene_Directory.list().toList();

Future<List<String>> getSaveDirectoryFileNames() async {
  final files = await saveDirectoryFileSystemEntities;
  return files
      .map(getFileSystemEntityFileName)
      .map(fileNameRemoveExtension)
      .toList();
}
