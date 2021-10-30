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
  String text = "";

  Character({
    this.state,
    this.direction,
    this.x,
    this.y,
    this.frame,
    this.weapon,
    this.squad,
    this.name
  });
}
