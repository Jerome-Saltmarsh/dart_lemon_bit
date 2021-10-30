import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/enums.dart';

class Character {
  CharacterState state;
  Direction direction;
  double x;
  double y;
  int frame;
  Weapon weapon;
  int squad;
  String name;
  String text;

  bool get dead => state == CharacterState.Dead;
  bool get alive => state != CharacterState.Dead;

  Character({
    this.state = CharacterState.Idle,
    this.direction = Direction.Down,
    this.x = 0,
    this.y = 0,
    this.frame = 0,
    this.weapon = Weapon.Unarmed,
    this.squad = 0,
    this.name = "",
    this.text = "",
  });
}
