
import 'dart:typed_data';
import 'dart:ui';

import 'package:gamestream_flutter/atlases.dart';
import 'package:gamestream_flutter/isometric/render/render_sprites.dart';
import 'package:lemon_engine/canvas.dart';
import 'package:lemon_engine/state/paint.dart';

import 'render_constants.dart';

final _src = Float32List(4);
final _dst = () {
  final bytes = Float32List(4);
  bytes[0] = 1;
  bytes[1] = 0;
  return bytes;
}();
final _colors = Int32List(1);

void renderStandardNode({
  required double srcX,
  required double srcY,
  int color = 1,
}){
  _colors[0] = color;
  _src[0] = srcX;
  // _dst[0] = 1;
  _src[1] = srcY;
  // _dst[1] = 0;
  _src[2] = srcX + spriteWidth;
  _dst[2] = renderNodeDstX - spriteWidthHalf;
  _src[3] = srcY + spriteHeight;
  _dst[3] = renderNodeDstY - spriteHeightThird;
  canvas.drawRawAtlas(Images.blocks, _dst, _src, _colors, BlendMode.dstATop, null, paint);
}

void renderNonStandardNode({
  required double srcX,
  required double srcY,
  int color = 1,
}){
  _colors[0] = color;
  _src[0] = srcX;
  _dst[0] = 1;
  _src[1] = srcY;
  _dst[1] = 0;
  _src[2] = srcX + spriteWidth;
  _dst[2] = renderNodeDstX - spriteWidthHalf;
  _src[3] = srcY + spriteHeight;
  _dst[3] = renderNodeDstY - spriteHeightThird;
  canvas.drawRawAtlas(Images.blocks, _dst, _src, _colors, BlendMode.dstATop, null, paint);
}