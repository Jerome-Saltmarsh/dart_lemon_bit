
import 'dart:ui';

import 'package:bleed_client/common/enums/EnvironmentObjectType.dart';

class EnvironmentObject {
  double x;
  double y;
  int tileRow;
  int tileColumn;
  Image image;
  final EnvironmentObjectType type;
  final Rect dst;
  final Rect src;
  final bool generated;

  EnvironmentObject({this.x, this.y, this.type, this.image, this.src, this.dst, this.generated = false});
}
