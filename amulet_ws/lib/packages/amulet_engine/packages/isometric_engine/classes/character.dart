import 'dart:math';
import 'dart:typed_data';

import '../isometric_engine.dart';
import '../consts/isometric_settings.dart';

class Character extends Collider {

  static const maxAnimationFrames = 32;
  static const maxAnimationDeathFrames = maxAnimationFrames - 2;

  /// between 0 and 1. 0 means very accurate and 1 is very inaccurate
  var _angle = 0.0;
  var _health = 1;
  var _maxHealth = 1;
  var _goal = CharacterGoal.Idle;

  /// in seconds
  var respawnDurationTotal = (60 * 3);
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
  var autoTargetTimerDuration = 60;
  var invincible = false;
  var actionDuration = -1;
  var attackDuration = 0;
  var actionFrame = -1;
  var weaponHitForce = 10.0;
  var weaponType = WeaponType.Unarmed;
  var weaponDamage = 1;
  var weaponRange = 20.0;
  var weaponCooldown = 0;
  var characterState = CharacterState.Idle;
  var frame = 0;
  var runSpeed = 1.0;
  @override
  var name = "";
  var pathCurrent = -1;
  var pathStart = -1;
  var pathTargetIndex = -1;
  var pathTargetIndexPrevious = -1;
  var action = CharacterAction.Idle;
  var forceAttack = false;
  var arrivedAtDestination = false;
  var runToDestinationEnabled = true;
  var pathFindingEnabled = true;
  var runX = 0.0;
  var runY = 0.0;
  var runZ = 0.0;
  var helmType = HelmType.None;
  var armorType = ArmorType.None;
  var roamEnabled = false;
  var roamNext = 0;
  var roamRadius = 2;
  var chanceOfSetTarget = 0.5;
  var maxFollowDistance = 500.0;

  final path = Uint32List(20);

  Position? target;

  Character({
    required super.x,
    required super.y,
    required super.z,
    required super.team,
    required this.characterType,
    required this.weaponType,
    required this.weaponDamage,
    required this.weaponRange,
    required this.weaponCooldown,
    required this.attackDuration,
    required int health,
    String? name,
    this.runSpeed = 1.0,
    this.roamEnabled = false,
    this.actionFrame = -1,
    this.invincible = false,
    super.radius = 10,
  }) : super(
    materialType: MaterialType.Flesh,
  ) {
    maxHealth = health;
    this.health = health;

    if (name != null){
      this.name = name;
    }
    fixed = false;
    physical = true;
    hitable = true;
    setDestinationToCurrentPosition();

    if (roamEnabled) {
      roamNext = randomInt(50, 300);
    }
  }

  int get goal => _goal;

