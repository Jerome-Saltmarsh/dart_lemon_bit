

import 'dart:typed_data';

import 'package:image/image.dart';

import 'find_bounds.dart';

void buildFromAtlas({
  required Image atlas,
  required int rows,
  required int columns,
}){
  final bounds = Uint16List(rows * columns * 4);
  var boundsI = 0;

  final spriteWidth = atlas.width ~/ columns;
  final spriteHeight = atlas.height ~/ rows;

  for (var row = 0; row < rows; row++){
    for (var column = 0; column < columns; column++){
      final x = column * spriteWidth;
      final y = row * spriteHeight;
      bounds[boundsI++] = findBoundsLeft(atlas, x: x, y: y, width: spriteWidth, height: spriteHeight);
      bounds[boundsI++] = findBoundsLeft(atlas, x: x, y: y, width: spriteWidth, height: spriteHeight);
      bounds[boundsI++] = findBoundsLeft(atlas, x: x, y: y, width: spriteWidth, height: spriteHeight);
      bounds[boundsI++] = findBoundsLeft(atlas, x: x, y: y, width: spriteWidth, height: spriteHeight);
    }
  }
}