import 'dart:io';

import '../lemon_io/filename_remove_extension.dart';
import '../lemon_io/get_file_system_entity_filename.dart';

final saveDirectoryPath = '${Directory.current.path}/saved_scenes';
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
