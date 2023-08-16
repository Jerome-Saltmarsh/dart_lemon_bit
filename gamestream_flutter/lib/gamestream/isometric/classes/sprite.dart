import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

class Sprite {
  final Image image;
  final Float32List values;
  final int width;
  final int height;
  final int rows;
  final int columns;
  final double x;
  final double y;
  final bool loop;
  late final bool isEmpty;

  factory Sprite.fromBytes(Uint8List bytes, {
    required Image image,
    double x = 0,
    required num y,
    required bool loop,
  }) =>
      Sprite.fromUint16List(
          bytes.buffer.asUint16List(),
          image: image,
          x: x,
          y: y,
          loop: loop,
      );

  factory Sprite.fromUint16List(Uint16List uint16List, {
    required Image image,
    double x = 0,
    required num y,
    required bool loop,
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
          x: x,
          y: y.toDouble(),
          loop: loop,
      );

  Sprite({
    required this.image,
    required this.values,
    required this.width,
    required this.height,
    required this.rows,
    required this.columns,
    required this.y,
    required this.loop,
    this.x = 0,
  }) {
    isEmpty = values.isEmpty;
  }

  int getFrame({required int row, required int column}){
    assert (row >= 0 && row <= rows);
    return (row * columns) + (loop
        ? (column % columns)
        : (min(column, columns - 1)));
  }

}