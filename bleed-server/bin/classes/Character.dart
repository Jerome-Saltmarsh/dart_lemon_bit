import 'dart:math';
import 'dart:typed_data';

import 'package:lemon_math/library.dart';

import '../common/MaterialType.dart';
import '../common/library.dart';
import '../functions/withinRadius.dart';
import 'Ability.dart';
import 'Collider.dart';
import 'Game.dart';
import 'components.dart';

const maxAIPathLength = 80;
const maxAIPathLengthMinusOne = maxAIPathLength - 3;


class AI extends Character with Material {
  static const viewRange = 200.0;
  static const chaseRange = 500.0;
  final pathX = Float32List(maxAIPathLength);
  final pathY = Float32List(maxAIPathLength);
  var mode = NpcMode.Aggressive;
  var _pathIndex = -1;
  var dest = Vector2(-1, -1);
  var idleDuration = 0;
  dynamic target;

  int get pathIndex => _pathIndex;

  void stopPath(){
    if (deadOrBusy) return;
    _pathIndex = -1;
    state = CharacterState.Idle;
  }

  set pathIndex(int value){
    _pathIndex = value;
    if (value < 0) {
      if (alive) {
        state = CharacterState.Idle;
      }
      return;
    }
    dest.x = pathX[value];
    dest.y = pathY[value];
  }

  void nextPath(){
    pathIndex = _pathIndex - 1;
  }

  bool get arrivedAtDest {
    const radius = 15;
    if ((x - dest.x).abs() > radius) return false;
    if ((y - dest.y).abs() > radius) return false;
    return true;
  }

  AI({
    required double x,
    required double y,
    this.mode = NpcMode.Defensive,
    required CharacterType type,
    required int health,
    int team = 0,
    int weapon = SlotType.Empty,
    double speed = 3.0,
  }): super(x: x, y: y, type: type, health: health, team: team, weapon: weapon, speed: speed) {
    this.material = MaterialType.Flesh;
  }

  void clearTargetIf(Character value){
    if (target != value) return;
    target = null;
  }

  bool withinViewRange(Position target) {
    if (mode == NpcMode.Swarm) return true;
    return withinRadius(this, target, viewRange);
  }

  bool withinChaseRange(Position target) {
    if (mode == NpcMode.Swarm) return true;
    return withinRadius(this, target, chaseRange);
  }

  @override
  void onCollisionWith(Collider other){
    if (_pathIndex < 0) return;
    if (other is AI) {
      rotateAround(other, 0.2);
    }
    if (!other.withinBounds(dest)) return;
    nextPath();
  }
}

const piEighth = pi / 8.0;

class Character extends Collider with Team, Health, Velocity, Material {
  late CharacterType type;
  late double _speed;
  Ability? ability = null;
  Ability? performing = null;
  double angle = 0;
  double accuracy = 0;
  double speedModifier = 0;
  int state = CharacterState.Idle;
  int stateDurationRemaining = 0;
  int stateDuration = 0;
  int animationFrame = 0;
  int frozenDuration = 0;
  /// the character that was highlighted as the character began attacking
  /// This forces a hit to occur even if the target goes out of range of the attack
  Collider? attackTarget;
  bool invincible = false;
  final abilityTarget = Vector2(0, 0);
  final techTree = TechTree();
  // final slots = Slots();
  var equipped = TechType.Unarmed;

  // properties

  int get direction => (((angle + piEighth) % pi2) ~/ piQuarter) % 8;
  bool get frozen => frozenDuration > 0;


  double get speed {
    if (frozen) {
      return (_speed + speedModifier) * 0.5;
    }
    return (_speed + speedModifier);
  }

  bool get running => state == CharacterState.Running;

  bool get idling => state == CharacterState.Idle;

  bool get busy => stateDurationRemaining > 0;

  bool get deadOrBusy => dead || busy;

  double get equippedRange => TechType.getRange(equipped);
  int get equippedAttackDuration => TechType.getDuration(equipped);
  bool get equippedTypeIsBow => isEquipped(TechType.Bow);
  bool get unarmed => isEquipped(TechType.Unarmed);
  bool get equippedTypeIsShotgun => isEquipped(TechType.Shotgun);
  bool get equippedIsMelee => TechType.isMelee(equipped);
  bool get equippedIsEmpty => false;
  int get equippedLevel => getTechTypeLevel(equipped);

  bool isEquipped(int type) {
    return equipped == type;
  }

  void reduceEquippedAmount() {

  }

  Character({
    required this.type,
    required double x,
    required double y,
    required int health,
    int weapon = TechType.Unarmed,
    double speed = 3.0,
    int team = Teams.none,
  }) : super(x: x, y: y, radius: 10) {
    maxHealth = health;
    this.health = health;
    _speed = speed;
    this.team = team;
    this.material = MaterialType.Flesh;
  }

  void applyVelocity() {
    move(angle, speed);
  }

  void updateMovement() {
    const minVelocity = 0.005;
    if (xv.abs() <= minVelocity) return;
    x += xv;
    y += yv;
    const velocityFriction = 0.88;
    xv *= velocityFriction;
    yv *= velocityFriction;
  }

  bool withinAttackRange(Position target){
    if (target is Collider){
      return withinRadius(this, target, equippedRange + (target.radius * 0.5));
    }
    return withinRadius(this, target, equippedRange);
  }

  void face(Position position){
    if (deadOrBusy) return;
    angle = this.getAngle(position);
  }

  int getTechTypeLevel(int type) {
    switch(type){
      case TechType.Unarmed:
        return 1;
      case TechType.Pickaxe:
        return techTree.pickaxe;
      case TechType.Sword:
        return techTree.sword;
      case TechType.Bow:
        return techTree.bow;
      case TechType.Axe:
        return techTree.axe;
      case TechType.Hammer:
        return techTree.hammer;
      default:
        throw Exception("cannot get tech type level. type: $type");
    }
  }
}

bool sameTeam(dynamic a, dynamic b){
  if (a == b) return true;
  if (a is Team == false) return false;
  if (b is Team == false) return false;
  if (a.team == 0) return false;
  return a.team == b.team;
}

enum NpcMode {
  Ignore,
  Stand_Ground,
  Defensive,
  Aggressive,
  Swarm,
}
