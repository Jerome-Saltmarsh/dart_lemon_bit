import 'dart:math';
import 'dart:typed_data';


import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/isometric/isometric_game.dart';
import 'package:bleed_server/isometric/isometric_scene.dart';
import 'package:lemon_math/library.dart';

import 'isometric_collider.dart';
import 'isometric_player.dart';
import 'isometric_position.dart';
import 'isometric_settings.dart';

abstract class IsometricCharacter extends IsometricCollider {
  /// between 0 and 1. 0 means very accurate and 1 is very inaccurate
  var _accuracy = 0.0;
  /// TODO BELONGS IN isometric_character_template.dart
  var _faceAngle = 0.0;
  var _health = 1;
  var _maxHealth = 1;
  var _weaponStateDurationTotal = 0;
  var _weaponType = ItemType.Empty;
  var _characterType = 0;

  var weaponDamage = 1;
  var weaponRange = 20.0;
  var weaponState = WeaponState.Idle;
  var weaponStateDuration = 0;
  var state = CharacterState.Idle;
  var stateDurationRemaining = 0;
  var stateDuration = 0;
  var nextFootstep = 0;
  var animationFrame = 0;
  var lookRadian = 0.0;
  var runSpeed = 1.0;
  var name = "";
  var pathIndex = 0;
  var pathStart = 0;
  var pathTargetIndex = 0;
  var targetIndex = 0;

  var runPositionX = 0.0;
  var runDestinationY = 0.0;
  var runDestinationZ = 0.0;

  IsometricPosition? target;

  final path = Uint32List(20);

  IsometricCharacter({
    required int characterType,
    required int health,
    required int weaponType,
    required int team,
    required int damage,
    double x = 0,
    double y = 0,
    double z = 0,
    String? name,
  }) : super(
    x: x,
    y: y,
    z: z,
    radius: CharacterType.getRadius(characterType),
  ) {
    maxHealth = health;
    this.weaponType = weaponType;
    this.characterType = characterType;
    this.health = health;
    this.team = team;
    this.weaponDamage = damage;
    if (name != null){
      this.name = name;
    }
    fixed = false;
    physical = true;
    hitable = true;
    radius = CharacterType.getRadius(characterType);
    setDestinationToCurrentPosition();
  }

  bool get runDestinationWithinRadiusRunSpeed => runDestinationWithinRadius(runSpeed);

  double get weaponRangeSquared => weaponRange * weaponRange;

  int get pathNodeIndex => path[pathIndex];

  /// throws an exception if target is null
  bool get targetWithinAttackRange {
    final target = this.target;
    if (target == null){
      throw Exception('target == null');
    }
    return withinAttackRange(target);
  }

  // int get buffByte {
  //   var buff = 0;
  //   if (buffInvincible) {
  //     buff = buff | 0x00000001;
  //   }
  //   if (buffDoubleDamage) {
  //     buff = buff | 0x00000002;
  //   }
  //   if (buffInvisible) {
  //     buff = buff | 0x00000004;
  //   }
  //   return buff;
  // }

  int get weaponType => _weaponType;

  bool get isPlayer => false;

  bool get aliveAndActive => alive && active;

  int get weaponStateDurationTotal => _weaponStateDurationTotal;

  set weaponType(int value){
    assert (value == ItemType.Empty || ItemType.isTypeWeapon(value));
    if (_weaponType == value) return;
    _weaponType = value;
    onWeaponTypeChanged();
  }

  set weaponStateDurationTotal(int value){
    assert (value >= 0);
    if (value > 0){
      weaponStateDuration = value;
      _weaponStateDurationTotal = value;
    }
  }

  int get characterType => _characterType;

  bool get isTemplate => _characterType == CharacterType.Template;

  set characterType(int value){
    _characterType = value;
    radius = CharacterType.getRadius(value);
    if (value != CharacterType.Template) {
      weaponType = ItemType.Empty;
    }
  }

  double get accuracy => _accuracy;

  bool get characterTypeZombie => characterType == CharacterType.Zombie;

  bool get characterTypeTemplate => characterType == CharacterType.Template;

  bool get dead => state == CharacterState.Dead;

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
  bool get weaponStateBusy => weaponStateDuration > 0 && weaponState != WeaponState.Aiming;

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

  bool get weaponStateAiming => weaponState == WeaponState.Aiming;

  double get healthPercentage => health / maxHealth;

  double get faceAngle => _faceAngle;

  double get weaponDurationPercentage =>  weaponStateDurationTotal == 0 || weaponStateAiming ? 0 : weaponStateDuration / weaponStateDurationTotal;

  int get weaponFrame {
    assert (weaponStateDuration == 0 || weaponStateDurationTotal > 0);
    assert (weaponStateDurationTotal - weaponStateDuration >= 0);
    return weaponStateDurationTotal - weaponStateDuration;
  }

  int get faceDirection => IsometricDirection.fromRadian(_faceAngle);

  int get health => _health;

  int get maxHealth => _maxHealth;

  int get weaponTypeCooldown => ItemType.getCooldown(weaponType);

  /// SETTERS

  set accuracy(double value) {
    _accuracy = clamp01(value);
  }

  set maxHealth(int value){
    if (_maxHealth == value) return;
    assert (value > 0);
    _maxHealth = value;
    if (this is IsometricPlayer){
      (this as IsometricPlayer).writePlayerHealth();
    }
    if (_health > _maxHealth) {
      health = _maxHealth;
    }
  }

