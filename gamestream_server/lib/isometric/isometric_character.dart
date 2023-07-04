import 'dart:math';
import 'dart:typed_data';

import 'package:gamestream_server/common/src.dart';
import 'package:gamestream_server/isometric/isometric_game.dart';
import 'package:gamestream_server/lemon_math.dart';

import 'isometric_collider.dart';
import 'isometric_position.dart';

abstract class IsometricCharacter extends IsometricCollider {
  /// between 0 and 1. 0 means very accurate and 1 is very inaccurate
  var _accuracy = 0.0;
  var _faceAngle = 0.0;
  var _health = 1;
  var _maxHealth = 1;
  var _weaponType = WeaponType.Unarmed;
  var _characterType = 0;
  var _weaponState = WeaponState.Idle;

  var weaponStateDurationTotal = 0;
  var autoTarget = true;
  var autoTargetRange = 300.0;
  var autoTargetTimer = 0;
  var autoTargetTimerDuration = 100;

  var weaponDamage = 1;
  var weaponRange = 20.0;
  var weaponStateDuration = 0;
  var weaponCooldown = 0;
  var state = CharacterState.Idle;
  var stateDurationRemaining = 0;
  var stateDuration = 0;
  var nextFootstep = 0;
  var animationFrame = 0;
  var lookRadian = 0.0;
  var runSpeed = 1.0;
  var name = "";
  var pathIndex = -1;
  var pathStart = -1;
  var pathTargetIndex = 0;
  var pathTargetIndexPrevious = 0;

  var runToDestinationEnabled = true;
  var pathFindingEnabled = true;
  var runX = 0.0;
  var runY = 0.0;
  var runZ = 0.0;
  var runRadius = 1.0;

  var headType = HeadType.Plain;
  var bodyType = BodyType.Shirt_Blue;
  var legsType = LegType.Blue;

  IsometricPosition? target;

  final path = Uint32List(20);

  IsometricCharacter({
    required super.x,
    required super.y,
    required super.z,
    required super.team,
    required int characterType,
    required int health,
    required int weaponType,
    required this.weaponDamage,
    required this.weaponRange,
    required this.weaponCooldown,
    String? name,
  }) : super(
    radius: CharacterType.getRadius(characterType),
  ) {
    maxHealth = health;
    this.weaponType = weaponType;
    this.characterType = characterType;
    this.health = health;
    this.team = team;

    if (name != null){
      this.name = name;
    }
    fixed = false;
    physical = true;
    hitable = true;
    radius = CharacterType.getRadius(characterType);
    setDestinationToCurrentPosition();
  }

  int get weaponState => _weaponState;

  set weaponState(int value){
    if (_weaponState == value)
      return;
    _weaponState = value;
    weaponStateDuration = 0;
    weaponStateDurationTotal = getWeaponStateDurationTotal(value);
  }

  bool get shouldUpdatePath =>
      (pathTargetIndex != pathTargetIndexPrevious) || (pathIndex == 0);

  bool get runDestinationWithinRadiusRunSpeed => runDestinationWithinRadius(10);

  double get weaponRangeSquared => weaponRange * weaponRange;

  int get pathNodeIndex => path[pathIndex];

  int get lookDirection => IsometricDirection.fromRadian(lookRadian);

  bool get targetWithinAttackRange {
    final target = this.target;
    if (target == null){
      return false;
    }
    return withinAttackRange(target);
  }

  int get weaponType => _weaponType;

  bool get isPlayer => false;

  bool get aliveAndActive => alive && active;

  set weaponType(int value){
    // assert (value == ItemType.Empty || ItemType.isTypeWeapon(value));
    if (_weaponType == value) return;
    _weaponType = value;
    onWeaponTypeChanged();
  }

  int get characterType => _characterType;

  bool get isTemplate => _characterType == CharacterType.Template;

  set characterType(int value){
    _characterType = value;
    radius = CharacterType.getRadius(value);
    if (value != CharacterType.Template) {
      weaponType = WeaponType.Unarmed;
    }
  }

