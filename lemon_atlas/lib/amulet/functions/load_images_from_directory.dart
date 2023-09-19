import 'dart:async';

import 'package:image/image.dart';
import 'dart:io';

// Future<List<Image>> loadImagesFomDirectory(String directoryName) async {
//
//   final folder = Directory(directoryName);
//   if (!folder.existsSync()){
//     throw Exception('$directoryName does not exist');
//   }
//
//   final images = <Image> [];
//   final children = folder.listSync();
//
//   final completed = Completer();
//
//   var total = 0;
//   var read = 0;
//
//   for (final child in children){
//     if (child is! File) {
//       continue;
//     }
//     total++;
//     child.readAsBytes().then((bytes) {
//       Image? image;
//       try {
//         image = decodePng(bytes);
//       } catch (error) {
//         print(error);
//         return;
//       }
//
//       if (image == null) {
//         throw Exception();
//       }
//       if (image.format != Format.int8){
//         image = image.convert(format: Format.int8);
//       }
//       images.add(image);
//       read++;
//
//       if (read >= total){
//         completed.complete(true);
//       }
//     });
//   }
//   await completed.future;
//   return images;
// }


Future<List<Image>> loadImagesFomDirectory(String directoryName) async {

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
