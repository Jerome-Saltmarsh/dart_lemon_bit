import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/common/enums/Direction.dart';

class Character {
  CharacterType type;
  CharacterState state;
  Direction direction;
  double x;
  double y;
  int frame;
  WeaponType weapon;
  int team;
  String name;
  String text;
  double health = 1; // percentage between 0 and 1
  double magic = 1; // percentage between 0 and 1

  bool get dead => state == CharacterState.Dead;
  bool get alive => state != CharacterState.Dead;

  Character({
    required this.type,
    this.state = CharacterState.Idle,
    this.direction = Direction.Down,
    this.x = 0,
    this.y = 0,
    this.frame = 0,
    this.weapon = WeaponType.Unarmed,
    this.team = 0,
    this.name = "",
    this.text = "",
  });
}
