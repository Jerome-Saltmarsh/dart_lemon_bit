import 'package:gamestream_flutter/isometric/utils/convert.dart';
import 'package:lemon_math/library.dart';

class GameObject extends Vector2 {
  late int row;
  late int column;
  late int type;
  var id = -1;
  GameObject() : super(0, 0) {
    move(x, y);
  }

  void move(double x, double y){
    this.x = x;
    this.y = y;
    refreshRowAndColumn();
  }

  void refreshRowAndColumn(){
    row = convertWorldToRow(x, y, 0);
    column = convertWorldToColumn(x, y, 0);
  }
}