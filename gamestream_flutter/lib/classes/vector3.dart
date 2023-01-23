import 'dart:math';

import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/render/renderer_nodes.dart';

class Vector3 with Position {
  late double z;

  /// remove
  int get indexZ {
    const Halves_0 = Node_Size_Half * 0;
    const Halves_1 = Node_Size_Half * 1;
    const Halves_2 = Node_Size_Half * 2;
    const Halves_3 = Node_Size_Half * 3;
    const Halves_4 = Node_Size_Half * 4;
    if (z < Halves_0) return z ~/ Node_Size_Half;
    if (z < Halves_1) return 0;
    if (z < Halves_2) return 1;
    if (z < Halves_3) return 2;
    if (z < Halves_4) return 3;
    return z ~/ Node_Size_Half;
  }
  int get indexRow => x ~/ Node_Size;
  int get indexColumn => y ~/ Node_Size;
  int get nodeIndex => GameQueries.getNodeIndex(x, y, z);

  int get nodeVisibility => outOfBounds ? Visibility.Invisible : GameNodes.nodeVisible[nodeIndex];

  bool get nodeVisibilityOpaque => nodeVisibility == Visibility.Opaque;
  bool get nodeVisibilityInvisible => nodeVisibility == Visibility.Invisible;

  bool get nodePerceptible {
    if (outOfBounds) return false;
    final index = nodeIndex;
    if (index < RendererNodes.nodesPerceptible.length && RendererNodes.nodesPerceptible[index]) return true;
    return !(RendererNodes.nodesReserved[index % GameNodes.projection]);
  }

  int get indexProjection => nodeIndex % GameNodes.projection;

  double get renderOrder => x + y + (z * 0.25);

  double get sortOrder => x + y + z;
  double get renderX => (x - y) * 0.5;
  double get renderY => ((y + x) * 0.5) - z;

  void set indexZ(int value){
    z = value * Node_Size_Half;
  }
  void set indexRow(int value){
    x = value * Node_Size;
  }
  void set indexColumn(int value){
    y = value * Node_Size;
  }
  bool get outOfBounds =>
     z < 0                ||
     x < 0                ||
     y < 0                ||
     x >= GameState.nodesLengthRow    ||
     y >= GameState.nodesLengthColumn ||
     z >= GameState.nodesLengthZ     ;

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

}
