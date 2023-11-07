import 'package:flutter/material.dart';
import 'package:gamestream_flutter/packages/sprite/render_sprite.dart';
import 'package:lemon_sprite/lib.dart';

void renderCanvasSprite({
  required Canvas canvas,
  required Sprite sprite,
  required int row,
  required int column,
  required BlendMode blendMode,
  required int color,
  double scale = 1.0,
}) => spriteExternal(
    canvas: canvas,
    sprite: sprite,
    frame: sprite.getFrame(row: row, column: column),
    color: color,
    scale: scale,
    dstX: 0,
    dstY: 0,
    blendMode: blendMode,
  );
