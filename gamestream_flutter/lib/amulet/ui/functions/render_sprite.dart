import 'package:flutter/material.dart';
import 'package:gamestream_flutter/packages/sprite/render_sprite.dart';
import 'package:lemon_sprite/lib.dart';

void renderSprite({
  required Canvas canvas,
  required Sprite? sprite,
  required int row,
  required int column,
  int? color = null,
  double scale = 1.0,
}) {
  if (sprite == null){
    return;
  }

  final blendMode = color == null ? BlendMode.dstATop : BlendMode.modulate;
  final frame = sprite.getFrame(row: row, column: column);

  spriteExternal(
    canvas: canvas,
    sprite: sprite,
    frame: frame,
    color: 0,
    scale: scale,
    dstX: 0,
    dstY: 0,
    blendMode: blendMode,
  );

  if (color != null){
    spriteExternal(
      canvas: canvas,
      sprite: sprite,
      frame: sprite.getFrame(row: row, column: column),
      color: color,
      scale: scale,
      dstX: 0,
      dstY: 0,
      blendMode: blendMode,
    );
  }
}
