import 'dart:typed_data';
import 'package:gamestream_server/packages.dart';
import 'package:gamestream_server/isometric/isometric_game.dart';

import 'collider.dart';
import 'isometric_settings.dart';
import 'position.dart';

class Character extends Collider {

  static const maxAnimationFrames = 32;
  static const maxAnimationDeathFrames = maxAnimationFrames - 2;

  /// between 0 and 1. 0 means very accurate and 1 is very inaccurate
  var _weaponAccuracy = 0.0;
  var _angle = 0.0;
  var _health = 1;
  var _maxHealth = 1;

  var complexion = 0;
  var hurtStateBusy = true;
  var interacting = false;
  var targetPerceptible = false;
  var hurtable = true;
  var clearTargetOnPerformAction = true;
  var characterType = 0;
  var autoTarget = true;
  var autoTargetRange = 300.0;
  var autoTargetTimer = 0;
  var autoTargetTimerDuration = 100;

  var invincible = false;
  var actionDuration = -1;
  var actionFrame = -1;
  var attackDuration = 0;
  var attackActionFrame = 0;
  var weaponHitForce = 10.0;
  var weaponRecoil = 0.25;
  var weaponType = WeaponType.Unarmed;
  var weaponDamage = 1;
  var weaponRange = 20.0;
  var weaponCooldown = 0;
  var state = CharacterState.Idle;
  var frame = 0;
  var runSpeed = 1.0;
  var name = "";
  var pathCurrent = -1;
  var pathStart = -1;
  var pathTargetIndex = -1;
  var pathTargetIndexPrevious = -1;
  var action = CharacterAction.Idle;
  var _goal = CharacterGoal.Idle;
  var forceShot = false;

  int get goal => _goal;

  set goal(int value){
    if (_goal == value)
      return;

    _goal = value;
  }

  var arrivedAtDestination = false;
  var runToDestinationEnabled = true;
  var pathFindingEnabled = true;
  var runX = 0.0;
  var runY = 0.0;
  var runZ = 0.0;

  var helmType = HelmType.None;
  var bodyType = BodyType.None;
  var legsType = LegType.None;
  var handTypeLeft = HandType.None;
  var handTypeRight = HandType.None;

  Position? target;

  var doesWander = false;
  var nextWander = 0;
  var wanderRadius = 3;
  var attackAlwaysHitsTarget = false;

  final path = Uint32List(20);

  Character({
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

  int get compressedAnimationFrameAndDirection =>
      animationFrame | direction << 5;

  int get framesPerAnimation => characterStateChanging ? 1 : 3;

  int get animationFrame {
    return (frame ~/ framesPerAnimation) % maxAnimationFrames;
  }

  double get actionCompletionPercentage =>
      actionDuration <= 0 ? 0 : frame / actionDuration;

  int get compressedState => compressBytesToUInt32(
    characterType,
    state,
    team,
    (healthPercentage * 255).toInt(),
  );

  bool get shouldPerformAction => actionFrame > 0 && frame == actionFrame;

  bool get pathSet => pathTargetIndex >= 0 && pathCurrent >= 0;

  bool get targetWithinCollectRange {
    final target = this.target;
    if (target == null)
      throw Exception();

    return withinRadiusPosition(target, IsometricSettings.Collect_Radius);
  }

  bool get shouldUpdatePath =>
      (pathTargetIndex != pathTargetIndexPrevious) || (pathCurrent == 0);

  double get weaponRangeSquared => weaponRange * weaponRange;

  int get pathCurrentIndex => path[pathCurrent];

  bool get targetWithinAttackRange {
    final target = this.target;
    if (target == null){
      return throw Exception('target == null');
    }
    return withinAttackRange(target);
  }

  bool get isPlayer => false;

  bool get aliveAndActive => alive && active;

  double get weaponAccuracy => _weaponAccuracy;

  bool get characterTypeTemplate =>
      characterType == CharacterType.Kid;

  bool get dead => state == CharacterState.Dead;

  bool get deadOrInactive => dead || !active;

  bool get alive => !dead;

  bool get targetIsEnemy => target == null ? false : isEnemy(target);

  bool get targetIsAlly => target == null ? false : isAlly(target);

  bool get running => state == CharacterState.Running;

  bool get firing => state == CharacterState.Fire;

  bool get striking => state == CharacterState.Strike;

  bool get idling => state == CharacterState.Idle;

  bool get characterStateIdle => state == CharacterState.Idle;

  bool get characterStateHurt => state == CharacterState.Hurt;

  bool get characterStateChanging => state == CharacterState.Changing;

  bool get busy =>
      actionDuration > 0 &&
      (!characterStateHurt || hurtStateBusy);

  bool get deadOrBusy => dead || busy;

  bool get canChangeEquipment => !dead || characterStateChanging;

  bool get targetSet => target != null;

  double get healthPercentage => (health / maxHealth).clamp(0, 1.0);

  double get angle => _angle;

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

  void setCharacterStateFire({
    required int duration,
    required int actionFrame,
  }){
    assert (active);
    assert (alive);
    assert (duration > 0);
    assert (actionFrame < duration);

    this.actionFrame = actionFrame;
    setDestinationToCurrentPosition();
    setCharacterState(value: CharacterState.Fire, duration: duration);
  }

  void setCharacterStateSpawning({int duration = 40}){
    if (state == CharacterState.Spawning)
      return;

    x = startX;
    y = startY;
    z = startZ;
    active = true;
    health = maxHealth;
    physical = true;
    hitable = true;
    state = CharacterState.Spawning;
    frame = 0;
    actionDuration = duration;
  }

  void setCharacterStateChanging({int duration = 15}) {
    if (deadOrBusy)
      return;

    state = CharacterState.Changing;
    frame = 0;
    actionDuration = duration;
  }

  void setCharacterStateHurt({int duration = 10}){
    if (dead || state == CharacterState.Hurt || !hurtable)
      return;

    state = CharacterState.Hurt;
    frame = 0;
    actionDuration = duration;
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
    actionDuration = duration;
  }

  bool withinInteractRange(Position target){
    if ((target.z - z).abs() > Character_Height)
      return false;
    if (target is Collider) {
      return withinRadiusPosition(target, Interact_Radius + target.radius);
    }
    return withinRadiusPosition(target, Interact_Radius);
  }

  bool withinAttackRangeAndAngle(Collider collider){
    if (!withinAttackRange(collider)){
      return false;
    }
    final angle = this.getAngle(collider);
    final angleD = angleDiff(angle, angle);
    return angleD < piQuarter; // TODO Replace constant with weaponAngleRange
  }

  bool withinAttackRange(Position target){
    if ((target.z - z).abs() > Character_Height)
      return false;
    if (target is Collider) {
      return withinRadiusPosition(target, weaponRange + target.radius);
    }
    return withinRadiusPosition(target, weaponRange);
  }

  void face(Position position) => faceXY(position.x, position.y);

  void lookAt(Position position) => lookAtXY(position.x, position.y);

  void lookAtTarget(){
    final target = this.target;
    if (target != null) {
       lookAt(target);
    }
  }

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
    game.characterAttack(this);
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
    if (!runToDestinationEnabled || deadOrBusy)
      return;
    runX = x;
    runY = y;
    runZ = z;
    arrivedAtDestination = false;
  }

  void clearAction(){
    if (dead)
      return;

    state = CharacterState.Idle;
    frame = 0;
    actionDuration = -1;
  }

  @override
  double get order => dead ? super.order - 25 : super.order;
}
