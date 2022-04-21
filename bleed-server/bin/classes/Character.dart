import 'dart:typed_data';

import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/abs.dart';

import '../common/CharacterState.dart';
import '../common/CharacterType.dart';
import '../common/SlotType.dart';
import '../constants.dart';
import '../constants/no_squad.dart';
import '../enums/npc_mode.dart';
import '../functions/withinRadius.dart';
import '../settings.dart';
import 'Ability.dart';
import 'Collider.dart';
import 'Game.dart';
import 'Player.dart';
import 'components.dart';

const maxAIPathLength = 80;
const maxAIPathLengthMinusOne = maxAIPathLength - 3;


class AI extends Character {
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
    int team = noSquad,
    int weapon = SlotType.Empty,
    double speed = 3.0,
  }): super(x: x, y: y, type: type, health: health, team: team, weapon: weapon, speed: speed);

  void clearTargetIf(Character value){
    if (target != value) return;
    target = null;
  }

  bool withinViewRange(Vector2 target) {
    if (mode == NpcMode.Swarm) return true;
    return withinRadius(this, target, viewRange);
  }

  bool withinChaseRange(Vector2 target) {
    if (mode == NpcMode.Swarm) return true;
    return withinRadius(this, target, chaseRange);
  }

  @override
  void onCollisionWith(Collider other){
    if (_pathIndex < 0) return;
    rotateAround(other, 0.1);
    if (!other.withinBounds(dest)) return;
    nextPath();
  }
}

class Character extends Collider with Team, Health, Velocity, Active {
  late CharacterType type;
  late double _speed;
  Ability? ability = null;
  Ability? performing = null;
  int state = CharacterState.Idle;
  double angle = 0;
  double accuracy = 0;
  int stateDurationRemaining = 0;
  int stateDuration = 0;
  int animationFrame = 0;
  int frozenDuration = 0;
  /// the character that was highlighted as the character began attacking
  /// This forces a hit to occur even if the target goes out of range of the attack
  Collider? attackTarget;
  double speedModifier = 0;
  bool invincible = false;
  final abilityTarget = Vector2(0, 0);
  final slots = Slots();

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

  int get weapon => slots.weapon.type;

  double get weaponRange => SlotType.getRange(weapon);

  Character({
    required this.type,
    required double x,
    required double y,
    required int health,
    int weapon = SlotType.Empty,
    double speed = 3.0,
    int team = Teams.none,
  }) : super(x: x, y: y, radius: settings.radius.character) {
    maxHealth = health;
    this.health = health;
    _speed = speed;
    slots.weapon.type = weapon;
    this.team = team;
  }

  void applyVelocity() {
    move(angle, speed);
  }

  void updateMovement() {
    const minVelocity = 0.005;
    if (abs(xv) <= minVelocity) return;
    x += xv;
    y += yv;
    const velocityFriction = 0.88;
    xv *= velocityFriction;
    yv *= velocityFriction;
  }

  bool withinAttackRange(Vector2 target){
    if (target is Collider){
      return withinRadius(this, target, weaponRange + (target.radius * 0.5));
    }
    return withinRadius(this, target, weaponRange);
  }

  void face(Vector2 position){
    if (deadOrBusy) return;
    angle = getAngle(position);
  }
}

bool sameTeam(dynamic a, dynamic b){
  if (a == b) return true;
  if (a is Team == false) return false;
  if (b is Team == false) return false;
  if (a.team == 0) return false;
  return a.team == b.team;
}