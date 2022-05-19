

import 'package:bleed_common/library.dart';
import 'package:lemon_math/library.dart';

class StaticObject extends Vector2 {
  late int row;
  late int column;
  final ObjectType type;
  late bool isHouse;
  late bool isTorch;

  var frameRandom = 0;

  StaticObject({
    required double x,
    required double y,
    required this.type,
  }) :super(x, y) {
    isHouse = type == ObjectType.House01 || type == ObjectType.House02;
    isTorch = type == ObjectType.Torch;
    move(x, y);
    if (isTorch) {
      frameRandom = random.nextInt(99);
    }
  }

  void move(double x, double y){
    this.x = x;
    this.y = y;
    refreshRowAndColumn();
  }

  void refreshRowAndColumn(){
    row = convertWorldToRow(x, y);
    column = convertWorldToColumn(x, y);
  }
}
