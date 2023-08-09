import 'dart:typed_data';

import 'package:gamestream_server/lemon_bits.dart';
import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/isometric/isometric_game.dart';
import 'package:gamestream_server/lemon_math.dart';

import 'isometric_collider.dart';
import 'isometric_position.dart';
import 'isometric_settings.dart';

class IsometricCharacter extends IsometricCollider {


  /// between 0 and 1. 0 means very accurate and 1 is very inaccurate
  var _weaponAccuracy = 0.0;
  var _angle = 0.0;
  var _health = 1;
  var _maxHealth = 1;

  var strikeDuration = 0;
  var strikeActionFrame = 0;

  var weaponHitForce = 10.0;
  var hurtStateBusy = true;
  var interacting = false;
  var targetPerceptible = false;
  /// can have a characterState of type hurt
  var hurtable = true;
  var clearTargetOnPerformAction = true;
  var characterType = 0;
  var weaponStateDurationTotal = 0;
  var autoTarget = true;
  var autoTargetRange = 300.0;
  var autoTargetTimer = 0;
  var autoTargetTimerDuration = 100;

  var actionFrame = -1;
  var weaponRecoil = 0.25;
  var weaponType = WeaponType.Unarmed;
  var weaponDamage = 1;
  var weaponRange = 20.0;
  // var weaponStateDuration = 0;
  var weaponCooldown = 0;
  var state = CharacterState.Idle;
  var frame = 0;
  var frameDuration = -1;
  var nextFootstep = 0;
  var framesPerAnimation = 3;
  // var lookRadian = 0.0;
  var runSpeed = 1.0;
  var name = "";
  var pathCurrent = -1;
  var pathStart = -1;
  var pathTargetIndex = -1;
  var pathTargetIndexPrevious = -1;
  var action = CharacterAction.Idle;
  var goal = CharacterGoal.Idle;

  var arrivedAtDestination = false;
  var runToDestinationEnabled = true;
  var pathFindingEnabled = true;
  var runX = 0.0;
  var runY = 0.0;
  var runZ = 0.0;

  var headType = HeadType.None;
  var bodyType = BodyType.None;
  var legsType = LegType.None;
  var handTypeLeft = HandType.None;
  var handTypeRight = HandType.None;

  IsometricPosition? target;

  var doesWander = false;
  var nextWander = 0;
  var wanderRadius = 3;
  var attackAlwaysHitsTarget = false;

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
    this.runSpeed = 1.0,
    this.doesWander = false,
    this.actionFrame = -1,
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

