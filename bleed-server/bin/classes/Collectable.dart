

import '../classes.dart';
import '../enums/CollectableType.dart';

class Collectable extends GameObject {
  late final String compiled;
  final CollectableType type;
  bool active = true;

  Collectable(double x, double y, this.type) : super(x, y){
    compiled = "${type.index} ${x.toInt()} ${y.toInt()} ";
  }
}