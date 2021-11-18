
import 'dart:typed_data';
import 'dart:ui';

import 'package:bleed_client/common/enums/EnvironmentObjectType.dart';

class EnvironmentObject {
  double x;
  double y;
  int tileRow;
  int tileColumn;
  Image image;
  final EnvironmentObjectType type;
  // final Rect dst;
  // final Rect src;
  final bool generated;

  final Float32List dst;
  final Float32List src;

  double _top;
  double _right;
  double _bottom;
  double _left;

  double width;
  double height;
  double radius;

  double get top => _top;
  double get right => _right;
  double get bottom => _bottom;
  double get left => _left;

  EnvironmentObject({this.x, this.y, this.type, this.image, this.src, this.dst, this.generated = false, this.radius}) {
    width = src[2] - src[0];
    height = src[3] - src[1];
    double widthHalf = width * 0.5;
    _top = y - height * 0.666;
    _right = x + widthHalf;
    _bottom = y + height * 0.333;
    _left = x - widthHalf;
  }
}
