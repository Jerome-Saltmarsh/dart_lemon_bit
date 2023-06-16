import 'dart:math';
import 'dart:typed_data';


import 'package:bleed_server/common/src/character_state.dart';
import 'package:bleed_server/common/src/character_type.dart';
import 'package:bleed_server/common/src/direction.dart';
import 'package:bleed_server/common/src/item_type.dart';
import 'package:bleed_server/common/src/node_orientation.dart';
import 'package:bleed_server/common/src/node_size.dart';
import 'package:bleed_server/common/src/player_event.dart';
import 'package:bleed_server/common/src/weapon_state.dart';
import 'package:bleed_server/src/games/isometric/isometric_scene.dart';
import 'package:lemon_math/library.dart';

import 'isometric_collider.dart';
import 'isometric_player.dart';
import 'isometric_position.dart';
import 'isometric_settings.dart';

abstract class IsometricCharacter extends IsometricCollider {
  /// between 0 and 1. 0 means very accurate and 1 is very inaccurate
  var _accuracy = 0.0;
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
  var buffDuration = 0;
  var lookRadian = 0.0;
  var runSpeed = 1.0;
  var name = "";
  var buffInvincible      = false;
  var buffDoubleDamage    = false;
  var buffInvisible       = false;

  IsometricPosition? target;

  // PATHFINDING

  static final visitedNodes = Uint32List(10000);
  static var visitedNodesIndex = 0;

  final path = Uint32List(20);

  var pathIndex = 0;
  var pathEnd = 0;
  var targetIndex = 0;
  var targetIndexRow = 0;
  var targetIndexColumn = 0;

  var destinationX = 0.0;
  var destinationY = 0.0;
  var destinationZ = 0.0;

  double get weaponRangeSquared => weaponRange * weaponRange;

  void setPathToIsometricPosition(
      IsometricScene scene,
      IsometricPosition position,
  ) =>
      setPathToNodeIndex(scene, scene.getNodeIndexV3(position));

  void setPathToNodeIndex(IsometricScene scene, int targetIndex) {

    this.targetIndex = targetIndex;
    targetIndexRow = scene.getNodeIndexRow(targetIndex);
    targetIndexColumn = scene.getNodeIndexColumn(targetIndex);
    final targetIndexZ = scene.getNodeIndexZ(targetIndex);

    assert(scene.getNodeIndex(targetIndexZ, targetIndexRow, targetIndexColumn) == targetIndex);

    visitedNodesIndex = 0;
    pathIndex = 0;
    pathEnd = 0;
    if (visitNode(indexRow, indexColumn, indexZ, scene)){
      pathEnd = pathIndex;
      pathIndex = 0;
      destinationX = scene.getNodePositionX(path[0]);
      destinationY = scene.getNodePositionY(path[0]);
      assert(validatePath(scene));
    } else {
      pathIndex = 0;
      pathEnd = 0;
      destinationX = x;
      destinationY = y;
    }
  }

  bool validatePath(IsometricScene scene) {
    if (pathEnd <= 0) return true;
    for (var i = 0; i < pathEnd; i++){
      if (scene.nodeOrientations[path[i]] == NodeOrientation.None) continue;
      return false;
    }
    return true;
  }

  bool visitNode(int row, int column, int z, IsometricScene scene){
    if (row < 0)
      return false;
    if (column < 0)
      return false;
    if (z < 0)
      return false;
    if (row >= scene.gridRows)
      return false;
    if (column >= scene.gridColumns)
      return false;
    if (z >= scene.gridHeight)
      return false;

    final index = scene.getNodeIndex(z, row, column);

    assert (scene.getNodeIndexRow(index) == row);
    assert (scene.getNodeIndexColumn(index) == column);

    if (index == targetIndex) {
      return true;
    }

    if (index < 0) return false;
    if (index >= scene.nodeOrientations.length) return false;

    final nodeOrientation = scene.nodeOrientations[index];
    if (nodeOrientation != NodeOrientation.None) {
      return false;
    }

    for (var i = 0; i < visitedNodesIndex; i++){
      if (visitedNodes[i] == index) {
        return false;
      }
    }

    visitedNodes[visitedNodesIndex] = index;
    visitedNodesIndex++;


    if (pathIndex > 0){
      final pathI = path[pathIndex - 1];
      final pathIRow = scene.getNodeIndexRow(pathI);
      final pathJRow = scene.getNodeIndexRow(index);
      final pathIColumn = scene.getNodeIndexRow(pathI);
      final pathJColumn = scene.getNodeIndexRow(index);

      if ((pathIRow - pathJRow).abs() > 1){
        return false;
      }
      if ((pathIColumn - pathJColumn).abs() > 1){
        return false;
      }
    }

    path[pathIndex] = index;
    pathIndex++;
    final cachePathIndex = pathIndex;

    if (pathIndex >= path.length)
      return true;

    final targetDirection = convertToDirection(targetIndexRow - row, targetIndexColumn - column);

    if (visitNode(row + convertDirectionToRowVel(targetDirection), column + convertDirectionToColumnVel(targetDirection), z, scene)){
      return true;
    }
    pathIndex = cachePathIndex;

    for (var i = 1; i <= 3; i++){
      final dirLess = (targetDirection - i) % 8;
      if (visitNode(row + convertDirectionToRowVel(dirLess), column + convertDirectionToColumnVel(dirLess), z, scene)){
        return true;
      }
      pathIndex = cachePathIndex;
      final dirMore = (targetDirection + i) % 8;
      if (visitNode(row + convertDirectionToRowVel(dirMore), column + convertDirectionToColumnVel(dirMore), z, scene)){
        return true;
      }
      pathIndex = cachePathIndex;
    }

    final dirOpp = (targetDirection + 4) % 8;
    return visitNode(row + convertDirectionToRowVel(dirOpp), column + convertDirectionToColumnVel(dirOpp), z, scene);
  }

