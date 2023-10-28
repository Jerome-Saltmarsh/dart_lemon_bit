import 'dart:math';

import 'package:gamestream_flutter/packages/common/src/isometric/node_size.dart';
import 'package:lemon_math/src.dart';

class Position implements Comparable<Position>{

  double x;
  double y;
  double z;

  Position({this.x = 0, this.y = 0, this.z = 0});

  int get indexZ => z ~/ Node_Size_Half;

  int get indexRow => x ~/ Node_Size;

  int get indexColumn => y ~/ Node_Size;

  double get indexSum => (indexRow + indexColumn).toDouble();

  double get sortOrder {
    final z = this.z;
    return x + y + (z + z);
  }

  double get renderX => (x - y) * 0.5;

  double get renderY => ((x + y) * 0.5) - z;

  void set indexZ(int value){
    z = value * Node_Size_Half;
  }
  void set indexRow(int value){
    x = value * Node_Size;
  }
  void set indexColumn(int value){
    y = value * Node_Size;
  }

  void copy(Position position){
    this.x = position.x;
    this.y = position.y;
    this.z = position.z;
  }

  @override
  String toString()=> '{x: ${x.toInt()}, y: ${y.toInt()}, z: ${z.toInt()}}';

  @override
  int compareTo(Position that) {
    final thisRenderOrder = this.sortOrder;
    final thatRenderOrder = that.sortOrder;

    if (thisRenderOrder < thatRenderOrder)
      return -1;

    if (thisRenderOrder > thatRenderOrder)
      return 1;

    return 0;
  }

  double getAngle(double x, double y) => angleBetween(this.x, this.y, x, y);

  bool withinRadiusPosition({
    required Position position,
    required double radius,
  }) =>
    withinRadius(x: position.x, y: position.y, z: position.z, radius: radius);

  bool withinRadius({
    required double x,
    required double y,
    required double z,
    required double radius,
  }) =>
      getDistanceXYZSquared(this.x, this.y, this.z, x, y, z) <= pow(radius, 2);
}

