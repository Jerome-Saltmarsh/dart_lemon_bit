import 'dart:typed_data';

import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/isometric/isometric_game.dart';
import 'package:gamestream_server/lemon_math.dart';

import 'isometric_collider.dart';
import 'isometric_position.dart';
import 'isometric_settings.dart';

abstract class IsometricCharacter extends IsometricCollider {
  /// between 0 and 1. 0 means very accurate and 1 is very inaccurate
  var _weaponAccuracy = 0.0;
  var _angle = 0.0;
  var _health = 1;
  var _maxHealth = 1;

  var _weaponState = WeaponState.Idle;

  var targetPerceptible = false;
  var canSetCharacterStateHurt = true;
  var clearTargetAfterAttack = true;
  var characterType = 0;
  var weaponStateDurationTotal = 0;
  var autoTarget = true;
  var autoTargetRange = 300.0;
  var autoTargetTimer = 0;
  var autoTargetTimerDuration = 100;

  var weaponRecoil = 0.25;
  var weaponType = WeaponType.Unarmed;
  var weaponDamage = 1;
  var weaponRange = 20.0;
  var weaponStateDuration = 0;
  var weaponCooldown = 0;
  var state = CharacterState.Idle;
  var stateDurationRemaining = 0;
  var stateDuration = 0;
  var nextFootstep = 0;
  var framesPerAnimation = 6;
  var lookRadian = 0.0;
  var runSpeed = 1.0;
  var name = "";
  var pathCurrent = -1;
  var pathStart = -1;
  var pathTargetIndex = -1;
  var pathTargetIndexPrevious = -1;
  var action = CharacterAction.Idle;
  var goal = CharacterGoal.Idle;

  var aiDelayAfterPerformFinished = true;
  var aiDelayAfterPerformFinishedMin = 25;
  var aiDelayAfterPerformFinishedMax = 200;

  var arrivedAtDestination = false;
  var runToDestinationEnabled = true;
  var runInDirectionEnabled = true;
  var pathFindingEnabled = true;
  var runX = 0.0;
  var runY = 0.0;
  var runZ = 0.0;

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

  int get compressedLookAndWeaponState => (lookDirection << 4) | weaponState;

  int get compressedAnimationFrameAndDirection =>
      animationFrame | direction << 5;

  int get animationFrame => (stateDuration ~/ framesPerAnimation) % 32;

  int get compressedState => compressBytesToUInt32(
    characterType,
    state,
    team,
    (healthPercentage * 255).toInt(),
  );


  int get weaponState => _weaponState;

  bool get pathSet => pathTargetIndex >= 0;

  bool get targetWithinCollectRange {
    final target = this.target;
    if (target == null)
      throw Exception();

    return withinRadiusPosition(target, IsometricSettings.Collect_Radius);
  }

  set weaponState(int value){
    if (_weaponState == value)
      return;

    _weaponState = value;
    weaponStateDuration = 0;
    weaponStateDurationTotal = getWeaponStateDurationTotal(value);
  }

  bool get shouldUpdatePath =>
      (pathTargetIndex != pathTargetIndexPrevious) || (pathCurrent == 0);

  double get weaponRangeSquared => weaponRange * weaponRange;

  int get pathCurrentIndex => path[pathCurrent];

  int get lookDirection => IsometricDirection.fromRadian(lookRadian);

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

  bool get characterTypeTemplate => characterType == CharacterType.Template;

  bool get dead => state == CharacterState.Dead;

  bool get deadOrInactive => dead || !active;

  bool get alive => !dead;

  bool get targetIsEnemy => target == null ? false : isEnemy(target);

  bool get targetIsAlly => target == null ? false : isAlly(target);

  bool get weaponStateBusy => weaponState != WeaponState.Aiming && weaponStateDurationTotal > 0;

  bool get running => state == CharacterState.Running;

  bool get performing => state == CharacterState.Performing;

  bool get idling => state == CharacterState.Idle;

  bool get characterStateIdle => state == CharacterState.Idle;

  bool get characterStateHurt => state == CharacterState.Hurt;

  bool get characterStatePerforming => state == CharacterState.Performing;

  bool get characterStateChanging => state == CharacterState.Changing || weaponState == WeaponState.Changing;

  bool get busy => stateDurationRemaining > 0;

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

  double get angle => _angle;

  double get weaponDurationPercentage =>
      weaponStateDurationTotal == 0 || weaponStateAiming
          ? 1
          : weaponStateDuration / weaponStateDurationTotal;

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

  int getWeaponStateDurationTotal(int weaponState) =>
      switch (weaponState) {
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

  void setCharacterStateChanging() {
    state = CharacterState.Changing;
    stateDurationRemaining = 15;
  }

  void setCharacterStateHurt(){
    if (dead) return;
    if (state == CharacterState.Hurt) return;
    if (!canSetCharacterStateHurt) return;
    stateDurationRemaining = 10;
    state = CharacterState.Hurt;
    stateDuration = 0;
  }

  void setCharacterStateIdle(){
    if (deadOrBusy) return;
    if (characterStateIdle) return;
    setCharacterState(value: CharacterState.Idle, duration: 0);
  }

  void aiIdle(){
    if (!aiDelayAfterPerformFinished || deadBusyOrWeaponStateBusy) return;
    setCharacterState(
      value: CharacterState.Idle,
      duration: randomInt(
          aiDelayAfterPerformFinishedMin, aiDelayAfterPerformFinishedMax),
    );
  }

  void setCharacterState({required int value, required int duration}) {
    assert (duration >= 0);
    assert (value != CharacterState.Dead); // use game.setCharacterStateDead
    assert (value != CharacterState.Hurt); // use character.setCharacterStateHurt
    if (state == value) return;
    if (deadOrBusy) return;
    stateDurationRemaining = duration;
    state = value;
    stateDuration = 0;
  }

  bool withinInteractRange(IsometricPosition target){
    if ((target.z - z).abs() > Character_Height)
      return false;
    if (target is IsometricCollider) {
      return withinRadiusPosition(target, Interact_Radius + target.radius);
    }
    return withinRadiusPosition(target, Interact_Radius);
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
    lookRadian = getAngleXY(x, y);
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

    if (weaponStateDuration < weaponStateDurationTotal) {
      weaponStateDuration++;
      if (weaponStateDuration == weaponStateDurationTotal) {

        if (clearTargetAfterAttack && const [WeaponState.Melee, WeaponState.Firing].contains(weaponState)){
          clearTarget();
        }
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
  void customOnUpdate() {}

  void customOnDead() {}

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
