import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_characters.dart';

class Sprite {
  final Image image;
  final Float32List values;
  final int width;
  final int height;
  final int rows;
  final int columns;
  final double x;
  final double y;
  final int mode;
  late final bool isEmpty;

  factory Sprite.fromBytes(Uint8List bytes, {
    required Image image,
    double x = 0,
    required num y,
    required int mode,
  }) =>
      Sprite.fromUint16List(
          bytes.buffer.asUint16List(),
          image: image,
          x: x,
          y: y,
          mode: mode,
      );

  factory Sprite.fromUint16List(Uint16List uint16List, {
    required Image image,
    double x = 0,
    required num y,
    required int mode,
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
          mode: mode,
      );

  Sprite({
    required this.image,
    required this.values,
    required this.width,
    required this.height,
    required this.rows,
    required this.columns,
    required this.y,
    required this.mode,
    this.x = 0,
  }) {
    isEmpty = values.isEmpty;
  }

  int getFrame({required int row, required int column}){
    final columns = this.columns; // cache on cpu
    switch (mode){
      case AnimationMode.Single:
        return (row * columns) + (min(column, columns - 1));
      case AnimationMode.Loop:
        return (row * columns) + (column % columns);
      case AnimationMode.Bounce:
        if (column ~/ columns % 2 == 0){
          return (row * columns) + column % columns;
        }
        return (row * columns) + ((columns - 1) - (column % columns));
      default:
        throw Exception();
    }
  }
}