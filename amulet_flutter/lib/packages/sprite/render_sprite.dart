

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
  required BlendMode blendMode,
  double anchorX = 0.5,
  double anchorY = 0.5,
}) {
  if (sprite.src.isEmpty)
    return;

  final spriteSrc = sprite.src;
  final spriteDst = sprite.dst;
  final f = frame * 4;
  final dstLeft = spriteSrc[f + 0];
  final dstTop = spriteSrc[f + 1];
  final srcLeft = spriteDst[f + 0];
  final srcTop = spriteDst[f + 1];
  final srcRight = spriteDst[f + 2];
  final srcBottom = spriteDst[f + 3];

  renderCanvasAbs(
    canvas: canvas,
    image: sprite.image,
    blendMode: blendMode,
    color: color,
    srcLeft: srcLeft,
    srcTop: srcTop,
    srcRight: srcRight,
    srcBottom: srcBottom,
    scale: scale,
    dstX: dstX - (sprite.srcWidth * anchorX * scale) + (dstLeft * scale),
    dstY: dstY - (sprite.srcHeight * anchorY * scale) + (dstTop * scale),
  );
}