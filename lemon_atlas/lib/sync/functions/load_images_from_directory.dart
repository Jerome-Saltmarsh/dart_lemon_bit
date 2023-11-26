import 'package:image/image.dart';
import 'dart:io';


List<Image> loadImagesFomDirectory(String directoryName) {

  final folder = Directory(directoryName);
  if (!folder.existsSync()){
    throw Exception('$directoryName does not exist');
  }

  final images = <Image> [];
  final children = folder.listSync();

  for (final child in children) {
    if (child is! File) {
      continue;
    }
    final bytes = child.readAsBytesSync();
    Image? image = decodePng(bytes);

    if (image == null) {
      throw Exception();
    }
    if (image.format != Format.int8) {
      image = image.convert(format: Format.int8);
    }
    images.add(image);
  }
  return images;
}
