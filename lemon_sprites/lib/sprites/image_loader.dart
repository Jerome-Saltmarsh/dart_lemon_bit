
import 'dart:isolate';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart';


Future<Image?> isolatedLoadImageFromFile(PlatformFile file) async {
  final bytes = file.bytes;
  if (bytes == null) {
    throw Exception('Image bytes are null');
  }

  return await Isolate.run((){
    return decodePng(bytes);
  });
}