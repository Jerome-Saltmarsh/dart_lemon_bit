

import 'package:image/image.dart';
import 'package:lemon_atlas/functions/build_dst_from_src.dart';
import 'package:lemon_atlas/functions/save_image_and_dst_to_file.dart';
import 'package:lemon_atlas/variables/tmp.dart';

import 'build_image_from_src_and_dst.dart';
import 'build_src_from_atlas.dart';

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
  final dstImage = buildImageFromSrcAndDst(
      src: src,
      dst: dst,
      srcImage: srcImage,
  );
  await saveImageAndDstToFile(dstImage, dst, tmp, name);
}



