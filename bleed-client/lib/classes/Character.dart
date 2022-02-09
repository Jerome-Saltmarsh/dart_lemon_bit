import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/SlotType.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:lemon_math/Vector2.dart';

class Character extends Vector2 {
  CharacterType type;
  CharacterState state;
  Direction direction;
  int frame;
  WeaponType weapon;
  SlotType equippedSlotType = SlotType.Empty;
  SlotType equippedArmour = SlotType.Empty;
  SlotType equippedHead = SlotType.Empty;
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
    double x = 0,
    double y = 0,
    this.frame = 0,
    this.weapon = WeaponType.Unarmed,
    this.team = 0,
    this.name = "",
    this.text = "",
  }): super(x, y);
}
