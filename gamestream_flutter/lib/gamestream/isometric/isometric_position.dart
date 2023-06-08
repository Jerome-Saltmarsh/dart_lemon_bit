import 'dart:math';

import 'package:gamestream_flutter/gamestream/games/isometric/render/renderer_nodes.dart';
import 'package:gamestream_flutter/library.dart';

class IsometricPosition with Position {
  late double z;

  // GETTERS

  int get indexZ => z ~/ Node_Size_Half;
  int get indexRow => x ~/ Node_Size;
  int get indexColumn => y ~/ Node_Size;
  double get indexSum => (indexRow + indexColumn).toDouble();
  int get nodeIndex => gamestream.isometric.nodes.getNodeIndex(x, y, z);
  int get indexProjection => nodeIndex % gamestream.isometric.nodes.projection;

  bool get onscreen {
     final rx = renderX;
     if (rx < engine.Screen_Left) return false;
     if (rx > engine.Screen_Right) return false;
     final ry = renderY;
     if (ry < engine.Screen_Top) return false;
     if (ry > engine.Screen_Bottom) return false;
     return true;
  }

  bool get onscreenPadded {
    const Pad_Distance = 75.0;
    final rx = renderX;

    if (rx < engine.Screen_Left - Pad_Distance)
      return false;
    if (rx > engine.Screen_Right + Pad_Distance)
      return false;
    final ry = renderY;
    if (ry < engine.Screen_Top - Pad_Distance)
      return false;
    if (ry > engine.Screen_Bottom + Pad_Distance)
      return false;

    return true;
  }

  bool get nodePerceptible {
    if (outOfBounds) return false;
    if (!RendererNodes.playerInsideIsland) return true;
    final i = indexRow * gamestream.isometric.nodes.totalColumns + indexColumn;
    if (!RendererNodes.island[i]) return true;
    if (indexZ > gamestream.isometric.player.indexZ + 2) return false;

    return RendererNodes.visible3D[nodeIndex];
  }

  bool get outOfBounds =>
      z < 0                ||
          x < 0                ||
          y < 0                ||
          x >= gamestream.isometric.nodes.lengthRows    ||
          y >= gamestream.isometric.nodes.lengthColumns ||
          z >= gamestream.isometric.nodes.lengthZ     ;

  double get sortOrder => x + y + z;
  double get renderX => (x - y) * 0.5;
  double get renderY => ((y + x) * 0.5) - z;

  // SETTERS

  void set indexZ(int value){
    z = value * Node_Size_Half;
  }
  void set indexRow(int value){
    x = value * Node_Size;
  }
  void set indexColumn(int value){
    y = value * Node_Size;
  }

  /// TODO Delete
  int getGridDistance(int z, int row, int column){
    var distance = (z - indexZ).abs();
    final distanceRow = (row - indexRow).abs();
    final distanceColumn = (column - indexColumn).abs();
    if (distanceRow > distance){
      distance = distanceRow;
    }
    if (distanceColumn > distance){
      return distanceColumn;
    }
    return distance;
  }

  IsometricPosition() {
    this.x = 0;
    this.y = 0;
    this.z = 0;
  }

  @override
  String toString(){
    return 'x: ${x.toInt()}, y: ${y.toInt()}, z: ${z.toInt()}';
  }

  // TODO Delete
  double distance3(double x, double y, double z){
    return sqrt(_sq(this.x - x) + _sq(this.y - y) + _sq(this.z - z));
  }

  double distanceFrom(IsometricPosition that){
    return distance3(that.x, that.y, that.z);
  }

  double _sq(double value){
    return value * value;
  }

  double get magnitude {
    return sqrt((x * x) + (y * y) + (z * z));
  }

  double get magnitudeXY {
    return sqrt((x * x) + (y * y));
  }

}