    if (doesWander) {
      nextWander = randomInt(50, 300);
    }
  }

  // int get compressedLookAndWeaponState => (direction << 4) | weaponState;
  int get compressedLookAndWeaponState => (direction << 4) | 0; // TODO remove 0

  int get compressedAnimationFrameAndDirection =>
      animationFrame | direction << 5;

  int get animationFrame => (frame ~/ framesPerAnimation) % 32;

  int get compressedState => compressBytesToUInt32(
    characterType,
    state,
    team,
    (healthPercentage * 255).toInt(),
  );

  bool get shouldPerformAction => actionFrame > 0 && frame == actionFrame;

  // int get weaponState => _weaponState;

  bool get pathSet => pathTargetIndex >= 0 && pathCurrent >= 0;

  bool get targetWithinCollectRange {
    final target = this.target;
    if (target == null)
      throw Exception();

    return withinRadiusPosition(target, IsometricSettings.Collect_Radius);
  }

  // set weaponState(int value){
  //   if (_weaponState == value)
  //     return;
  //
  //   _weaponState = value;
  //   weaponStateDuration = 0;
  // }

  bool get shouldUpdatePath =>
      (pathTargetIndex != pathTargetIndexPrevious) || (pathCurrent == 0);

  double get weaponRangeSquared => weaponRange * weaponRange;

  int get pathCurrentIndex => path[pathCurrent];

  // int get lookDirection => IsometricDirection.fromRadian(lookRadian);

  bool get targetWithinAttackRange {
    final target = this.target;
    if (target == null){
      return throw Exception('target == null');
    }
    return withinAttackRange(target);
  }

  bool get isPlayer => false;

  bool get aliveAndActive => alive && active;

  bool get isTemplate => characterType == CharacterType.Template;

  double get weaponAccuracy => _weaponAccuracy;

  // TODO REMOVE
  bool get characterTypeZombie => characterType == CharacterType.Zombie;

  bool get characterTypeTemplate =>
      characterType == CharacterType.Template ||
      characterType == CharacterType.Kid;

  bool get dead => state == CharacterState.Dead;

  bool get deadOrInactive => dead || !active;

  bool get alive => !dead;

  bool get targetIsEnemy => target == null ? false : isEnemy(target);

  bool get targetIsAlly => target == null ? false : isAlly(target);

  // bool get weaponStateBusy => weaponState != WeaponState.Aiming && weaponStateDurationTotal > 0;

  bool get running => state == CharacterState.Running;

  bool get striking => state == CharacterState.Strike;

  bool get idling => state == CharacterState.Idle;

  bool get characterStateIdle => state == CharacterState.Idle;

  bool get characterStateHurt => state == CharacterState.Hurt;

  bool get characterStateChanging => state == CharacterState.Changing;

  bool get busy =>
      frameDuration > 0 &&
      frame < frameDuration &&
      (!characterStateHurt || hurtStateBusy);

  bool get deadOrBusy => dead || busy;

  bool get deadBusyOrWeaponStateBusy => dead;

  bool get canChangeEquipment => !deadBusyOrWeaponStateBusy || characterStateChanging;

  bool get targetSet => target != null;

  // bool get weaponStateIdle => weaponState == WeaponState.Idle;
  //
  // bool get weaponStateReloading => weaponState == WeaponState.Reloading;
  //
  // bool get weaponStatePerforming => weaponState == WeaponState.Performing;
  //
  // bool get weaponStateAiming => weaponState == WeaponState.Aiming;

  double get healthPercentage => health / maxHealth;

  double get angle => _angle;

  // double get weaponDurationPercentage =>
  //     weaponStateDurationTotal == 0 || weaponStateAiming
  //         ? 1
  //         : weaponStateDuration / weaponStateDurationTotal;

  int get direction => IsometricDirection.fromRadian(_angle);

  int get health => _health;

  int get maxHealth => _maxHealth;

  set weaponAccuracy(double value) {
    _weaponAccuracy = clamp01(value);
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

  void set direction(int value) =>
        angle = IsometricDirection.toRadian(value);

  void set angle(double value) =>
      _angle = value % pi2;

  // int getWeaponStateDurationTotal(int weaponState) =>
  //     switch (weaponState) {
  //       WeaponState.Idle => 0,
  //       WeaponState.Aiming => 10,
  //       WeaponState.Reloading => 10,
  //       WeaponState.Performing => 10, // TODO
  //       _ => (throw Exception(''))
  //     };

  void assignWeaponStateReloading({int duration = 30}){
    // weaponState = WeaponState.Reloading;
    weaponStateDurationTotal = duration;
  }

  void setCharacterStateStriking({
    required int duration,
    required int actionFrame,
  }){
    assert (active);
    assert (alive);
    this.actionFrame = actionFrame;
    setDestinationToCurrentPosition();
    setCharacterState(value: CharacterState.Strike, duration: duration);
  }

  void setCharacterStateSpawning({int duration = 40}){
    if (state == CharacterState.Spawning)
      return;

    state = CharacterState.Spawning;
    frame = 0;
    frameDuration = duration;
  }

  void setCharacterStateChanging({int duration = 15}) {
    if (deadBusyOrWeaponStateBusy)
      return;

    state = CharacterState.Changing;
    frame = 0;
    frameDuration = duration;
  }

  void setCharacterStateHurt({int duration = 10}){
    if (dead || state == CharacterState.Hurt || !hurtable)
      return;

    state = CharacterState.Hurt;
    frame = 0;
    frameDuration = duration;
  }

  void setCharacterStateIdle({int duration = 0}){
    if (deadOrBusy || characterStateIdle)
      return;

    setCharacterState(value: CharacterState.Idle, duration: duration);
  }

  void setCharacterState({required int value, required int duration}) {
    assert (duration >= 0);
    assert (value != CharacterState.Dead); // use game.setCharacterStateDead
    assert (value != CharacterState.Hurt); // use character.setCharacterStateHurt
    if (state == value || deadOrBusy)
      return;

    state = value;
    frame = 0;
    frameDuration = duration;
  }

  bool withinInteractRange(IsometricPosition target){
    if ((target.z - z).abs() > Character_Height)
      return false;
    if (target is IsometricCollider) {
      return withinRadiusPosition(target, Interact_Radius + target.radius);
    }
    return withinRadiusPosition(target, Interact_Radius);
  }

  bool withinAttackRangeAndAngle(IsometricCollider collider){
    if (!withinAttackRange(collider)){
      return false;
    }
    final angle = this.getAngle(collider);
    final angleD = angleDiff(angle, angle);
    return angleD < piQuarter; // TODO Replace constant with weaponAngleRange
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
    angle = getAngleXY(x, y);
  }

  void lookAtXY(double x, double y) {
    if (deadOrBusy) return;
    angle = getAngleXY(x, y);
  }

  double getAngleXY(double x, double y) =>
      angleBetween(this.x, this.y, x, y);

  void setCharacterStateRunning()=>
      setCharacterState(value: CharacterState.Running, duration: 0);

  void update() {
    const change = 0.01;

    if (weaponAccuracy.abs() > change){
      if (weaponAccuracy > 0) {
        weaponAccuracy -= change;
      } else {
        weaponAccuracy += change;
      }
    }

    if (runToDestinationEnabled && !arrivedAtDestination && withinRadiusXYZ(runX, runY, runZ, 8)){
       setDestinationToCurrentPosition();
    }

    // if (weaponStateDuration < weaponStateDurationTotal) {
    //   weaponStateDuration++;
    //   if (weaponStateDuration >= weaponStateDurationTotal) {
    //
    //     if (weaponStatePerforming && WeaponType.isFirearm(weaponType)){
    //       weaponState = WeaponState.Aiming;
    //       weaponStateDurationTotal = 10;
    //     } else {
    //       weaponState = WeaponState.Idle;
    //       weaponStateDurationTotal = 0;
    //     }
    //   }
    // }
  }

  void runStraightToTarget(){
    action = CharacterAction.Run_To_Target;
    if (pathFindingEnabled){
      clearPath();
    }
    setRunDestinationToTarget();
    runToDestination();
  }

  void runToDestination(){
    faceRunDestination();
    setCharacterStateRunning();
  }

  void faceRunDestination() => faceXY(runX, runY);

  void clearTarget(){
    target = null;
  }

  void onTargetDead(){
    clearTarget();
    clearPath();
    setDestinationToCurrentPosition();
    setCharacterStateIdle();
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
    arrivedAtDestination = true;
  }

  void clearPath(){
    pathCurrent = -1;
    pathStart = -1;
    pathTargetIndex = -1;
    pathTargetIndexPrevious = -1;
  }

  bool runDestinationWithinRadius(double runRadius) => withinRadiusXYZ(runX, runY, runZ, runRadius);

  void attackTargetEnemy(IsometricGame game){
    final target = this.target;
    if (target == null) return;
    setDestinationToCurrentPosition();
    clearPath();
    idle();
    faceTarget();
    game.characterStrike(this);
  }

  void idle() {
    setCharacterStateIdle();
    setDestinationToCurrentPosition();
  }

  void faceTarget() {
    final target = this.target;
    if (target == null)
      throw Exception('target is null');
    face(target);
    lookAt(target);
  }

  void setRunDestinationToTarget(){
    final target = this.target;
    if (target == null)
      throw Exception();
    setRunDestination(target.x, target.y, target.z);
  }



  void setRunDestination(double x, double y, double z) {
    if (!runToDestinationEnabled || deadBusyOrWeaponStateBusy)
      return;
    runX = x;
    runY = y;
    runZ = z;
    arrivedAtDestination = false;
  }
}
