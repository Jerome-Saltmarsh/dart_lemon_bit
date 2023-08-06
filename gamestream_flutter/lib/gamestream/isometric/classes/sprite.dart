import 'dart:typed_data';
import 'dart:ui';

class Sprite {
  final Image image;
  final Float32List values;
  final int width;
  final int height;
  final int rows;
  final int columns;
  final double y;

  factory Sprite.fromBytes(Uint8List bytes, {
    required Image image,
    required double y,
  }) =>
      Sprite.fromUint16List(bytes.buffer.asUint16List(), image: image, y: y);

  factory Sprite.fromUint16List(Uint16List uint16List, {
    required Image image,
    required double y,
  }) =>
      Sprite(
          image: image,
          width: uint16List[0],
          height: uint16List[1],
          rows: uint16List[2],
          columns: uint16List[3],
          values: Float32List.fromList(
              uint16List.sublist(4, uint16List.length)
                  .map((e) => e.toDouble())
                  .toList(growable: false)
          ),
          y: y,
      );

  Sprite({
    required this.image,
    required this.values,
    required this.width,
    required this.height,
    required this.rows,
    required this.columns,
    required this.y,
  });
}