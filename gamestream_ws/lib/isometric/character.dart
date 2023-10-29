import 'dart:typed_data';

import 'package:gamestream_ws/isometric/consts/caste_action_frame_percentage.dart';
import 'package:gamestream_ws/isometric/isometric_game.dart';
import 'package:gamestream_ws/packages.dart';

import 'collider.dart';
import 'consts/fire_action_frame_percentage.dart';
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

  var spawnLootOnDeath = true;
  var respawnDurationTotal = 30;
  var gender = Gender.female;
  var headType = HeadType.boy;
  var shoeType = ShoeType.None;
  var hairType = HairType.none;
  var hairColor = 0;
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
  // var attackDuration = 0;
  // var attackActionFrame = 0;
  var weaponHitForce = 10.0;
  var weaponRecoil = 0.25;
  var weaponType = WeaponType.Unarmed;
  var weaponDamage = 1;
  var weaponRange = 20.0;
  var weaponCooldown = 0;
  var characterState = CharacterState.Idle;
  var frame = 0;
  var runSpeed = 1.0;
  var name = "";
  var pathCurrent = -1;
  var pathStart = -1;
  var pathTargetIndex = -1;
  var pathTargetIndexPrevious = -1;
  var action = CharacterAction.Idle;
  var _goal = CharacterGoal.Idle;
  var forceAttack = false;

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
    this.invincible = false,
  }) : super(
    radius: CharacterType.getRadius(characterType),
    materialType: MaterialType.Flesh,
  ) {
    maxHealth = health;
    this.weaponType = weaponType;
    this.characterType = characterType;
    this.health = health;
    this.team = team;

    if (name != null){
      this.name = name;
    }
    enabledFixed = false;
    physical = true;
    hitbox = true;
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
    characterState,
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

  bool get dead => characterState == CharacterState.Dead;

  bool get deadOrInactive => dead || !active;

  bool get alive => !dead;

  bool get targetIsEnemy => target == null ? false : isEnemy(target);

  bool get targetIsAlly => target == null ? false : isAlly(target);

  bool get running => characterState == CharacterState.Running;

  bool get firing => characterState == CharacterState.Fire;

  bool get striking => characterState == CharacterState.Strike;

  bool get idling => characterState == CharacterState.Idle;

  bool get characterStateIdle => characterState == CharacterState.Idle;

  bool get characterStateHurt => characterState == CharacterState.Hurt;

  bool get characterStateChanging => characterState == CharacterState.Changing;

  bool get busy =>
      actionDuration > 0 &&
      (!characterStateHurt || hurtStateBusy);

  bool get deadOrBusy => dead || busy;

  bool get deadInactiveOrBusy => dead || !active || busy;

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

  void setCharacterStateSpawning({int duration = 40}){
    if (characterState == CharacterState.Spawning)
      return;

    x = startPositionX;
    y = startPositionY;
    z = startPositionZ;
    active = true;
    health = maxHealth;
    physical = true;
    hitbox = true;
    characterState = CharacterState.Spawning;
    frame = 0;
    actionDuration = duration;
  }

  void setCharacterStateChanging({int duration = 15}) {
    if (deadOrBusy)
      return;

    characterState = CharacterState.Changing;
    frame = 0;
    actionDuration = duration;
  }

  void setCharacterStateHurt({int duration = 10}){
    if (dead || characterState == CharacterState.Hurt || !hurtable)
      return;

    characterState = CharacterState.Hurt;
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

  void faceRunDestination() {
    if (z != runZ){
      final diff = z - runZ;
      runX += diff;
      runY += diff;
      runZ = z;
    }
    faceXY(runX, runY);
  }

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
    if (target == null) {
      throw Exception('target == null');
    }
    faceTarget();
    game.characterAttack(this);
  }

  void idle() {
    setCharacterStateIdle();
    setDestinationToCurrentPosition();
  }

  void faceTarget() {
    final target = this.target;
    if (target == null) {
      throw Exception('target is null');
    }
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

    characterState = CharacterState.Idle;
    frame = 0;
    actionDuration = -1;
  }

  @override
  double get order => dead ? super.order - 25 : super.order;
  
  int get templateDataA => compressBytesToUInt64(
      weaponType,
      bodyType,
      helmType,
      legsType,
      handTypeLeft,
      handTypeRight,
      hairType,
      hairColor,
    );

  int get templateDataB => compressBytesToUInt64(
    complexion,
    shoeType,
    gender,
    headType,
    0,
    0,
    0,
    0,
  );

  @override
  bool onSameTeam(dynamic that, {bool neutralMeansTrue = true}) {

      if (identical(this, that)) {
        return true;
      }

      if (that is! Collider) {
        return false;
      }

      final thisTeam = this.team;

      if (thisTeam == TeamType.Alone) {
        return false;
      }

      if (thisTeam == TeamType.Neutral) {
        return neutralMeansTrue;
      }

      final thatTeam = that.team;

      if (thatTeam == TeamType.Alone) {
        return false;
      }

      if (thisTeam == TeamType.Neutral) {
        return neutralMeansTrue;
      }

      return thisTeam == thatTeam;
  }

  void setCharacterStateCasting({
    required int duration,
  }){
    if (deadInactiveOrBusy){
      return;
    }
    actionFrame = (duration * casteActionFramePercentage).toInt();
    setDestinationToCurrentPosition();
    setCharacterState(
      value: CharacterState.Casting,
      duration: duration,
    );
  }

  void setCharacterStateFire({
    required int duration,
  }){
    if (deadInactiveOrBusy){
      return;
    }
    if (duration <= 0){
      throw Exception('invalid duration');
    }
    actionFrame = (duration * fireActionFramePercentage).toInt();
    setDestinationToCurrentPosition();
    setCharacterState(
      value: CharacterState.Fire,
      duration: duration,
    );
  }

  void setCharacterStateStriking({
    required int duration,
    // required int actionFrame,
  }){
    if (deadInactiveOrBusy){
      return;
    }

    const actionFramePercentage = 0.6;
    this.actionFrame = (duration * actionFramePercentage).toInt();
    setDestinationToCurrentPosition();
    setCharacterState(
      value: CharacterState.Strike,
      duration: duration,
    );
  }

  void setCharacterStateIdle({int duration = 0}){
    if (
      deadOrInactive ||
      characterStateIdle
    ) return;

    setDestinationToCurrentPosition();
    setCharacterState(
      value: CharacterState.Idle,
      duration: duration,
    );
  }

  void setCharacterStateRunning() =>
    setCharacterState(
      value: CharacterState.Running,
      duration: 0,
    );

  void setCharacterState({
    required int value,
    required int duration,
  }) {
    assert (duration >= 0);
    assert (value != CharacterState.Dead); // use game.setCharacterStateDead
    assert (value != CharacterState.Hurt); // use character.setCharacterStateHurt

    if (characterState == value || deadInactiveOrBusy) {
      return;
    }

    characterState = value;
    frame = 0;
    this.actionDuration = duration;
  }


}
