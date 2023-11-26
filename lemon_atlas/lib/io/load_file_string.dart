
import 'dart:io';
import 'dart:typed_data';

Future<String> loadFileString(String filePath) async {
  final file = File(filePath);
  if (await file.exists()) {
    return await file.readAsString();
  }
  throw FileSystemException('File not found: $filePath');
}