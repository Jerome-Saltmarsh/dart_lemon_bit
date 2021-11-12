

import '../common/CollectableType.dart';
import 'GameObject.dart';

class Collectable extends GameObject {
  late String compiled;
  CollectableType type;
  bool active = true;

  Collectable(double x, double y, this.type) : super(x, y){
    _recompile();
  }

  void setType(CollectableType value){
    if (type == value) return;
    type = value;
    _recompile();
  }

  void _recompile(){
    compiled = "${type.index} ${x.toInt()} ${y.toInt()} ";
  }
}