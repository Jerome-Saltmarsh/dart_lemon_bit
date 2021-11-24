import '../common/GameEventType.dart';
import 'GameObject.dart';

class GameEvent extends GameObject {
  GameEventType type;
  int frameDuration = 2;

  GameEvent(this.type, double x, double y, double xv, double yv)
      : super(x, y, xv: xv, yv: yv);
}
