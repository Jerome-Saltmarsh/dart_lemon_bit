//
// import 'dart:math';
// import 'dart:typed_data';
// import 'dart:ui';
//
// import 'package:gamestream_flutter/gamestream/isometric/components/render/types/animation_mode.dart';
//
// /// values
// /// [0] srcLeft
// /// [1] srcTop
// /// [2] srcRight
// /// [3] srcBottom
// /// [4] dstX
// /// [5] dstY
// class Sprite2 {
//   final Image image;
//   final Float32List values;
//   final int rows;
//   final int columns;
//   final int mode;
//   final double srcWidth;
//   final double srcHeight;
//   final int x;
//   final int y;
//
//   Sprite2({
//     required this.image,
//     required this.values,
//     required this.rows,
//     required this.columns,
//     required this.mode,
//     required this.srcWidth,
//     required this.srcHeight,
//     this.x = 0,
//     this.y = 0,
//   });
//
//   factory Sprite2.fromList({
//     required List<num> list,
//     required Image image,
//     required int rows,
//     required int columns,
//     required int mode,
//     required double srcWidth,
//     required double srcHeight,
//     int x = 0,
//     int y = 0,
//   }) => Sprite2(
//       image: image,
//       rows: rows,
//       columns: columns,
//       mode: mode,
//       srcWidth: srcWidth,
//       srcHeight: srcHeight,
//       x: x,
//       y: y,
//       values: Float32List.fromList(
//           list
//               .map((e) => e.toDouble())
//               .toList(growable: false)
//       )
//   );
//
//   int getFrame({required int row, required int column}){
//     final columns = this.columns; // cache on cpu
//     switch (mode){
//       case AnimationMode.Single:
//         return (row * columns) + (min(column, columns - 1));
//       case AnimationMode.Loop:
//         return (row * columns) + (column % columns);
//       case AnimationMode.Bounce:
//         if (column ~/ columns % 2 == 0){
//           return (row * columns) + column % columns;
//         }
//         return (row * columns) + ((columns - 1) - (column % columns));
//       default:
//         throw Exception();
//     }
//   }
//
//   int getFramePercentage(int row, double actionComplete) {
//     final columns = this.columns; // cache on cpu
//     switch (mode){
//       case AnimationMode.Single:
//         return (row * columns) + min((columns * actionComplete).round(), columns - 1);
//       case AnimationMode.Bounce:
//         if (actionComplete < 0.5){
//           final p = actionComplete / 0.5;
//           return (row * columns) + min((columns * p).round(), columns - 1);
//         }
//         final p = 1.0 - ((actionComplete - 0.5) / 0.5);
//         return (row * columns) + min((columns * p).round(), columns - 1);
//
//       case AnimationMode.Loop:
//         return (row * columns) + min((columns * actionComplete).round(), columns - 1);
//       default:
//         throw Exception();
//     }
//   }
// }
