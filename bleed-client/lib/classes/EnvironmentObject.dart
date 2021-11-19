
import 'dart:typed_data';

import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/mappers/mapEnvironmentObjectToSrc.dart';

class EnvironmentObject {
  double x;
  double y;
  int tileRow;
  int tileColumn;
  final ObjectType type;
  final bool generated;

  final Float32List dst;

  double _top;
  double _right;
  double _bottom;
  double _left;

  double _width;
  double height;
  double radius;

  double get top => _top;
  double get right => _right;
  double get bottom => _bottom;
  double get left => _left;

  EnvironmentObject({this.x, this.y, this.type, this.dst, this.generated = false, this.radius}) {
    _width = environmentObjectWidth[type];
    height = environmentObjectHeight[type];
    double widthHalf = _width * 0.5;
    _top = y - height * 0.666;
    _right = x + widthHalf;
    _bottom = y + height * 0.333;
    _left = x - widthHalf;
  }
}
