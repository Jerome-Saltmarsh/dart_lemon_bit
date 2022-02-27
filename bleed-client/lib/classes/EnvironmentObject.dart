

import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/mappers/mapEnvironmentObjectToSrc.dart';
import 'package:bleed_client/modules/isometric/utilities.dart';
import 'package:lemon_math/Vector2.dart';

class EnvironmentObject extends Vector2 {
  late int row;
  late int column;
  final ObjectType type;
  final bool generated;

  late double top;
  late double right;
  late double bottom;
  late double left;
  late double width;
  late double height;
  late double radius;
  late double anchorX;
  late double anchorY;

  late double srcX;

  static const _anchorYRatio = 0.66666;

  EnvironmentObject({
    required double x,
    required double y,
    required this.type,
    required this.radius,
    this.generated = false,
  }) :super(x, y) {
    width = environmentObjectWidth[type]!;
    height = environmentObjectHeight[type]!;
    anchorX = width * 0.5;
    anchorY = height * _anchorYRatio;
    top = y - anchorY;
    right = x + anchorX;
    bottom = y + (height - anchorY);
    left = x - anchorX;
    move(x, y);

    final translation = objectTypeSrcPosition[type]!;
    final index =  environmentObjectIndex[type]!;
    srcX = index * width + translation.x;
  }

  void move(double x, double y){
    this.x = x;
    this.y = y;
    row = getRow(x, y);
    column = getColumn(x, y);
  }
}
