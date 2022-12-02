import 'dart:math';

import 'package:lemon_math/library.dart';

import 'package:bleed_server/gamestream.dart';

abstract class Character extends Collider {
  /// VARIABLES
  var _faceAngle = 0.0;
  var _health = 1;
  var _maxHealth = 1;
  var damage = 1;
  var state = CharacterState.Idle;
  var stateDurationRemaining = 0;
  var stateDuration = 0;
  var animationFrame = 0;
  var frozenDuration = 0;
  Position3? target;
  var invincible = false;
  var weaponState = WeaponState.Idle;
  var weaponStateDuration = 0;
  var weaponStateDurationTotal = 0;
  var weaponType = ItemType.Empty;
  var bodyType = ItemType.Body_Shirt_Cyan;
  var headType = ItemType.Head_Steel_Helm;
  var legsType = ItemType.Legs_Blue;
  var performX = 0.0;
  var performY = 0.0;
  var performZ = 0.0;
  var characterType = 0;
  var lookRadian = 0.0;

  /// PROPERTIES
  bool get characterTypeZombie => characterType == CharacterType.Zombie;
  bool get dead => state == CharacterState.Dead;
  bool get dying => state == CharacterState.Dying;
  bool get alive => !deadOrDying;
  bool get deadOrDying => dead || dying;
  bool get targetIsNull => target == null;
  bool get targetIsEnemy {
    if (target == null) return false;
    if (target == this) return false;
    if (target is Collider == false) return false;
    final targetTeam = (target as Collider).team;
    if (targetTeam == 0) return true;
    return team != targetTeam;
  }
  bool get targetIsAlly {
    if (target == null) return false;
    if (target == this) return true;
    if (target is Collider == false) return false;
    final targetTeam = (target as Collider).team;
    if (targetTeam == 0) return false;
    return team == targetTeam;
  }
  bool get weaponStateBusy => weaponStateFiring || weaponStateReloading;
  bool get running => state == CharacterState.Running;
  bool get idling => state == CharacterState.Idle;
  bool get characterStateIdle => state == CharacterState.Idle;
  bool get busy => stateDurationRemaining > 0;
  bool get deadOrBusy => dying || dead || busy;
  bool get deadBusyOrWeaponStateBusy => dying || dead || weaponStateBusy;
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
  double get weaponDurationPercentage =>  weaponStateDurationTotal == 0 || weaponStateAiming ? 0 : weaponStateDuration / weaponStateDurationTotal;
  double get equippedRange => ItemType.getRange(weaponType);

  int get weaponFrame => weaponStateDurationTotal - weaponStateDuration;
  int get faceDirection => Direction.fromRadian(_faceAngle);
  int get health => _health;
  int get maxHealth => _maxHealth;
  int get weaponTypeCooldown => ItemType.getCooldown(weaponType);
  int get equippedAttackDuration => 25;

  /// SETTERS

  set maxHealth(int value){
    if (_maxHealth == value) return;
    assert (value > 0);
    _maxHealth = value;
    if (_health > _maxHealth){
      _health = _maxHealth;
    }
  }

  set health (int value) {
    if (_health == value) return;
    _health = clamp(value, 0, maxHealth);
    if (this is Player){
      (this as Player).writePlayerHealth();
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
      weaponStateDuration = weaponStateDurationTotal;
  }

  void assignWeaponStateFiring() {
    weaponState = WeaponState.Firing;
    weaponStateDurationTotal = ItemType.getCooldown(weaponType);
    assert (weaponStateDurationTotal > 0);
    weaponStateDuration = weaponStateDurationTotal;
  }

  void assignWeaponStateReloading(){
    weaponState = WeaponState.Reloading;
    weaponStateDurationTotal = 30;
    weaponStateDuration = weaponStateDurationTotal;
    if (this is Player) {
      (this as Player).writePlayerEvent(PlayerEvent.Reloading);
    }
  }

  void assignWeaponStateIdle() {
    weaponState = WeaponState.Idle;
    weaponStateDurationTotal = 0;
    weaponStateDuration = weaponStateDurationTotal;
  }

  void assignWeaponStateAiming() {
    weaponState = WeaponState.Aiming;
    weaponStateDurationTotal = 60;
    weaponStateDuration = weaponStateDurationTotal;
  }

  // void write(Player player);

    Character({
    required this.characterType,
    required int health,
    required this.bodyType,
    required this.headType,
    required this.weaponType,
    required int team,
    required int damage,
    double speed = 5.0,
    double x = 0,
    double y = 0,
    double z = 0,

  }) : super(x: x, y: y, z: z, radius: 7) {
    maxHealth = health;
    this.health = health;
    this.team = team;
    this.damage = damage;
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

  bool withinAttackRange(Position3 target){
    if (target is Collider){
      return withinRadius(target, equippedRange + (target.radius * 0.5));
    }
    return withinRadius(target, equippedRange);
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

  void updateMovement() {
    z -= velocityZ;
    const gravity = 0.98;
    velocityZ += gravity;
    const minVelocity = 0.005;
    if (velocitySpeed <= minVelocity) return;
    x += velocityX;
    y += velocityY;
    applyFriction(0.75);
  }
}
