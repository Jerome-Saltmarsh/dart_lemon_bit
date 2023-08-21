import 'dart:typed_data';

class SpriteMap {
  final String name;
  final int y;
  final Uint8List bytes;

  SpriteMap(this.name, this.y, this.bytes);
}