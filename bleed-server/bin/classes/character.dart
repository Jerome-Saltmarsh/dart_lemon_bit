import 'package:lemon_math/library.dart';

import '../common/character_type.dart';
import '../common/library.dart';
import '../functions/withinRadius.dart';
import '../utilities.dart';
import 'collider.dart';
import 'game.dart';
import 'player.dart';
import 'position3.dart';
import 'power.dart';
import 'components.dart';
import 'weapon.dart';

abstract class Character extends Collider with Team, Velocity, Material {

  Game game;

  var _health = 1;
  var maxHealth = 1;

  bool get dead => _health <= 0;

  bool get alive => _health > 0;

  int get health => _health;

  double get healthPercentage => health / maxHealth;

  set health(int value) {
    _health = clampInt(value, 0, maxHealth);
  }
  var type = CharacterType.Template;
  late double movementSpeed;
  Power? ability = null;
  var state = CharacterState.Idle;
  var stateDurationRemaining = 0;
  var stateDuration = 0;
  var wanderPause = randomInt(300, 500);
  var animationFrame = 0;
  var frozenDuration = 0;
  /// the character that was highlighted as the character began attacking
  /// This forces a hit to occur even if the target goes out of range of the attack
  Position3? target;
  var invincible = false;
  Weapon equippedWeapon;
  var equippedArmour = ArmourType.shirtCyan;
  var equippedHead = HeadType.None;
  var equippedPants = PantsType.white;

  bool get running => state == CharacterState.Running;
  bool get idling => state == CharacterState.Idle;
  bool get characterStateIdle => state == CharacterState.Idle;
  bool get busy => stateDurationRemaining > 0;
  bool get deadOrBusy => dead || busy;
  bool get equippedTypeIsBow => equippedWeapon.type == WeaponType.Bow;
  bool get equippedTypeIsStaff => equippedWeapon.type == WeaponType.Staff;
  bool get unarmed => equippedWeapon.type == WeaponType.Unarmed;
  bool get equippedTypeIsShotgun => equippedWeapon.type == WeaponType.Shotgun;
  bool get equippedIsMelee => WeaponType.isMelee(equippedWeapon.type);
  bool get equippedIsEmpty => false;
  int get equippedLevel => 1;
  int get equippedAttackDuration => 25;
  int get equippedDamage => equippedWeapon.damage;
  double get equippedRange => WeaponType.getRange(equippedWeapon.type);

  void write(Player player);

  Character({
    required double x,
    required double y,
    required double z,
    required int health,
    required this.game,
    required this.equippedWeapon,
    double speed = 5.0,
    int team = Teams.none,
    this.equippedArmour = ArmourType.tunicPadded,
    this.equippedHead = HeadType.None,

  }) : super(x: x, y: y, z: z, radius: 7) {
    maxHealth = health;
    this.health = health;
    movementSpeed = speed;
    this.team = team;
    this.material = MaterialType.Flesh;
    setCharacterStateSpawning();
  }

  void applyVelocity() {
     if (speed > movementSpeed) return;
     speed = movementSpeed;
  }

  void customUpdateCharacter(Game game){

  }

  void onPlayerRemoved(Player player) {

  }

  void onDeath(){

  }

  void clearAbility(){
    ability = null;
  }

  void clearTarget(){
    target = null;
  }

  void attackTarget(Position3 target) {
    if (deadOrBusy) return;
    face(target);
    setCharacterStatePerforming(duration: equippedAttackDuration);
    this.target = target;
  }

  bool getCollisionInDirection({required Game game, required double angle, required double distance}){
    return game.scene.getCollisionAt(x + getAdjacent(angle, distance), y + getOpposite(angle, distance), z + tileHeightHalf);
  }

  int getGridTypeInDirection({required Game game, required double angle, required double distance}){
    return game.scene.getNodeXYZ(x + getAdjacent(angle, distance), y + getOpposite(angle, distance), z + tileHeightHalf).type;
  }

  void updateCharacter(Game game){
    if (dead) return;
    if (!busy){
      customUpdateCharacter(game);
    }
    updateMovement(game);
    updateCharacterState(game);
    game.scene.resolveCharacterTileCollision(this, game);
  }

  void updateCharacterState(Game game){
    if (stateDurationRemaining > 0) {
        stateDurationRemaining--;
        if (stateDurationRemaining == 0) {
          return setCharacterStateIdle();
        }
    }
    switch (state) {
      case CharacterAction.Idle:
        speed *= 0.75;
        break;
      case CharacterState.Running:
        applyVelocity();
        if (stateDuration % 10 == 0) {
          game.dispatch(GameEventType.Footstep, x, y, z);
        }
        break;
      case CharacterState.Performing:
        game.updateCharacterStatePerforming(this);
        break;
    }
    stateDuration++;
  }

  void setCharacterStatePerforming({required int duration}){
    setCharacterState(value: CharacterState.Performing, duration: duration);
  }

  void setCharacterStateRunning(){
    setCharacterState(value: CharacterState.Running, duration: 0);
    // if (stateDuration == 0) {
    //   dispatch(GameEventType.Spawn_Dust_Cloud);
    // }
  }

  void setCharacterStateSpawning(){
    state = CharacterState.Spawning;
    stateDurationRemaining = 66;
  }

  void setCharacterStateHurt(){
    if (dead) return;
    stateDurationRemaining = 10;
    state = CharacterState.Hurt;
    ability = null;
    onCharacterStateChanged();
  }

  void setCharacterStateIdle(){
    if (deadOrBusy) return;
    if (characterStateIdle) return;
    setCharacterState(value: CharacterState.Idle, duration: 0);
    target = null;
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

  void dispatch(int gameEventType, [double angle = 0]){
     game.dispatch(gameEventType, x, y, z, angle);
  }

  void onCharacterStateChanged(){
    stateDuration = 0;
    animationFrame = 0;
  }

  void updateMovement(Game game) {
    const minVelocity = 0.005;
    if (speed <= minVelocity) return;

    x += xv;
    y += yv;

    final type = getGridTypeInDirection(game: game, angle: angle, distance: radius);
    if (type == NodeType.Tree_Bottom || type == NodeType.Torch) {
      final nodeCenterX = indexRow * tileSize + tileSizeHalf;
      final nodeCenterY = indexColumn * tileSize + tileSizeHalf;
      final dis = getDistanceXY(nodeCenterX, nodeCenterY);
      const treeRadius = 5;
      final overlap = dis - treeRadius - radius;
      if (overlap < 0) {
        x -= getAdjacent(angle, overlap);
        y -= getOpposite(angle, overlap);
      }
    }

    speed *= 0.75; // friction
  }

  bool withinAttackRange(Position3 target){
    if (target is Collider){
      return withinRadius(this, target, equippedRange + (target.radius * 0.5));
    }
    return withinRadius(this, target, equippedRange);
  }

  void face(Position position) {
    assert(!deadOrBusy);
    angle = this.getAngle(position);
  }
}

bool onSameTeam(dynamic a, dynamic b){
  if (a == b) return true;
  if (a is Team == false) return false;
  if (b is Team == false) return false;
  if (a.team == 0) return false;
  return a.team == b.team;
}

class RunSpeed {
   static const Slow = 1.0;
   static const Regular = 2.0;
   static const Fast = 3.0;
   static const Very_Fast = 4.0;
}


mixin Respawnable {
  var respawn = 0;


}