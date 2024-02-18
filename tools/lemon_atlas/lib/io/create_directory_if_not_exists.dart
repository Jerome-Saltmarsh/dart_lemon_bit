
import 'dart:io';


void createDirectoryIfNotExists(String directoryPath) {
  final directory = Directory(directoryPath);
  if (directory.existsSync()) {
    return;
  }
  directory.createSync(recursive: true);
}