import 'package:gamestream_flutter/library.dart';

class IsometricPosition implements Comparable<IsometricPosition>{

  double x;
  double y;
  double z;

  IsometricPosition({this.x = 0, this.y = 0, this.z = 0});

  int get indexZ => z ~/ Node_Size_Half;

  int get indexRow => x ~/ Node_Size;

  int get indexColumn => y ~/ Node_Size;

  double get indexSum => (indexRow + indexColumn).toDouble();

  double get sortOrder => x + y + z;

  double get screenX => engine.worldToScreenX(renderX);

  double get screenY => engine.worldToScreenY(renderY);

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

  @override
  String toString()=> '{x: ${x.toInt()}, y: ${y.toInt()}, z: ${z.toInt()}}';

  // static int compareRenderOrder(IsometricPosition a, IsometricPosition b) {
  //   // final aRowColumn = a.indexRow + a.indexColumn;
  //   // final bRowColumn = b.indexRow + b.indexColumn;
  //   //
  //   // if (aRowColumn > bRowColumn) return false;
  //   // if (aRowColumn < bRowColumn) return true;
  //   //
  //   // final aIndexZ = a.indexZ;
  //   // final bIndexZ = b.indexZ;
  //   //
  //   // if (aIndexZ > bIndexZ) return false;
  //   // if (aIndexZ < bIndexZ) return true;
  //
  //   // return a.sortOrder < b.sortOrder;
  //   final aSortOrder = a.sortOrder;
  //   final bSortUnder = b.sortOrder;
  //
  //   if (aSortOrder < bSortUnder)
  //     return 1;
  //
  //   if (aSortOrder > bSortUnder)
  //     return -1;
  //
  //   return 0;
  // }

  // static int compareRenderOrder2(IsometricPosition a, IsometricPosition b) {
  //   final aRowColumn = a.indexRow + a.indexColumn;
  //   final bRowColumn = b.indexRow + b.indexColumn;
  //
  //   if (aRowColumn > bRowColumn) return false;
  //   if (aRowColumn < bRowColumn) return true;
  //
  //   final aIndexZ = a.indexZ;
  //   final bIndexZ = b.indexZ;
  //
  //   if (aIndexZ > bIndexZ) return false;
  //   if (aIndexZ < bIndexZ) return true;
  //
  //   return a.sortOrder < b.sortOrder;
  // }

  @override
  int compareTo(IsometricPosition that) {
    final thisSortThat = this.sortOrder;
    final thatSortOrder = that.sortOrder;

    if (thisSortThat < thatSortOrder)
      return -1;

    if (thisSortThat > thatSortOrder)
      return 1;

    return 0;
  }


}

