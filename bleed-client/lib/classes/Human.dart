import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/enums.dart';

class Human {
  CharacterState state;
  Direction direction;
  double x;
  double y;
  int frame;
  Weapon weapon;
  int squad;
  String name;
  String text = "";

  Human({
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
