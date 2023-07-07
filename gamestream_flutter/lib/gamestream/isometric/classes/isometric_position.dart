import 'dart:math';

import 'package:gamestream_flutter/library.dart';

class IsometricPosition {
  var x = 0.0;
  var y = 0.0;
  var z = 0.0;

  int get indexZ => z ~/ Node_Size_Half;

  int get indexRow => x ~/ Node_Size;

  int get indexColumn => y ~/ Node_Size;

  double get indexSum => (indexRow + indexColumn).toDouble();

  double get sortOrder => x + y + z;

  double get screenX => engine.worldToScreenX(renderX);

  double get screenY => engine.worldToScreenY(renderY);

  double get renderX => (x - y) * 0.5;

  double get renderY => ((y + x) * 0.5) - z;

  double get magnitudeXY => sqrt((x * x) + (y * y));

  void set indexZ(int value){
    z = value * Node_Size_Half;
  }
  void set indexRow(int value){
    x = value * Node_Size;
  }
  void set indexColumn(int value){
    y = value * Node_Size;
  }

  @override
  String toString()=> '{x: ${x.toInt()}, y: ${y.toInt()}, z: ${z.toInt()}}';

  static bool compareRenderOrder(IsometricPosition a, IsometricPosition b) {
    final aRowColumn = a.indexRow + a.indexColumn;
    final bRowColumn = b.indexRow + b.indexColumn;

    if (aRowColumn > bRowColumn) return false;
    if (aRowColumn < bRowColumn) return true;

    final aIndexZ = a.indexZ;
    final bIndexZ = b.indexZ;

    if (aIndexZ > bIndexZ) return false;
    if (aIndexZ < bIndexZ) return true;

    return a.sortOrder < b.sortOrder;
  }


}

