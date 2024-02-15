import 'dart:math';
import 'dart:typed_data';

import 'package:amulet_engine/isometric/consts/caste_action_frame_percentage.dart';
import 'package:amulet_engine/isometric/consts/fire_action_frame_percentage.dart';
import 'package:lemon_bits/src.dart';
import 'package:lemon_math/src.dart';

import '../../common/src.dart';
import '../consts/isometric_settings.dart';
import 'collider.dart';
import 'isometric_game.dart';
import 'position.dart';



class Character extends Collider {

  static const maxAnimationFrames = 32;
  static const maxAnimationDeathFrames = maxAnimationFrames - 2;

  /// between 0 and 1. 0 means very accurate and 1 is very inaccurate
  var _angle = 0.0;
  var _health = 1;
  var _maxHealth = 1;
  var _goal = CharacterGoal.Idle;

  var ailmentColdDuration = 0;
  var ailmentBurningDamage = 0;
  var ailmentBurningDuration = 0;
  var ailmentBurningRadius = 50.0;
  Character? ailmentBurningSrc;

  bool get isAilmentCold => ailmentColdDuration > 0;

  bool get isAilmentBurning => ailmentBurningDuration > 0;

  /// in seconds
  var respawnDurationTotal = (60 * 3);
  // var respawnDurationTotal = 20;
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
  var attackDamage = 1;
  var attackRange = 20.0;
  var characterState = CharacterState.Idle;
  var frame = 0.0;
  var frameVelocity = 1.0;
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
    required this.attackDamage,
    required this.attackRange,
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

  int get animationFrame => (frame ~/ 3).toInt() % maxAnimationFrames;

  double get actionCompletionPercentage =>
      actionDuration <= 0 ? 0 : (frame / actionDuration).clamp(0, 1);

  bool get shouldPerformAction => actionFrame > 0 &&
      frame < actionFrame &&
      frame + frameVelocity >= actionFrame;

  bool get shouldPerformStart => actionFrame > 0 && frame == 0;

  bool get shouldPerformEnd =>  actionDuration > 0 && frame >= actionDuration;

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

  double get weaponRangeSquared => attackRange * attackRange;

  int get pathCurrentIndex => path[pathCurrent];

  bool get targetWithinAttackRange {
    final target = this.target;
    if (target == null){
      return throw Exception('target == null');
    }
    return withinWeaponRange(target);
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

  int get healthPercentageByte => (healthPercentage * 255).toInt();

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
    actionDuration = duration;
    clearFrame();
  }

  void setCharacterStateChanging({int duration = 15}) {
    if (deadOrBusy) {
      return;
    }

    characterState = CharacterState.Changing;
    actionDuration = duration;
    clearFrame();
  }

  void setCharacterStateHurt({int duration = 10}){
    if (dead || characterState == CharacterState.Hurt || !hurtable) {
      return;
    }

    characterState = CharacterState.Hurt;
    actionDuration = duration;
    clearFrame();
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
    if (!withinWeaponRange(collider)){
      return false;
    }
    final angle = getAngle(collider);
    final angleD = angleDiff(angle, angle);
    return angleD < piQuarter; // TODO Replace constant with weaponAngleRange
  }

  bool withinWeaponRange(Position target) => withinStrikeRadius(target, attackRange);

  /// calculates the difference in radians between the characters face direction and another position
  double getFaceAngleDiff(Position position){
    return angleDiff(position.getAngle(this), angle);
  }

  bool withinStrikeRadius(Position target, double radius){
    if ((target.z - z).abs() > Character_Height) {
      return false;
    }
    if (target is Collider) {
      return withinRadiusPosition(target, radius + target.radius);
    }
    return withinRadiusPosition(target, radius);
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

    updateAilments();

    if (
      runToDestinationEnabled &&
      !arrivedAtDestination &&
      withinRadiusXYZ(runX, runY, runZ, 8)
    ){
       setDestinationToCurrentPosition();
    }
  }

  void updateAilments() {
     if (ailmentColdDuration > 0) {
      ailmentColdDuration--;
    }

    if (ailmentBurningDuration > 0) {
      ailmentBurningDuration--;
      if (ailmentBurningDuration == 0){
        ailmentBurningSrc = null;
      }
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
    actionDuration = -1;
    clearFrame();
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
    actionDuration = duration;
    clearFrame();
  }


  void attack() {
    clearPath();

    if (WeaponType.isBow(weaponType)) {
      setCharacterStateFire(
        duration: attackDuration, // TODO
      );
    }

    if (WeaponType.isMelee(weaponType)){
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

  int get characterTypeAndTeam => characterType | team << 6;

  int get compressedAilments {
    return writeBits(isAilmentCold, isAilmentBurning, false, false, false, false, false, false);
  }

  void applyFrameVelocity() {
    frame += frameVelocity * getAilmentVelocity();
  }

  double getAilmentVelocity(){
     if (isAilmentCold) {
       return 0.5;
     }
     return 1.0;
  }

  void clearFrame() => frame = 0;

}