  double get accuracy => _accuracy;

  bool get characterTypeZombie => characterType == CharacterType.Zombie;

  bool get characterTypeTemplate => characterType == CharacterType.Template;

  bool get dead => state == CharacterState.Dead;

  bool get deadOrInactive => dead || !active;

  bool get alive => !dead;

  bool get targetIsNull => target == null;

  bool get targetIsEnemy {
    if (target == null) return false;
    return isEnemy(target);
  }

  bool get targetIsAlly {
    if (target == null) return false;
    return isAlly(target);
  }
  bool get weaponStateBusy => weaponState != WeaponState.Aiming && weaponStateDurationTotal > 0;

  bool get running => state == CharacterState.Running;

  bool get performing => state == CharacterState.Performing;

  bool get idling => state == CharacterState.Idle;

  bool get characterStateIdle => state == CharacterState.Idle;

  bool get characterStateHurt => state == CharacterState.Hurt;

  bool get characterStatePerforming => state == CharacterState.Performing;

  bool get characterStateChanging => state == CharacterState.Changing || weaponState == WeaponState.Changing;

  bool get busy => stateDurationRemaining > 0 && !characterStateHurt;

  bool get deadOrBusy => dead || busy;

  bool get deadBusyOrWeaponStateBusy => dead || weaponStateBusy;

  bool get canChangeEquipment => !deadBusyOrWeaponStateBusy || characterStateChanging || weaponStateAiming;

  bool get targetSet => target != null;

  bool get weaponStateIdle => weaponState == WeaponState.Idle;

  bool get weaponStateReloading => weaponState == WeaponState.Reloading;

  bool get weaponStateFiring => weaponState == WeaponState.Firing;

  bool get weaponStateMelee => weaponState == WeaponState.Melee;

  bool get weaponStateAiming => weaponState == WeaponState.Aiming;

  double get healthPercentage => health / maxHealth;

  double get faceAngle => _faceAngle;

  double get weaponDurationPercentage =>  weaponStateDurationTotal == 0 || weaponStateAiming ? 0 : weaponStateDuration / weaponStateDurationTotal;

  // int get weaponFrame {
  //   assert (weaponStateDuration == 0 || weaponStateDurationTotal > 0);
  //   assert (weaponStateDurationTotal - weaponStateDuration >= 0);
  //   return weaponStateDurationTotal - weaponStateDuration;
  // }

  int get faceDirection => IsometricDirection.fromRadian(_faceAngle);

  int get health => _health;

  int get maxHealth => _maxHealth;

  set accuracy(double value) {
    _accuracy = clamp01(value);
  }

  set maxHealth(int value){
    if (value <= 0) return;
    if (_maxHealth == value)
      return;
    _maxHealth = value;
    if (_health > _maxHealth) {
      health = _maxHealth;
    }
  }

  set health (int value) => _health = clamp(value, 0, maxHealth);

  void set faceDirection(int value) =>
        faceAngle = IsometricDirection.toRadian(value);

  void set faceAngle(double value) =>
      _faceAngle = value % pi2;

  int getWeaponStateDurationTotal(int weaponState) =>
      switch(weaponState) {
        WeaponState.Melee => weaponCooldown,
        WeaponState.Firing => weaponCooldown,
        WeaponState.Idle => 0,
        WeaponState.Aiming => 10,
        WeaponState.Reloading => 10,
        WeaponState.Throwing => 15,
        _ => (throw Exception(''))
      };

  void assignWeaponStateReloading(){
    weaponState = WeaponState.Reloading;
    weaponStateDurationTotal = 30;
  }

  void setCharacterStatePerforming({required int duration}){
    assert (active);
    assert (alive);
    setCharacterState(value: CharacterState.Performing, duration: duration);
  }

  void setCharacterStateSpawning(){
    if (state == CharacterState.Spawning) return;
    state = CharacterState.Spawning;
    stateDurationRemaining = 40;
  }

