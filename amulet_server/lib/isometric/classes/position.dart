
import 'dart:math';

import 'package:amulet_common/src.dart';
import 'package:lemon_math/src.dart';


class Position implements Comparable<Position> {
  double x;
  double y;
  double z;

  Position({
    this.x = 0,
    this.y = 0,
    this.z = 0,
  });

  int get indexRow => x ~/ Node_Size;

  int get indexColumn => y ~/ Node_Size;

  int get indexZ => z ~/ Node_Size_Half;

  double get renderX => (x - y) * 0.5;

  double get renderY => ((x + y) * 0.5) - z;

  double get order => x + y + z;

  double getDistance(Position value) =>
      getDistanceXYZ(value.x, value.y, value.z);

  double getDistanceXYZ(double x, double y, double z) =>
      hyp3(this.x - x, this.y - y, this.z - z);

  double getDistanceXY(double x, double y) =>
      hyp2(this.x - x, this.y - y);

  double getAngle(Position value) =>
      getAngleXY(value.x, value.y);

  double getAngleXY(double x, double y) =>
      angleBetween(this.x, this.y, x, y);

  bool withinRadiusPosition(Position position3, double radius) =>
      withinRadiusXYZ(position3.x, position3.y, position3.z, radius);

  bool withinRadiusXYZ(double x, double y, double z, double radius){
    final radiusSquared = pow(radius, 2);

    final xDiffSquared = pow(this.x - x, 2);
    if (xDiffSquared > radiusSquared) return false;

    final yDiffSquared = pow(this.y - y, 2);
    if (yDiffSquared > radiusSquared) return false;

    final zDiffSquared = pow(this.z - z, 2);
    if (zDiffSquared > radiusSquared) return false;

    return xDiffSquared + yDiffSquared + zDiffSquared <= radiusSquared;
  }

  double getDistanceSquared(Position position) =>
      getDistanceSquaredXYZ(position.x, position.y, position.z);

  double getDistanceSquaredXYZ(double x, double y, double z) =>
      pow(this.x - x, 2) +
      pow(this.y - y, 2) +
      pow(this.z - z, 2).toDouble();

  void moveTo(Position value){
    x = value.x;
    y = value.y;
    z = value.z;
  }

  @override
  int compareTo(Position that) {
    final thisSortThat = order;
    final thatSortOrder = that.order;

    if (thisSortThat < thatSortOrder) {
      return -1;
    }

    if (thisSortThat > thatSortOrder) {
      return 1;
    }

    return 0;
  }

  @override
  String toString() => '{x: ${x.toInt()}, y: ${y.toInt()}, z: ${z.toInt()}}';
}