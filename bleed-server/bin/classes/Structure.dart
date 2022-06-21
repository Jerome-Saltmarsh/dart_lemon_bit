

import 'package:lemon_math/library.dart';
import '../common/StructureType.dart';
import 'collider.dart';
import 'Player.dart';
import 'components.dart';

class Structure extends Collider with Team, Health, Owner<Player?>, Type<int> {
  var cooldown = 0;
  int attackRate;
  int attackDamage;
  double attackRange;

  bool get isTower => type == StructureType.Tower;
  bool get isPalisade => type == StructureType.Palisade;

  Structure({
    required double x,
    required double y,
    required int team,
    required int health,
    required int type,
    this.attackRate = 0,
    this.attackDamage = 0,
    this.attackRange = 200.0,
    Player? owner,
  }) : super(x: x, y: y, radius: 25) {
    this.team = team;
    this.owner = owner;
    this.maxHealth = health;
    this.health = health;
    this.type = type;
    this.owner = owner;
  }

  bool withinRange(Position value) {
    return getDistance(value) < attackRange;
  }
}