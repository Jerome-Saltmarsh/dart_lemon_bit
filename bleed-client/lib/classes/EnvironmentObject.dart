
import 'dart:typed_data';

import 'package:bleed_client/common/classes/Vector2.dart';
import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/getters/getTileAt.dart';
import 'package:bleed_client/mappers/mapEnvironmentObjectToSrc.dart';

class EnvironmentObject extends Vector2 {
  late int row;
  late int column;
  final ObjectType type;
  final bool generated;

  late final Float32List dst;

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
    required double x,
    required double y,
    required this.type,
    required this.radius,
    this.generated = false,
  }) :super(x, y) {
    _width = environmentObjectWidth[type]!;
    height = environmentObjectHeight[type]!;
    final double widthHalf = _width * 0.5;
    _top = y - height * 0.666;
    _right = x + widthHalf;
    _bottom = y + height * 0.333;
    _left = x - widthHalf;
    dst = Float32List(4);
    dst[0] = 1;
    dst[1] = 0;
    dst[2] = x - (_width * 0.5);
    dst[3] = y - (height * 0.6666);
    row = getRow(x, y);
    column = getColumn(x, y);
  }
}
