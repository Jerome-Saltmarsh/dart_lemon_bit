
import 'dart:typed_data';

import 'package:image/image.dart';

import 'find_bounds.dart';

class SpriteBounds {

  static const boundStackSize = 10000;

  var boundStackIndex = 0;
  var spriteWidth = 0;
  var spriteHeight = 0;

  final boundStackLeft = Uint16List(boundStackSize);
  final boundStackRight = Uint16List(boundStackSize);
  final boundStackTop = Uint16List(boundStackSize);
  final boundStackBottom = Uint16List(boundStackSize);

  void bind(Image srcImage, int rows, int columns) {
    boundStackIndex = 0;

    final width = srcImage.width;
    final height = srcImage.height;

    spriteWidth = width ~/ columns;
    spriteHeight = height ~/ rows;

    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {

        final left = findBoundsLeft(
          image: srcImage,
          srcX: column * spriteWidth,
          srcY: row * spriteHeight,
          width: spriteWidth,
          height: spriteHeight,
        );
        if (left == -1) {
          continue;
        }

        final right = findBoundsRight(
          image: srcImage,
          srcX: column * spriteWidth,
          srcY: row * spriteHeight,
          width: spriteWidth,
          height: spriteHeight,
        );

        final top = findBoundsTop(
          image: srcImage,
          srcX: column * spriteWidth,
          srcY: row * spriteHeight,
          width: spriteWidth,
          height: spriteHeight,
        );

        final bottom = findBoundsBottom(
          image: srcImage,
          srcX: column * spriteWidth,
          srcY: row * spriteHeight,
          width: spriteWidth,
          height: spriteHeight,
        );

        boundStackLeft[boundStackIndex] = left;
        boundStackRight[boundStackIndex] = right;
        boundStackTop[boundStackIndex] = top;
        boundStackBottom[boundStackIndex] = bottom;
        boundStackIndex++;
      }
    }
  }
}