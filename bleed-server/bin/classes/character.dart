import 'dart:math';

import 'package:lemon_math/library.dart';

import '../common/library.dart';
import '../functions/withinRadius.dart';
import '../utilities.dart';
import 'collider.dart';
import 'game.dart';
import 'player.dart';
import 'position3.dart';
import 'power.dart';
import 'components.dart';
import 'weapon.dart';

abstract class Character extends Collider with Team, Velocity, FaceDirection {

  var _health = 1;
  var maxHealth = 1;

  bool get dead => state == CharacterState.Dead;
  bool get dying => state == CharacterState.Dying;
  bool get alive => !deadOrDying;
  bool get deadOrDying => dead || dying;
  int get health => _health;
  double get healthPercentage => health / maxHealth;

  int get type;


  set health(int value) {
    _health = clampInt(value, 0, maxHealth);
  }
  Power? ability = null;
  var state = CharacterState.Idle;
  var stateDurationRemaining = 0;
  var stateDuration = 0;
  var animationFrame = 0;
  var frozenDuration = 0;
  /// the character that was highlighted as the character began attacking
  /// This forces a hit to occur even if the target goes out of range of the attack
  Position3? target;
  var invincible = false;
  Weapon weapon;
  var equippedArmour = ArmourType.shirtCyan;
  var equippedHead = HeadType.None;
  var equippedPants = PantsType.white;

  var performDuration = 0;
  var performX = 0.0;
  var performY = 0.0;
  var performZ = 0.0;
  var performMaxHits = 1;

  dynamic spawn;

  bool get performing => performDuration > 0;
  bool get running => state == CharacterState.Running;
  bool get idling => state == CharacterState.Idle;
  bool get characterStateIdle => state == CharacterState.Idle;
  bool get busy => stateDurationRemaining > 0;
  bool get deadOrBusy => dying || dead || busy;
  bool get deadBusyOrPerforming => dying || dead || performing;
  bool get equippedTypeIsBow => weapon.type == AttackType.Bow;
  bool get equippedTypeIsStaff => weapon.type == AttackType.Staff;
  bool get unarmed => weapon.type == AttackType.Unarmed;
  bool get equippedTypeIsShotgun => weapon.type == AttackType.Shotgun;
  bool get equippedIsMelee => AttackType.isMelee(weapon.type);
  bool get equippedIsEmpty => false;
  int get equippedLevel => 1;
  int get equippedAttackDuration => 25;
  int get equippedDamage => weapon.damage;
  double get equippedRange => weapon.range;

  void write(Player player);

    Character({
    required double x,
    required double y,
    required double z,
    required int health,
    required this.weapon,
    required int team,
    double speed = 5.0,
    this.equippedArmour = ArmourType.tunicPadded,
    this.equippedHead = HeadType.None,

  }) : super(x: x, y: y, z: z, radius: 7) {
    maxHealth = health;
    this.health = health;
    this.team = team;
  }

  void updateFrame(){
    animationFrame++;
    if (animationFrame > 6)
      animationFrame = 0;
  }

  void applyVelocity() {
    if (performDuration > 0){
      applyForce(force: 0.8, angle: faceAngle);
      return;
    }
     applyForce(force: 1.0, angle: faceAngle);
  }

  void onDeath(){

  }

  void clearAbility(){
    ability = null;
  }

  void clearTarget(){
    target = null;
  }

  void attackTarget(Position3 target) {
    if (deadOrBusy) return;
    face(target);
    setCharacterStatePerforming(duration: equippedAttackDuration);
    this.target = target;
  }

  bool getCollisionInDirection({required Game game, required double angle, required double distance}){
    return game.scene.getCollisionAt(x + getAdjacent(angle, distance), y + getOpposite(angle, distance), z + tileHeightHalf);
  }

  int getNodeTypeInDirection({required Game game, required double angle, required double distance}){
    return game.scene.getNodeXYZ(x + getAdjacent(angle, distance), y + getOpposite(angle, distance), z + tileHeightHalf).type;
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
    ability = null;
    onCharacterStateChanged();
  }

  void setCharacterStateIdle(){
    if (deadOrBusy) return;
    if (characterStateIdle) return;
    setCharacterState(value: CharacterState.Idle, duration: 0);
    target = null;
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

  void dispatch(int gameEventType, [double angle = 0]){
     // game.dispatch(gameEventType, x, y, z, angle);
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
}

class RunSpeed {
   static const Slow = 1.0;
   static const Regular = 2.0;
   static const Fast = 3.0;
   static const Very_Fast = 4.0;
}
