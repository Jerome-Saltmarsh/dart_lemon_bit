
import 'dart:typed_data';
import 'dart:ui';

import 'package:gamestream_flutter/atlases.dart';
import 'package:gamestream_flutter/isometric/constants/color_pitch_black.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';
import 'package:gamestream_flutter/isometric/render/render_sprites.dart';
import 'package:lemon_engine/engine.dart';

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
  onscreenNodes++;
  _colors[0] = color;
  _src[0] = srcX;
  _src[1] = srcY;
  _src[2] = srcX + spriteWidth;
  _dst[2] = renderNodeDstX - spriteWidthHalf;
  _src[3] = srcY + spriteHeight;
  _dst[3] = renderNodeDstY - spriteHeightThird;
  Engine.canvas.drawRawAtlas(Images.blocks, _dst, _src, _colors, BlendMode.dstATop, null, Engine.paint);
}

void renderStandardNodeShaded({
  required double srcX,
  required double srcY,
}){
  onscreenNodes++;
  _colors[0] = colorShades[nodesShade[renderNodeIndex]];
  _src[0] = srcX;
  _src[1] = srcY;
  _src[2] = srcX + spriteWidth;
  _dst[2] = renderNodeDstX - spriteWidthHalf;
  _src[3] = srcY + spriteHeight;
  _dst[3] = renderNodeDstY - spriteHeightThird;
  Engine.canvas.drawRawAtlas(Images.blocks, _dst, _src, _colors, BlendMode.dstATop, null, Engine.paint);
}

void renderStandardNodeHalfEast({
  required double srcX,
  required double srcY,
  int color = 1,
}){
  onscreenNodes++;
  _colors[0] = color;
  _src[0] = srcX;
  _src[1] = srcY;
  _src[2] = srcX + spriteWidth;
  _dst[2] = renderNodeDstX - spriteWidthHalf + 17;
  _src[3] = srcY + spriteHeight;
  _dst[3] = renderNodeDstY - spriteHeightThird - 17;
  Engine.canvas.drawRawAtlas(Images.blocks, _dst, _src, _colors, BlendMode.dstATop, null, Engine.paint);
}

void renderStandardNodeHalfNorth({
  required double srcX,
  required double srcY,
  int color = 1,
}){
  onscreenNodes++;
  _colors[0] = color;
  _src[0] = srcX;
  _src[1] = srcY;
  _src[2] = srcX + spriteWidth;
  _dst[2] = renderNodeDstX - spriteWidthHalf - 17;
  _src[3] = srcY + spriteHeight;
  _dst[3] = renderNodeDstY - spriteHeightThird - 17;
  Engine.canvas.drawRawAtlas(Images.blocks, _dst, _src, _colors, BlendMode.dstATop, null, Engine.paint);
}


void renderAdvanced({
  required double dstX,
  required double dstY,
  required double srcX,
  required double srcY,
  required double width,
  required double height,
  double anchorX = 0.5,
  double anchorY = 0.5,
  int color = 1,
}){
  onscreenNodes++;
  _colors[0] = color;
  _src[0] = srcX;
  _dst[0] = 1;
  _src[1] = srcY;
  _dst[1] = 0;
  _src[2] = srcX + width;
  _dst[2] = dstX - width * anchorX;
  _src[3] = srcY + spriteHeight;
  _dst[3] = dstY - height * anchorY;
  Engine.canvas.drawRawAtlas(Images.blocks, _dst, _src, _colors, BlendMode.dstATop, null, Engine.paint);
}