  void setCharacterStateHurt(){
    if (dead) return;
    if (state == CharacterState.Hurt) return;
    if (!canSetCharacterStateHurt) return;
    stateDurationRemaining = 10;
    state = CharacterState.Hurt;
    onCharacterStateChanged();
    customOnHurt();
  }

  /// can be safely overridden for custom logic
  bool get canSetCharacterStateHurt => true;

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

  bool withinAttackRange(IsometricPosition target){
    if ((target.z - z).abs() > Character_Height)
      return false;
    if (target is IsometricCollider) {
      return withinRadiusPosition(target, weaponRange + target.radius);
    }
    return withinRadiusPosition(target, weaponRange);
  }

  void face(IsometricPosition position) => faceXY(position.x, position.y);

  void lookAt(IsometricPosition position) => lookAtXY(position.x, position.y);

  void faceXY(double x, double y) {
    if (deadOrBusy) return;
    faceAngle = getAngleXY(x, y) + pi;
  }

  void lookAtXY(double x, double y) {
    if (deadOrBusy) return;
    lookRadian = getAngleXY(x, y) + pi;
  }

  double getAngleXY(double x, double y) =>
      angleBetween(this.x, this.y, x, y);

  void setCharacterStateRunning()=>
      setCharacterState(value: CharacterState.Running, duration: 0);

  void update() {
    const change = 0.01;
    if (accuracy.abs() > change){
      if (accuracy > 0) {
        accuracy -= change;
      } else {
        accuracy += change;
      }
    }

    if (weaponStateDuration < weaponStateDurationTotal) {
      weaponStateDuration++;
      if (weaponStateDuration == weaponStateDurationTotal) {
        switch (weaponState) {
          case WeaponState.Firing:
            weaponState = WeaponState.Aiming;
            weaponStateDurationTotal = 10;
            weaponStateDuration = 0;
            break;
          default:
            weaponState = WeaponState.Idle;
            weaponStateDurationTotal = 0;
            weaponStateDuration = 0;
            break;
        }
      }
    }
  }

  /// safe to override
  void onWeaponTypeChanged() {}

  /// safe to override
  void customOnUpdate() {}

  void customOnHurt(){ }

  void customOnDead() {}

  bool runDestinationWithinRadius(double radius) =>
      withinRadiusXYZ(runX, runY, runZ, radius);

  void runToDestination(){
    if (runDestinationWithinRadiusRunSpeed) return;
    faceRunDestination();
    setCharacterStateRunning();
  }

  void faceRunDestination() => faceXY(runX, runY);

  void clearTarget(){
    target = null;
  }

  /// throws an exception if target is null
  void setDestinationToTarget() {
    final target = this.target;
    if (target == null) {
      throw Exception('target is null');
    }
    runX = target.x;
    runY = target.y;
    runZ = target.z;
  }

  /// throws an exception if target is null
  bool targetWithinRadius(double radius) {
    final target = this.target;
    if (target == null) {
      throw Exception("target is null");
    }
    return withinRadiusPosition(target, radius);
  }

  void setDestinationToCurrentPosition(){
    runX = x;
    runY = y;
    runZ = z;
  }

  void clearPath(){
    pathIndex = -1;
    pathStart = -1;
    pathTargetIndex = -1;
    pathTargetIndexPrevious = -1;
  }

  bool shouldAttackTarget() {
    final target = this.target;
    return
        target is IsometricCollider &&
        targetIsEnemy &&
        target.hitable &&
        targetWithinAttackRange;
  }

  void attackTargetEnemy(IsometricGame game){
    final target = this.target;
    if (target == null) return;
    idle();
    face(target);
    faceTarget();

    if (characterTypeTemplate){
      game.characterUseWeapon(this);
    } else {
      setCharacterStatePerforming(duration: weaponCooldown);
    }
  }

  void idle() {
    setCharacterStateIdle();
    setDestinationToCurrentPosition();
  }

  void faceTarget() {
    final target = this.target;
    if (target == null) return;
    face(target);
    lookAt(target);
  }

}
