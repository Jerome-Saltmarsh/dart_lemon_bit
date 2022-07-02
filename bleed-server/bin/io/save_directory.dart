import 'dart:io';

final saveDirectoryPath = '${Directory.current.path}/saved_scenes';
final saveDirectory = Directory(saveDirectoryPath);

Future<List<FileSystemEntity>> get saveDirectoryFileSystemEntities =>
    saveDirectory.list().toList();