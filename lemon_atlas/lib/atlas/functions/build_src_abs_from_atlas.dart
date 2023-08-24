import 'dart:typed_data';

import 'package:image/image.dart';

import 'find_bounds.dart';

Uint16List buildSrcAbsFromAtlas(int rows, int columns, Image atlas) {
  final src = Uint16List(rows * columns * 4);
  final spriteWidth = atlas.width ~/ columns;
  final spriteHeight = atlas.height ~/ rows;
  var i = 0;

  for (var row = 0; row < rows; row++) {
    for (var column = 0; column < columns; column++) {
      final left = column * spriteWidth;
      final top = row * spriteHeight;
      final right = left + spriteWidth;
      final bottom = top + spriteHeight;
      src[i++] = findBoundsLeft(atlas, left: left, top: top, right: right, bottom: bottom);
      src[i++] = findBoundsTop(atlas, left: left, top: top, right: right, bottom: bottom);
      src[i++] = findBoundsRight(atlas, left: left, top: top, right: right, bottom: bottom);
      src[i++] = findBoundsBottom(atlas, left: left, top: top, right: right, bottom: bottom);
    }
  }
  return src;
}
