import 'dart:typed_data';

import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/abs.dart';

import '../common/CharacterState.dart';
import '../common/CharacterType.dart';
import '../common/SlotType.dart';
import '../constants.dart';
import '../constants/no_squad.dart';
import '../enums/npc_mode.dart';
import '../settings.dart';
import '../utilities.dart';
import 'Ability.dart';
import 'Collider.dart';
import 'GameObject.dart';
import 'Player.dart';

const maxAIPathLength = 80;
const maxAIPathLengthMinusOne = maxAIPathLength - 3;

/// Merge into character class
class AI {
  final pathX = Float32List(maxAIPathLength);
  final pathY = Float32List(maxAIPathLength);
  late Character character;
  Character? target;
  var objectives = <Vector2>[];
  var mode = NpcMode.Aggressive;
  var viewRange = 200.0;
  var chaseRange = 500.0;
  var _pathIndex = -1;
  var destX = -1.0;
  var destY = -1.0;
  var idleDuration = 0;

  int get pathIndex => _pathIndex;

  void stopPath(){
    if (character.deadOrBusy) return;
    _pathIndex = -1;
    character.state = stateIdle;
  }

  set pathIndex(int value){
    _pathIndex = value;
    if (value < 0) {
      if (character.alive) {
        character.state = stateIdle;
      }
      return;
    }
    destX = pathX[value];
    destY = pathY[value];
  }

  void nextPath(){
    pathIndex = _pathIndex - 1;
  }

  double get x => character.x;
  double get y => character.y;

  bool get arrivedAtDest {
    const radius = 15;
    if ((character.x - destX).abs() > radius) return false;
    if ((character.y - destY).abs() > radius) return false;
    return true;
  }

  AI({
    this.mode = NpcMode.Defensive,
    this.viewRange = 300.0,
  });

  void clearTarget(){
    target = null;
  }

  void clearTargetIf(Character value){
    if (target != value) return;
    target = null;
  }

  void onDeath(){
    target = null;
    pathIndex = -1;
    objectives.clear();
  }
}

class Character extends GameObject {
  // TODO remove from character
  late CharacterType type;
  late int _health;
  late int maxHealth;
  late double _speed;
  late AI? ai;
  // TODO remove from character
  Ability? ability = null;
  // TODO remove from character
  Ability? performing = null;
  int state = stateIdle;
  double angle = 0;
  int equippedIndex = 0;
  double aimAngle = 0;
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
  int team;
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

  int get health => _health;

  set health(int value) {
    _health = clampInt(value, 0, maxHealth);
  }

  bool get alive => state != stateDead;

  bool get dead => state == stateDead;

  bool get running => state == stateRunning;

  bool get idling => state == stateIdle;

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
    this.team = noSquad,
    this.ai,
  }) : super(x, y, radius: settings.radius.character) {
    maxHealth = health;
    _health = health;
    _speed = speed;
    ai?.character = this;
    slots.weapon.type = weapon;
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

  void onCollisionWith(Collider other){
     if (ai == null) return;
     if (!other.withinBounds(ai!.destX, ai!.destY)) return;
     ai!.stopPath();
  }
}

bool sameTeam(Character a, Character b){
  if (a == b) return true;
  if (a.team == 0) return false;
  return a.team == b.team;
}