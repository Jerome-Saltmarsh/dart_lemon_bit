import 'dart:io';

import 'package:image/image.dart';
import 'package:lemon_atlas/atlas/functions/build_dst_from_src.dart';
import 'package:lemon_atlas/atlas/functions/build_src.dart';
import 'package:lemon_atlas/atlas/functions/copy_paste.dart';
import 'package:lemon_atlas/io/create_directory_if_not_exists.dart';
import 'package:lemon_atlas/atlas/functions/get_max_bottom_from_dst.dart';
import 'package:lemon_atlas/atlas/functions/get_max_right_from_dst.dart';
import 'package:lemon_atlas/atlas/variables/transparent.dart';

import 'enums/character_state.dart';
import 'get_images_fallen.dart';


void buildCharacterFallen(CharacterState state) async {
  final renders = await getImagesFallen(state);
  final src = buildSrcAbs(renders, 8, 8);
  final dst = buildDstFromSrcAbs(src);
  final width = getMaxRightFromDst(dst);
  final height = getMaxBottomFromDst(dst);

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
  final outputName = state.name;
  final directory = 'C:/Users/Jerome/github/bleed/lemon_atlas/assets/sprites_2/fallen/${state.name}';
  await createDirectoryIfNotExists(directory);
  final filePng = File('$directory/$outputName.png');
  await filePng.writeAsBytes(dstImageBytes);
  final fileDst = File('$directory/$outputName.dst');
  await fileDst.writeAsBytes(dst.buffer.asUint8List());
}
