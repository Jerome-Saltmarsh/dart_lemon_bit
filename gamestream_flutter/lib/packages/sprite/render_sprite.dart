

import 'dart:ui';

import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_sprite/lib.dart';

void spriteExternal({
  required Canvas canvas,
  required Sprite sprite,
  required int frame,
  required int color,
  required double scale,
  required double dstX,
  required double dstY,
  double anchorX = 0.5,
  double anchorY = 0.5,
}) {
  if (sprite.src.isEmpty)
    return;

  final spriteSrc = sprite.src;
  final spriteDst = sprite.dst;
  final srcWidth = sprite.srcWidth;
  final srcHeight = sprite.srcHeight;
  final atlasX = sprite.atlasX;
  final atlasY = sprite.atlasY;
  final f = frame * 4;
  final dstLeft = spriteSrc[f + 0];
  final dstTop = spriteSrc[f + 1];
  final srcLeft = spriteDst[f + 0] + atlasX;
  final srcTop = spriteDst[f + 1] + atlasY;
  final srcRight = spriteDst[f + 2] + atlasX;
  final srcBottom = spriteDst[f + 3] + atlasY;

  renderCanvas(
    canvas: canvas,
    image: sprite.image,
    color: color,
    srcX: srcLeft,
    srcY: srcTop,
    srcWidth: srcRight - srcLeft,
    srcHeight: srcBottom - srcTop,
    scale: scale,
    dstX: dstX - (srcWidth * anchorX * scale) + (dstLeft * scale),
    dstY: dstY - (srcHeight * anchorY * scale) + (dstTop * scale),
  );
}