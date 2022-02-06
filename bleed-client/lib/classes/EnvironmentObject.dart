

import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/mappers/mapEnvironmentObjectToSrc.dart';
import 'package:bleed_client/modules/isometric/utilities.dart';
import 'package:lemon_math/Vector2.dart';

class EnvironmentObject extends Vector2 {
  late int row;
  late int column;
  final ObjectType type;
  final bool generated;

  // final dst = Float32List(4);

  late double _top;
  late double _right;
  late double _bottom;
  late double _left;

  late double _width;
  late double height;
  late double radius;

  double get top => _top;
  double get right => _right;
  double get bottom => _bottom;
  double get left => _left;

  double get anchorX => _width * 0.5;
  double get anchorY => height * 0.6666;

  EnvironmentObject({
    required double x,
    required double y,
    required this.type,
    required this.radius,
    this.generated = false,
  }) :super(x, y) {
    _width = environmentObjectWidth[type]!;
    height = environmentObjectHeight[type]!;
    _top = y - anchorY;
    _right = x + anchorX;
    _bottom = y + (height - anchorY);
    _left = x - anchorX;
    move(x, y);
  }

  void move(double x, double y){
    this.x = x;
    this.y = y;
    row = getRow(x, y);
    column = getColumn(x, y);
  }
}
