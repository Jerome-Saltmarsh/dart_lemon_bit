import 'dart:math';

import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_nodes.dart';
import 'package:gamestream_flutter/library.dart';

class IsometricPosition {

  var x = 0.0;
  var y = 0.0;
  var z = 0.0;

  int get indexZ => z ~/ Node_Size_Half;
  int get indexRow => x ~/ Node_Size;
  int get indexColumn => y ~/ Node_Size;
  // TODO Remove
  // int get nodeIndex => gamestream.isometric.scene.getNodeIndex(x, y, z);
  // TODO Remove
  // int get indexProjection => nodeIndex % gamestream.isometric.scene.projection;

  double get indexSum => (indexRow + indexColumn).toDouble();

  bool get onscreen {
     final rx = renderX;
     if (rx < engine.Screen_Left || rx > engine.Screen_Right)
       return false;
     final ry = renderY;
     return ry > engine.Screen_Top && ry < engine.Screen_Bottom;
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
    final i = indexRow * gamestream.isometric.scene.totalColumns + indexColumn;
    if (!RendererNodes.island[i]) return true;
    if (indexZ > gamestream.isometric.player.indexZ + 2) return false;

    return RendererNodes.visible3D[gamestream.isometric.scene.getNodeIndexPosition(this)];
  }

  /// TODO remove
  bool get outOfBounds =>
      z < 0                ||
          x < 0                ||
          y < 0                ||
          x >= gamestream.isometric.scene.lengthRows    ||
          y >= gamestream.isometric.scene.lengthColumns ||
          z >= gamestream.isometric.scene.lengthZ     ;

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

