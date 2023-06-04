import 'dart:math';

import 'package:gamestream_flutter/gamestream/games/isometric/render/renderer_nodes.dart';
import 'package:gamestream_flutter/library.dart';

class Vector3 with Position {
  late double z;

  // GETTERS

  int get indexZ => z ~/ Node_Size_Half;
  int get indexRow => x ~/ Node_Size;
  int get indexColumn => y ~/ Node_Size;
  double get indexSum => (indexRow + indexColumn).toDouble();
  int get nodeIndex => gamestream.games.isometric.nodes.getNodeIndex(x, y, z);
  int get indexProjection => nodeIndex % gamestream.games.isometric.nodes.projection;

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
    final i = indexRow * gamestream.games.isometric.nodes.totalColumns + indexColumn;
    if (!RendererNodes.island[i]) return true;
    if (indexZ > gamestream.games.isometric.player.indexZ + 2) return false;

    return RendererNodes.visible3D[nodeIndex];
  }

  bool get outOfBounds =>
      z < 0                ||
          x < 0                ||
          y < 0                ||
          x >= gamestream.games.isometric.nodes.lengthRows    ||
          y >= gamestream.games.isometric.nodes.lengthColumns ||
          z >= gamestream.games.isometric.nodes.lengthZ     ;

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

  Vector3() {
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

  double distanceFrom(Vector3 that){
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
