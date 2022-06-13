import 'dart:math';

import 'package:lemon_math/library.dart';

import '../common/library.dart';
import '../common/weapon_type.dart';
import '../functions/withinRadius.dart';
import 'Collider.dart';
import 'Game.dart';
import 'card_abilities.dart';
import 'components.dart';

class Character extends Collider with Team, Health, Velocity, Material {
  late CharacterType type;
  late double _speed;
  CardAbility? ability = null;
  double angle = 0;
  double accuracy = 0;
  double speedModifier = 0;
  var state = CharacterState.Idle;
  var stateDurationRemaining = 0;
  var stateDuration = 0;
  var animationFrame = 0;
  var frozenDuration = 0;
  /// the character that was highlighted as the character began attacking
  /// This forces a hit to occur even if the target goes out of range of the attack
  Position? target;
  var invincible = false;
  final techTree = TechTree();
  var equippedWeapon = WeaponType.Unarmed;
  var equippedArmour = SlotType.Empty;
  var equippedHead = SlotType.Empty;

  int get direction => angle ~/ piQuarter;
  double get speed => _speed + speedModifier;

  void setSpeed(double value){
    _speed = value;
  }

  void set direction(int value){
    angle =  value * piQuarter;
  }

  bool get running => state == CharacterState.Running;

  bool get idling => state == CharacterState.Idle;

  bool get busy => stateDurationRemaining > 0;

  bool get deadOrBusy => dead || busy;

  int get equippedDamage => WeaponType.getDamage(equippedWeapon);
  double get equippedRange => WeaponType.getRange(equippedWeapon);
  int get equippedAttackDuration => 25;
  bool get equippedTypeIsBow => equippedWeapon == WeaponType.Bow;
  bool get unarmed => equippedWeapon == WeaponType.Unarmed;
  bool get equippedTypeIsShotgun => equippedWeapon == WeaponType.Shotgun;
  bool get equippedIsMelee => WeaponType.isMelee(equippedWeapon);
  bool get equippedIsEmpty => false;
  int get equippedLevel => 1;

  bool isEquipped(WeaponType type) {
    return equippedWeapon == type;
  }

  void reduceEquippedAmount() {

  }

  Character({
    required this.type,
    required double x,
    required double y,
    required int health,
    int weapon = TechType.Unarmed,
    double speed = 3.0,
    int team = Teams.none,
  }) : super(x: x, y: y, radius: 7) {
    maxHealth = health;
    this.health = health;
    _speed = speed;
    this.team = team;
    this.material = MaterialType.Flesh;
  }

  void applyVelocity() {
    x -= cos(angle + piQuarter) * speed;
    y -= sin(angle + piQuarter) * speed;
  }

  void updateMovement() {
    const minVelocity = 0.005;
    if (xv.abs() <= minVelocity) return;
    x += xv;
    y += yv;
    const velocityFriction = 0.88;
    xv *= velocityFriction;
    yv *= velocityFriction;
  }

  bool withinAttackRange(Position target){
    if (target is Collider){
      return withinRadius(this, target, equippedRange + (target.radius * 0.5));
    }
    return withinRadius(this, target, equippedRange);
  }

  void face(Position position) {
    assert(!deadOrBusy);
    angle = this.getAngle(position);
  }

  int getTechTypeLevel(int type) {
    switch(type){
      case TechType.Unarmed:
        return 1;
      case TechType.Pickaxe:
        return techTree.pickaxe;
      case TechType.Sword:
        return techTree.sword;
      case TechType.Bow:
        return techTree.bow;
      case TechType.Axe:
        return techTree.axe;
      case TechType.Hammer:
        return techTree.hammer;
      default:
        throw Exception("cannot get tech type level. type: $type");
    }
  }
}

bool onSameTeam(dynamic a, dynamic b){
  if (a == b) return true;
  if (a is Team == false) return false;
  if (b is Team == false) return false;
  if (a.team == 0) return false;
  return a.team == b.team;
}

class RunSpeed {
   static const Slow = 1.0;
   static const Regular = 2.0;
   static const Fast = 3.0;
   static const Very_Fast = 4.0;
}

