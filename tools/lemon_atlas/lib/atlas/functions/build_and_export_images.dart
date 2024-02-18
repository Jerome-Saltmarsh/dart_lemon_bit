//
// import 'dart:io';
//
// import 'package:image/image.dart';
// import 'package:lemon_atlas/io/create_directory_if_not_exists.dart';
// import 'package:lemon_atlas/atlas/variables/transparent.dart';
//
// import 'build_dst_from_src.dart';
// import 'build_src.dart';
// import 'copy_paste.dart';
// import 'get_max_bottom_from_dst.dart';
// import 'get_max_right_from_dst.dart';
//
// void buildAndExportImages(List<Image> images, {
//   required int rows,
//   required int columns,
//   required String directory,
//   required String name,
// }) async {
//   final srcAbs = buildSrcAbsFromImages(images: images, rows: 8, columns: 8);
//   final dst = buildDstFromSrcAbs(srcAbs);
//   final width = getMaxRightFromDst(dst);
//   final height = getMaxBottomFromDst(dst);
//
//   final dstImage = Image(
//     width: width,
//     height: height,
//     numChannels: 4,
//     backgroundColor: transparent,
//     format: images.first.format,
//   );
//
//   var i = 0;
//
//   for (final srcImage in images){
//
//     final srcLeft = srcAbs[i + 0];
//     final srcTop = srcAbs[i + 1];
//     final srcRight = srcAbs[i + 2];
//     final srcBottom = srcAbs[i + 3];
//
//     final dstLeft = dst[i + 0];
//     final dstTop = dst[i + 1];
//
//     final renderWidth = srcRight - srcLeft;
//     final renderHeight = srcBottom - srcTop;
//
//     copyPaste(
//       srcImage: srcImage,
//       dstImage: dstImage,
//       width: renderWidth,
//       height: renderHeight,
//       srcX: srcLeft,
//       srcY: srcTop,
//       dstX: dstLeft,
//       dstY: dstTop,
//     );
//
//     i += 4;
//   }
//
//   final dstImageBytes = encodePng(dstImage);
//   await createDirectoryIfNotExists(directory);
//   final filePng = File('$directory/$name.png');
//   await filePng.writeAsBytes(dstImageBytes);
//   final fileDst = File('$directory/$name.dst');
//   await fileDst.writeAsBytes(dst.buffer.asUint8List());
// }
