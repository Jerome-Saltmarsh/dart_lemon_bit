import 'package:lemon_math/Vector2.dart';

import '../common/GameEventType.dart';

class GameEvent extends Vector2 {

  static int idGen = 0;

  int id = idGen++;
  GameEventType type;
  int frameDuration = 2;
  double angle = 0;

  GameEvent({
    required this.type,
    required double x,
    required double y,
    double angle = 0}): super(x, y);

  void assignNewId(){
    idGen++;
    id = idGen;
  }
}
