
import 'dart:math';

import 'package:bleed_server/common/src/maths.dart';
import 'package:bleed_server/common/src/isometric/node_size.dart';
import 'package:lemon_math/library.dart';

class IsometricPosition with Position {
  var z = 0.0;

  int get indexRow => x ~/ Node_Size;
  int get indexColumn => y ~/ Node_Size;
  int get indexZ => z ~/ Node_Size_Half;
  double get renderX => (x - y) * 0.5;
  double get renderY => ((y + x) * 0.5) - z;
  double get order => (y + x + z);

  IsometricPosition set({double? x, double? y, double? z}){
     if (x != null) this.x = x;
     if (y != null) this.y = y;
     if (z != null) this.x = z;
     return this;
  }

  bool withinRadiusPosition(IsometricPosition position3, double radius) =>
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

  static bool compare(IsometricPosition a, IsometricPosition b){
    final aRowColumn = a.indexRow + a.indexColumn;
    final bRowColumn = b.indexRow + b.indexColumn;

    if (aRowColumn > bRowColumn) return false;
    if (aRowColumn < bRowColumn) return true;

    final aIndexZ = a.z;
    final bIndexZ = b.z;

    if (aIndexZ > bIndexZ) return false;
    if (aIndexZ < bIndexZ) return true;

    return a.order < b.order;
  }


  /// FUNCTIONS
  ///
  static void sort(List<IsometricPosition> items) {
    var start = 0;
    var end = items.length;
    for (var pos = start + 1; pos < end; pos++) {
      var min = start;
      var max = pos;
      var element = items[pos];
      while (min < max) {
        var mid = min + ((max - min) >> 1);
        if (compare(element, items[mid])) {
          max = mid;
        } else {
          min = mid + 1;
        }
      }
      items.setRange(min + 1, pos + 1, items, min);
      items[min] = element;
    }
  }

  double getDistance3(IsometricPosition position) =>
      getDistanceV3(x, y, z, position.x, position.y, position.z);

  double getDistanceSquared(IsometricPosition position) =>
      getDistanceSquaredXYZ(position.x, position.y, position.z);

  double getDistanceSquaredXYZ(double x, double y, double z) =>
      pow(this.x - x, 2) +
      pow(this.y - y, 2) +
      pow(this.z - z, 2).toDouble();

  void moveTo(IsometricPosition value){
    x = value.x;
    y = value.y;
    z = value.z;
  }
}