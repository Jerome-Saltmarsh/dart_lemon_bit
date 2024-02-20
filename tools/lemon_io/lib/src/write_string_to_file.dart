import 'dart:io';

Future<File> writeStringToFile({
  required String fileName,
  required String directory,
  required String contents
}) async {
  final dir = Directory(directory);
  final exists = await dir.exists();
  if (!exists){
    dir.create();
  }
  final file = File('${dir.path}/$fileName');
  return file.writeAsString(contents);
}