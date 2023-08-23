import 'dart:typed_data';

import 'package:image/image.dart';

import 'find_bounds.dart';

Uint16List buildSrcFromAtlas(int rows, int columns, Image atlas) {
  final src = Uint16List(rows * columns * 4);
  var srcI = 0;

  final spriteWidth = atlas.width ~/ columns;
  final spriteHeight = atlas.height ~/ rows;

  for (var row = 0; row < rows; row++){
    for (var column = 0; column < columns; column++){
      final left = column * spriteWidth;
      final top = row * spriteHeight;
      final right = left + spriteWidth;
      final bottom = top + spriteHeight;
      src[srcI++] = findBoundsLeft(atlas, left: left, top: top, right: right, bottom: bottom);
      src[srcI++] = findBoundsTop(atlas, left: left, top: top, right: right, bottom: bottom);
      src[srcI++] = findBoundsRight(atlas, left: left, top: top, right: right, bottom: bottom);
      src[srcI++] = findBoundsBottom(atlas, left: left, top: top, right: right, bottom: bottom);
    }
  }
  return src;
}