  set goal(int value){
    if (_goal == value) {
      return;
    }
    _goal = value;
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
    if (target == null) {
      throw Exception();
    }

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

  bool get characterTypeTemplate =>
      characterType == CharacterType.Human;

  bool get dead => characterState == CharacterState.Dead;

  bool get deadOrInactive => dead || !active;

  bool get alive => !dead;

  bool get targetIsEnemy => target == null ? false : isEnemy(target);

  bool get targetIsAlly => target == null ? false : isAlly(target);

  bool get running => characterState == CharacterState.Running;

  bool get firing => characterState == CharacterState.Fire;

  bool get striking =>
      const [CharacterState.Strike_1, CharacterState.Strike_2].contains(characterState);

  bool get idling => characterState == CharacterState.Idle;

  bool get characterStateIdle => characterState == CharacterState.Idle;

  bool get characterStateAttacking => const [
    CharacterState.Strike_1,
    CharacterState.Strike_2,
    CharacterState.Fire,
  ].contains(characterState);

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

  set maxHealth(int value){
    if (value <= 0) return;
    if (_maxHealth == value) {
      return;
    }
    _maxHealth = value;
    if (_health > _maxHealth) {
      health = _maxHealth;
    }
  }

  set health (int value) => _health = clamp(value, 0, maxHealth);

  set direction(int value) =>
        angle = IsometricDirection.toRadian(value);

  set angle(double value) =>
      _angle = value % pi2;

  void setCharacterStateSpawning({int duration = 40}){
    if (characterState == CharacterState.Spawning) {
      return;
    }

    active = true;
    health = maxHealth;
    physical = true;
    hitable = true;
    characterState = CharacterState.Spawning;
    frame = 0;
    actionDuration = duration;
  }

  void setCharacterStateChanging({int duration = 15}) {
    if (deadOrBusy) {
      return;
    }

    characterState = CharacterState.Changing;
    frame = 0;
    actionDuration = duration;
  }

  void setCharacterStateHurt({int duration = 10}){
    if (dead || characterState == CharacterState.Hurt || !hurtable) {
      return;
    }

    characterState = CharacterState.Hurt;
    frame = 0;
    actionDuration = duration;
  }



  bool withinInteractRange(Position target){
    if ((target.z - z).abs() > Character_Height) {
      return false;
    }
    if (target is Collider) {
      return withinRadiusPosition(target, Interact_Radius + target.radius);
    }
    return withinRadiusPosition(target, Interact_Radius);
  }

  bool withinAttackRangeAndAngle(Collider collider){
    if (!withinAttackRange(collider)){
      return false;
    }
    final angle = getAngle(collider);
    final angleD = angleDiff(angle, angle);
    return angleD < piQuarter; // TODO Replace constant with weaponAngleRange
  }

  bool withinAttackRange(Position target){
    if ((target.z - z).abs() > Character_Height) {
      return false;
    }
    if (target is Collider) {
      return withinRadiusPosition(target, weaponRange + target.radius);
    }
    return withinRadiusPosition(target, weaponRange);
  }

  void faceTarget() {
    final target = this.target;
    if (target != null) {
      facePosition(target);
    }
  }

  void facePosition(Position position, {bool force = false}) =>
      faceXY(position.x, position.y, force: force);

  void faceXY(double x, double y, {bool force = false}) {
    if (!force && deadOrBusy) return;
    angle = (getAngleXY(x, y) + pi) % pi2;
  }

  void update() {
    if (
      runToDestinationEnabled &&
      !arrivedAtDestination &&
      withinRadiusXYZ(runX, runY, runZ, 8)
    ){
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

  void setRunDestinationToStart() =>
      setRunDestination(startPositionX, startPositionY, startPositionZ);

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
    attack();
  }

  void setRunDestinationToTarget(){
    final target = this.target;
    if (target == null) {
      throw Exception();
    }
    setRunDestination(target.x, target.y, target.z);
  }

  void setRunDestination(double x, double y, double z) {
    if (!runToDestinationEnabled) {
      return;
    }

    runX = x;
    runY = y;
    runZ = z;
    arrivedAtDestination = false;
  }

  void clearAction(){
    if (dead) {
      return;
    }

    characterState = CharacterState.Idle;
    frame = 0;
    actionDuration = -1;
  }

  @override
  double get order => dead ? super.order - 25 : super.order;
  
  int get templateDataA => compressBytesToUInt32(
    weaponType,
    armorType,
    helmType,
    0, // TODO this was legsType
  );

  int get templateDataB => compressBytesToUInt32(
    complexion,
    shoeType,
    gender,
    headType,
  );

  int get templateDataC => compressBytesToUInt32(
    0, // TODO this was handTypeLeft
    0, // TODO this was handTypeRight,
    hairType,
    hairColor,
  );

  @override
  bool onSameTeam(dynamic a, {bool neutralMeansTrue = true}) {

      if (identical(this, a)) {
        return true;
      }

      if (a is! Collider) {
        return false;
      }

      final thisTeam = team;

      if (thisTeam == TeamType.Alone) {
        return false;
      }

      if (thisTeam == TeamType.Neutral) {
        return neutralMeansTrue;
      }

      final thatTeam = a.team;

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
    setActionFrame((duration * casteActionFramePercentage).toInt());
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
  }){
    if (deadInactiveOrBusy){
      return;
    }

    const actionFramePercentage = 0.6;
    actionFrame = (duration * actionFramePercentage).toInt();
    setDestinationToCurrentPosition();
    setCharacterState(
      value: randomItem(CharacterState.strikes),
      duration: duration,
    );
  }

  void setCharacterStateIdle({int duration = 0}){
    if (
      deadOrInactive ||
          (characterStateIdle && actionDuration >= duration)
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

    if (deadInactiveOrBusy){
      return;
    }

    if (characterState == value && duration <= actionDuration) {
      return;
    }

    characterState = value;
    frame = 0;
    actionDuration = duration;
  }


  void attack() {
    clearPath();

    if (weaponType == WeaponType.Bow) {
      setCharacterStateFire(
        duration: attackDuration, // TODO
      );
    } else {
      setCharacterStateStriking(
        duration: attackDuration, // TODO
      );
    }
  }

  void clearActionFrame(){
    setActionFrame(-1);
  }

  void setActionFrame(int value) {
    actionFrame = value;
  }

}
