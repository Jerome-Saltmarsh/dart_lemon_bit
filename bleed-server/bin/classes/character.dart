import 'dart:math';

import 'package:lemon_math/library.dart';

import '../common/library.dart';
import '../functions/withinRadius.dart';
import 'collider.dart';
import 'components.dart';
import 'player.dart';
import 'position3.dart';

abstract class Character extends Collider with Team, Velocity, FaceDirection {

  var _health = 1;
  var _maxHealth = 1;

  bool get dead => state == CharacterState.Dead;
  bool get dying => state == CharacterState.Dying;
  bool get alive => !deadOrDying;
  bool get deadOrDying => dead || dying;
  int get health => _health;
  double get healthPercentage => health / maxHealth;

  int get type;

  int get maxHealth => _maxHealth;

  set maxHealth(int value){
     if (_maxHealth == value) return;
     assert (value >= 0);
     _maxHealth = value;
     if (this is Player){
       (this as Player).writePlayerMaxHealth();
       (this as Player).writePlayerHealth();
     }
  }

  set health (int value) {
    if (_health == value) return;
    _health = clamp(value, 0, maxHealth);
    if (this is Player){
      (this as Player).writePlayerHealth();
    }
  }
  var state = CharacterState.Idle;
  var stateDurationRemaining = 0;
  var stateDuration = 0;
  var animationFrame = 0;
  var frozenDuration = 0;
  Position3? target;
  var invincible = false;
  var weaponDurationRemaining = 0;
  var weaponState = AttackState.Idle;
  var weaponType = ItemType.Empty;
  var bodyType = ItemType.Body_Shirt_Cyan;
  var headType = ItemType.Head_Steel_Helm;
  var legsType = ItemType.Legs_Blue;

  var weaponQuantity = 0;
  var bodyQuantity = 0;
  var headQuantity = 0;
  var legsQuantity = 0;

  int get weaponFrame => weaponDurationRemaining > 0 ? weaponDuration - weaponDurationRemaining : 0;

  var performX = 0.0;
  var performY = 0.0;
  var performZ = 0.0;

  double get weaponRange => ItemType.getRange(weaponType);
  int get weaponDamage => ItemType.getDamage(weaponType);
  int get weaponDuration => ItemType.getCooldown(weaponType);

  bool get targetSet => target != null;

  double get weaponDurationPercentage => weaponDurationRemaining == 0 ? 0 : weaponDurationRemaining / weaponDuration;

  bool get targetIsNull => target == null;

  bool get targetIsEnemy {
    if (target == null) return false;
    if (target == this) return false;
    if (target is Team == false) return false;
    final targetTeam = (target as Team).team;
    if (targetTeam == 0) return true;
    return team != targetTeam;
  }

  bool get targetIsAlly {
    if (target == null) return false;
    if (target == this) return true;
    if (target is Team == false) return false;
    final targetTeam = (target as Team).team;
    if (targetTeam == 0) return false;
    return team == targetTeam;
  }

  bool get usingWeapon => weaponDurationRemaining > 0;
  bool get running => state == CharacterState.Running;
  bool get idling => state == CharacterState.Idle;
  bool get characterStateIdle => state == CharacterState.Idle;
  bool get busy => stateDurationRemaining > 0;
  bool get deadOrBusy => dying || dead || busy;
  bool get deadBusyOrUsingWeapon => dying || dead || usingWeapon;
  bool get equippedTypeIsBow => weaponType == ItemType.Weapon_Ranged_Bow;
  bool get equippedTypeIsStaff => weaponType == ItemType.Weapon_Melee_Magic_Staff;
  bool get unarmed => weaponType == ItemType.Empty;
  bool get equippedTypeIsShotgun => weaponType == ItemType.Weapon_Ranged_Shotgun;
  bool get equippedIsMelee => ItemType.isTypeWeaponMelee(weaponType);
  bool get equippedIsEmpty => false;
  int get equippedAttackDuration => 25;
  int get equippedDamage => ItemType.getDamage(weaponType);
  double get equippedRange => ItemType.getRange(weaponType);

  void write(Player player);

    Character({
    required double x,
    required double y,
    required double z,
    required int health,
    required this.bodyType,
    required this.headType,
    required this.weaponType,
    required int team,
    double speed = 5.0,
  }) : super(x: x, y: y, z: z, radius: 7) {
    maxHealth = health;
    this.health = health;
    this.team = team;
  }


  void setCharacterStatePerforming({required int duration}){
    setCharacterState(value: CharacterState.Performing, duration: duration);
  }

  void setCharacterStateSpawning(){
    if (state == CharacterState.Spawning) return;
    state = CharacterState.Spawning;
    stateDurationRemaining = 100;
  }

  void setCharacterStateHurt(){
    if (deadOrDying) return;
    if (state == CharacterState.Hurt) return;
    stateDurationRemaining = 10;
    state = CharacterState.Hurt;
    onCharacterStateChanged();
  }

  void setCharacterStateIdle(){
    if (deadOrBusy) return;
    if (characterStateIdle) return;
    setCharacterState(value: CharacterState.Idle, duration: 0);
  }

  void setCharacterState({required int value, required int duration}) {
    assert (value >= 0);
    assert (value <= 5);
    assert (value != CharacterState.Dead); // use game.setCharacterStateDead
    assert (value != CharacterState.Hurt); // use character.setCharacterStateHurt
    if (state == value) return;
    if (deadOrBusy) return;
    stateDurationRemaining = duration;
    state = value;
    onCharacterStateChanged();
  }

  void onCharacterStateChanged(){
    stateDuration = 0;
    animationFrame = 0;
  }

  bool withinAttackRange(Position3 target){
    if (target is Collider){
      return withinRadius(this, target, equippedRange + (target.radius * 0.5));
    }
    return withinRadius(this, target, equippedRange);
  }

  void face(Position position) {
    assert(!deadOrBusy);
    faceAngle = this.getAngle(position) + pi;
  }

  void faceXY(double x, double y) {
    assert(!deadOrBusy);
    faceAngle = getAngleXY(x, y);
  }

  double getAngleXY(double x, double y) =>
      getAngleBetween(this.x, this.y, x, y);

  void updateMovement() {
    z -= zVelocity;
    const gravity = 0.98;
    zVelocity += gravity;
    const minVelocity = 0.005;
    if (velocitySpeed <= minVelocity) return;
    x += xv;
    y += yv;
    applyFriction(0.75);
  }
}

class RunSpeed {
   static const Slow = 1.0;
   static const Regular = 2.0;
   static const Fast = 3.0;
   static const Very_Fast = 4.0;
}
