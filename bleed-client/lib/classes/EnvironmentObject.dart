
import 'dart:typed_data';

import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/mappers/mapEnvironmentObjectToSrc.dart';

class EnvironmentObject {
  double x;
  double y;
  late int row;
  late int column;
  final ObjectType type;
  final bool generated;

  final Float32List dst;

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

  EnvironmentObject({
    required this.x,
    required this.y,
    required this.type,
    required this.dst,
    this.generated = false,
    required this.radius}) {
    _width = environmentObjectWidth[type]!;
    height = environmentObjectHeight[type]!;
    double widthHalf = _width * 0.5;
    _top = y - height * 0.666;
    _right = x + widthHalf;
    _bottom = y + height * 0.333;
    _left = x - widthHalf;
  }
}
