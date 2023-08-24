
import 'dart:io';
import 'dart:typed_data';

Future<Uint8List> loadFileBytes(String filePath) async {
  final file = File(filePath);
  if (await file.exists()) {
    return await file.readAsBytes();
  }
  throw FileSystemException('File not found: $filePath');
}