  set health (int value) {
    final clampedValue = clamp(value, 0, maxHealth);
    if (clampedValue == _health) return;
    _health = clampedValue;
    if (this is IsometricPlayer){
      (this as IsometricPlayer).writePlayerHealth();
    }
  }

  void set faceDirection(int value) =>
        faceAngle = IsometricDirection.toRadian(value);

  void set faceAngle(double value){
    if (value < 0){
      _faceAngle = pi2 - (-value % pi2);
      return;
    }
    if (value > pi2){
      _faceAngle = value % pi2;
      return;
    }
    _faceAngle = value;
  }

  /// METHODS
  void assignWeaponStateChanging() {
      weaponState = WeaponState.Changing;
      weaponStateDurationTotal = 20;
  }

  void assignWeaponStateFiring() {
    weaponState = WeaponState.Firing;
    weaponStateDurationTotal = ItemType.getCooldown(weaponType);
    assert (weaponStateDurationTotal > 0);
  }

  void assignWeaponStateThrowing() {
    weaponState = WeaponState.Throwing;
    weaponStateDurationTotal = IsometricSettings.Weapon_State_Duration_Throw;
    assert (weaponStateDurationTotal > 0);
  }

  void assignWeaponStateMelee() {
    weaponState = WeaponState.Melee;
    weaponStateDurationTotal = IsometricSettings.Weapon_State_Duration_Melee;
    assert (weaponStateDurationTotal > 0);
  }

  void assignWeaponStateReloading(){
    weaponState = WeaponState.Reloading;
    weaponStateDurationTotal = 30;
    if (this is IsometricPlayer) {
      (this as IsometricPlayer).writePlayerEvent(PlayerEvent.Reloading);
    }
  }

  void assignWeaponStateIdle() {
    weaponState = WeaponState.Idle;
    weaponStateDurationTotal = 0;
    weaponStateDuration = 0;
  }

  void assignWeaponStateAiming() {
    weaponState = WeaponState.Aiming;
    weaponStateDurationTotal = 10;
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
    if ((target.z - z).abs() > Character_Height) return false;
    if (target is IsometricCollider) {
      return withinRadiusPosition(target, weaponRange + target.radius);
    }
    return withinRadiusPosition(target, weaponRange);
  }

  void face(Position position) => faceXY(position.x, position.y);

  void faceXY(double x, double y) {
    if (deadOrBusy) return;
    faceAngle = getAngleXY(x, y) + pi;
  }

  double getAngleXY(double x, double y) =>
      getAngleBetween(this.x, this.y, x, y);

  void setCharacterStateRunning()=>
      setCharacterState(value: CharacterState.Running, duration: 0);

  void updateAccuracy() {
    final change = 0.01;
    final targetAccuracy = 0;
    // final targetAccuracy = running ? 0.5 : 0;
    final difference = accuracy - targetAccuracy;
    if (difference.abs() < change) return;
    if (difference > 0) {
      accuracy -= change;
    } else {
      accuracy += change;
    }
  }

  /// safe to override
  void onWeaponTypeChanged() {}

  /// safe to override
  void customOnUpdate() {}

  void customOnHurt(){ }

  void customOnDead() {}

  bool runDestinationWithinRadius(double radius) =>
      withinRadiusXYZ(runPositionX, runDestinationY, runDestinationZ, radius);

  void runToDestination(){
    if (runDestinationWithinRadiusRunSpeed) return;
    faceRunDestination();
    setCharacterStateRunning();
  }

  void faceRunDestination() => faceXY(runPositionX, runDestinationY);

  void clearTarget(){
    target = null;
  }

  /// throws an exception if target is null
  void setDestinationToTarget() {
    final target = this.target;
    if (target == null) {
      throw Exception('target is null');
    }
    runPositionX = target.x;
    runDestinationY = target.y;
    runDestinationZ = target.z;
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
    runPositionX = x;
    runDestinationY = y;
    runDestinationZ = z;
  }

  void clearPath(){
    pathIndex = 0;
    pathStart = 0;
  }

  bool shouldAttackTargetEnemy(IsometricScene scene) {
    final target = this.target;
    if (target == null) return false;
    if (target is! IsometricCollider) return false;
    if (!target.hitable) return false;
    if (!targetIsEnemy) return false;
    if (!enemyTargetWithinAttackRange) return false;
    return targetIsPerceptible(scene);
  }

  bool targetIsPerceptible(IsometricScene scene) {
    final target = this.target;

    if (target == null)
      return false;

    var positionX = x;
    var positionY = y;
    var angle = target.getAngle(this);

    final distance = getDistance3(target);
    final jumpSize = Node_Size_Quarter;
    final jumps = distance ~/ jumpSize;
    final velX = getAdjacent(angle, jumpSize);
    final velY = getOpposite(angle, jumpSize);

    for (var i = 0; i < jumps; i++) {
      positionX += velX;
      positionY += velY;
      final nodeOrientation = scene.getNodeOrientationXYZ(positionX, positionY, z);
      if (nodeOrientation != NodeOrientation.None){
        return false;
      }
    }
    return true;
  }

  bool get enemyTargetWithinAttackRange {
    final target = this.target;
    if (target == null) return false;
    if (!isEnemy(target)) return false;
    return getDistanceSquared(target) < weaponRangeSquared;
  }

  void attackTargetEnemy(IsometricGame game){
    final target = this.target;
    if (target == null) return;
    idle();
    face(target);
    game.characterUseWeapon(this);
  }

  void idle() {
    setCharacterStateIdle();
    setDestinationToCurrentPosition();
  }


}
