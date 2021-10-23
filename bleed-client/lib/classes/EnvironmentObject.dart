
import 'dart:ui';

import 'package:bleed_client/common/ObjectType.dart';
import 'package:bleed_client/mappers/mapEnvironmentObjectTypeToImage.dart';

class EnvironmentObject {
  double x;
  double y;
  EnvironmentObjectType type;
  Image image;
  Rect dst;

  EnvironmentObject({this.x, this.y, this.type}){
    image = mapEnvironmentObjectTypeToImage(type);
    dst = Rect.fromLTWH(x - 50, y - 80, 100, 120);
  }
}
