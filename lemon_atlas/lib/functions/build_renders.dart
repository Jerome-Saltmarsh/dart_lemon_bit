
import 'dart:io';

import 'package:image/image.dart';
import 'package:lemon_atlas/functions/create_directory_if_not_exists.dart';
import 'package:lemon_atlas/variables/transparent.dart';

import 'build_dst_from_src.dart';
import 'build_src.dart';
import 'copy_paste.dart';
import 'get_max_height_from_dst.dart';
import 'get_total_width_from_dst.dart';

void buildRenders(List<Image> renders, {
  required int rows,
  required int columns,
}) async {
  final src = buildSrc(renders, rows, columns);
  final dst = buildDstFromSrc(src);
  final width = getTotalWidthFromDst(dst);
  final height = getMaxHeightFromDst(dst);

  final dstImage = Image(
    width: width,
    height: height,
    numChannels: 4,
    backgroundColor: transparent,
    format: renders.first.format,
  );

  var iSrc = 0;
  var iDst = 0;

  for (final srcImage in renders){
    final dstX = dst[iDst + 0];
    final dstY = dst[iDst + 1];

    iDst += 6;

    final left = src[iSrc++];
    final top = src[iSrc++];
    final right = src[iSrc++];
    final bottom = src[iSrc++];

    final renderWidth = right - left;
    final renderHeight = bottom - top;

    copyPaste(
      srcImage: srcImage,
      dstImage: dstImage,
      width: renderWidth,
      height: renderHeight,
      srcX: left,
      srcY: top,
      dstX: dstX,
      dstY: dstY,
    );
  }

  final dstImageBytes = encodePng(dstImage);
  const outputName = 'export';
  const directory = 'C:/Users/Jerome/github/bleed/lemon_atlas/assets/tmp';
  await createDirectoryIfNotExists(directory);
  final filePng = File('$directory/$outputName.png');
  await filePng.writeAsBytes(dstImageBytes);
  final fileDst = File('$directory/$outputName.dst');
  await fileDst.writeAsBytes(dst.buffer.asUint8List());
  print('saved "$directory/$outputName"');
}
