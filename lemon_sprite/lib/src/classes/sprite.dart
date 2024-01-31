
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
  final double srcWidth;
  final double srcHeight;

  Sprite({
    required this.image,
    required this.src,
    required this.dst,
    required this.rows,
    required this.columns,
    required this.srcWidth,
    required this.srcHeight,
  });

  int getFramePercentage(int row, double actionComplete, int mode) {
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

  int getFrame({required int row, required int column, required int mode}){
    final columns = this.columns; // cache on cpu

    if (columns <= 0){
      return 0;
    }

    switch (mode) {
      case AnimationMode.single:
        return (row * columns) + (min(column, columns - 1));
      case AnimationMode.loop:
        return (row * columns) + (column % columns);
      case AnimationMode.bounce:
        if ((column ~/ columns) % 2 == 0){
          return (row * columns) + column % columns;
        }
        return (row * columns) + ((columns - 1) - (column % columns));
      default:
        throw Exception();
    }
  }
}
