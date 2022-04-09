import 'package:lemon_math/Vector2.dart';

import '../common/GameEventType.dart';

class GameEvent extends Vector2 {

  static int _idGen = 0;

  late int id;
  GameEventType type;
  int frameDuration = 3;
  double angle = 0;

  GameEvent({
    required this.type,
    required double x,
    required double y,
    double angle = 0}): super(x, y){
    assignNewId();
  }

  void assignNewId(){
    _idGen++;
    id = _idGen;
  }
}
