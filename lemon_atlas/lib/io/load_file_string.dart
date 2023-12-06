
import 'dart:io';

Future<String> loadFileString(String filePath) async {
  final file = File(filePath);
  if (await file.exists()) {
    return await file.readAsString();
  }
  throw FileSystemException('File not found: $filePath');
}