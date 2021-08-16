

import '../classes.dart';
import '../enums/CollectableType.dart';

class Collectable extends GameObject {
  CollectableType type;
  Collectable(double x, double y, this.type) : super(x, y);
}