  int convertToDirection(int diffRows, int diffCols){
    if (diffRows > 0){
      if (diffCols < 0) return 1;
      if (diffCols > 0) return 3;
      return 2;
    }

    if (diffRows < 0) {
      if (diffCols < 0) return 7;
      if (diffCols > 0) return 5;
      return 6;
    }

    if (diffCols < 0) return 0;
    return 4;
  }

  int convertDirectionToColumnVel(int direction)=> switch(direction){
        0 => -1,
        1 => -1,
        2 => 0,
        3 => 1,
        4 => 1,
        5 => 1,
        6 => 0,
        7 => -1,
        _ => throw Exception('invalid direction $direction'),
     };

  int convertDirectionToRowVel(int direction) => switch(direction){
    0 => 0,
    1 => 1,
    2 => 1,
    3 => 1,
    4 => 0,
    5 => -1,
    6 => -1,
    7 => -1,
    _ => throw Exception('invalid direction $direction'),
  };


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
  }

  int get buffByte {
    var buff = 0;
    if (buffInvincible) {
      buff = buff | 0x00000001;
    }
    if (buffDoubleDamage) {
      buff = buff | 0x00000002;
    }
    if (buffInvisible) {
      buff = buff | 0x00000004;
    }
    return buff;
  }

  int get weaponType => _weaponType;
  bool get isPlayer => false;
  bool get aliveAndActive => alive && active;

  set weaponType(int value){
    assert (value == ItemType.Empty || ItemType.isTypeWeapon(value));
    if (_weaponType == value) return;
    _weaponType = value;
    onWeaponTypeChanged();
  }

  int get weaponStateDurationTotal => _weaponStateDurationTotal;

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

  /// PROPERTIES
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
  bool get characterStateChanging => state == CharacterState.Changing || weaponState == WeaponState.Changing;
  bool get busy => stateDurationRemaining > 0;
  bool get deadOrBusy => dead || busy;
  bool get deadBusyOrWeaponStateBusy => dead || weaponStateBusy;
  bool get canChangeEquipment => !deadBusyOrWeaponStateBusy || characterStateChanging || weaponStateAiming;
  bool get equippedTypeIsBow => weaponType == ItemType.Weapon_Ranged_Bow;
  bool get equippedTypeIsStaff => weaponType == ItemType.Weapon_Melee_Staff;
  bool get unarmed => weaponType == ItemType.Empty;
  bool get equippedTypeIsShotgun => weaponType == ItemType.Weapon_Ranged_Shotgun;
  bool get equippedIsMelee => ItemType.isTypeWeaponMelee(weaponType);
  bool get equippedIsEmpty => false;
  bool get targetSet => target != null;

  bool get weaponStateIdle => weaponState == WeaponState.Idle;
  bool get weaponStateReloading => weaponState == WeaponState.Reloading;
  bool get weaponStateFiring => weaponState == WeaponState.Firing;
  bool get weaponStateAiming => weaponState == WeaponState.Aiming;

  double get healthPercentage => health / maxHealth;
  double get faceAngle => _faceAngle;
  double get weaponTypeRange => ItemType.getRange(weaponType);
  double get weaponTypeRangeMelee => ItemType.getMeleeAttackRadius(weaponType);
  double get weaponDurationPercentage =>  weaponStateDurationTotal == 0 || weaponStateAiming ? 0 : weaponStateDuration / weaponStateDurationTotal;

  int get weaponFrame {
    assert (weaponStateDuration == 0 || weaponStateDurationTotal > 0);
    assert (weaponStateDurationTotal - weaponStateDuration >= 0);
    return weaponStateDurationTotal - weaponStateDuration;
  }

  int get faceDirection => Direction.fromRadian(_faceAngle);
  int get health => _health;
  int get maxHealth => _maxHealth;
  int get weaponTypeCooldown => ItemType.getCooldown(weaponType);
  int get equippedAttackDuration => 25;

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
        faceAngle = Direction.toRadian(value);

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

  bool withinAttackRange(IsometricPosition target){
    if ((target.z - z).abs() > Character_Height) return false;
    if (target is IsometricCollider){
      return withinRadiusCheap(target, weaponTypeRange + target.radius);
    }
    return withinRadiusCheap(target, weaponTypeRange);
  }

  void face(Position position) {
    assert(!deadOrBusy);
    faceAngle = this.getAngle(position) + pi;
  }

  void faceXY(double x, double y) {
    assert(!deadOrBusy);
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
  void onEquipmentChanged() {}

  /// safe to override
  void onWeaponTypeChanged() {}

  /// safe to override
  void customUpdate() {}
}
