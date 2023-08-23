import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart';

import 'create_directory_if_not_exists.dart';

Future<void> saveImageAndDstToFile(Image dstImage, Uint16List dst, String directory, String name) async {
  final dstImageBytes = encodePng(dstImage);
  await createDirectoryIfNotExists(directory);
  final outputName = '$directory/$name';
  final filePng = File('$outputName.png');
  await filePng.writeAsBytes(dstImageBytes);
  final fileDst = File('$outputName.dst');
  await fileDst.writeAsBytes(dst.buffer.asUint8List());
}
