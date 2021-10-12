
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/enums.dart';

class Zombie {
  double x;
  double y;
  CharacterState state;
  Direction direction;
  String scoreMultiplier;
  int frame = 0;

  bool get dead => state == CharacterState.Dead;
  bool get alive => state != CharacterState.Dead;

  Zombie({this.x, this.y, this.state, this.direction, this.scoreMultiplier});
}