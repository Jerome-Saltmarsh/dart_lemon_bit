library;

import 'dart:io';

Future<File> writeBytesToFile({
  required String fileName,
  required String directory,
  required List<int> contents
}) async {
  final dir = Directory(directory);
  final exists = await dir.exists();
  if (!exists){
    dir.create();
  }
  final file = File('${dir.path}/$fileName');
  return file.writeAsBytes(contents);
}
