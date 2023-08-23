

import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:lemon_atlas/functions/build_dst_from_src.dart';
import 'package:lemon_atlas/functions/get_max_height_from_dst.dart';
import 'package:lemon_atlas/functions/get_total_width_from_dst.dart';
import 'package:lemon_atlas/variables/tmp.dart';
import 'package:lemon_atlas/variables/transparent.dart';

import 'build_src_from_atlas.dart';
import 'copy_paste.dart';
import 'create_directory_if_not_exists.dart';

void buildFromAtlas({
  required Image srcImage,
  required int rows,
  required int columns,
  String name = 'atlas',
}) async {
  if (srcImage.format != Format.int8){
    srcImage = srcImage.convert(format: Format.int8);
  }
  final src = buildSrcFromAtlas(rows, columns, srcImage);
  final dst = buildDstFromSrc(src);
  final dstImage = buildImageFrmSrcAndDst(
      src: src,
      dst: dst,
      srcImage: srcImage,
  );
  await saveImageAndDstToFile(dstImage, dst, tmp, name);
}

Future<void> saveImageAndDstToFile(Image dstImage, Uint16List dst, String directory, String name) async {
  final dstImageBytes = encodePng(dstImage);
  await createDirectoryIfNotExists(directory);
  final outputName = '$directory/$name';
  final filePng = File('$outputName.png');
  await filePng.writeAsBytes(dstImageBytes);
  final fileDst = File('$outputName.dst');
  await fileDst.writeAsBytes(dst.buffer.asUint8List());
}

Image buildImageFrmSrcAndDst({
  required Uint16List src,
  required Uint16List dst,
  required Image srcImage,
}) {
  final total = src.length ~/ 4;
  final dstWidth = getTotalWidthFromDst(dst);
  final dstHeight = getMaxHeightFromDst(dst);

  final dstImage = Image(
      width: dstWidth,
      height: dstHeight,
      numChannels: 4,
      backgroundColor: transparent,
  );

  for (var i = 0; i < total; i++){
    var iSrc = i * 4;
    final srcLeft = src[iSrc++];
    final srcTop = src[iSrc++];
    final srcRight = src[iSrc++];
    final srcBottom = src[iSrc++];

    final width = srcRight - srcLeft;
    final height = srcBottom - srcTop;

    var iDst = i * 6;
    final dstX = dst[iDst++];
    final dstY = dst[iDst++];

    copyPaste(
      srcImage: srcImage,
      dstImage: dstImage,
      width: width,
      height: height,
      srcX: srcLeft,
      srcY: srcTop,
      dstX: dstX,
      dstY: dstY,
    );
  }
  return dstImage;
}

