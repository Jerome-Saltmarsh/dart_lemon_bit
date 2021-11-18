
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

  double get top => _top;
  double get right => _right;
  double get bottom => _bottom;
  double get left => _left;

  EnvironmentObject({this.x, this.y, this.type, this.image, this.src, this.dst, this.generated = false}) {

    width = src[2] - src[0];
    height = src[3] - src[1];

    double widthHalf = width * 0.5;
    double heightHalf = height * 0.5;

    _top = y - heightHalf;
    _right = x + widthHalf;
    _bottom = _top + heightHalf;
    _left = _right - widthHalf;
  }
}
