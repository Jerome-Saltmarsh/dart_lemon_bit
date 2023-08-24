
import 'dart:io';


Future createDirectoryIfNotExists(String directoryPath) async {
  final directory = Directory(directoryPath);
  if (await directory.exists()) {
    return;
  }
  await directory.create(recursive: true);
}