import 'dart:typed_data';

import 'package:image/image.dart';

class Sprite {
  final int spriteWidth;
  final int spriteHeight;
  final int rows;
  final int columns;
  final Image image;
  final Uint16List src;
  final Uint16List dst;

  Sprite({
    required this.spriteWidth,
    required this.spriteHeight,
    required this.rows,
    required this.columns,
    required this.image,
    required this.src,
    required this.dst,
  });
}
