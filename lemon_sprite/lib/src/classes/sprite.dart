
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:lemon_sprite/lib.dart';

class Sprite {
  final Image image;
  final Float32List src;
  final Float32List dst;
  final int rows;
  final int columns;
  final int mode;
  final double srcWidth;
  final double srcHeight;
  final int atlasX;
  final int atlasY;

  Sprite({
    required this.image,
    required this.src,
    required this.dst,
    required this.rows,
    required this.columns,
    required this.mode,
    required this.srcWidth,
    required this.srcHeight,
    this.atlasX = 0,
    this.atlasY = 0,
  });

  int getFramePercentage(int row, double actionComplete) {
    final columns = this.columns; // cache on cpu
    switch (mode){
      case AnimationMode.single:
        return (row * columns) + min((columns * actionComplete).round(), columns - 1);
      case AnimationMode.bounce:
        if (actionComplete < 0.5){
          final p = actionComplete / 0.5;
          return (row * columns) + min((columns * p).round(), columns - 1);
        }
        final p = 1.0 - ((actionComplete - 0.5) / 0.5);
        return (row * columns) + min((columns * p).round(), columns - 1);

      case AnimationMode.loop:
        return (row * columns) + min((columns * actionComplete).round(), columns - 1);
      default:
        throw Exception();
    }
  }

  int getFrame({required int row, required int column}){
    final columns = this.columns; // cache on cpu
    switch (mode) {
      case AnimationMode.single:
        return (row * columns) + (min(column, columns - 1));
      case AnimationMode.loop:
        return (row * columns) + (column % columns);
      case AnimationMode.bounce:
        if (column ~/ columns % 2 == 0){
          return (row * columns) + column % columns;
        }
        return (row * columns) + ((columns - 1) - (column % columns));
      default:
        throw Exception();
    }
  }
}
