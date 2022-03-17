import 'dart:typed_data';

import 'package:lemon_math/Vector2.dart';

import '../common/CharacterState.dart';
import '../common/CharacterType.dart';
import '../common/SlotType.dart';
import '../constants.dart';
import '../constants/no_squad.dart';
import '../enums/npc_mode.dart';
import '../interfaces/HasSquad.dart';
import '../settings.dart';
import '../utilities.dart';
import 'Ability.dart';
import 'GameObject.dart';

const _defaultMode = NpcMode.Defensive;
const _defaultViewRange = 300.0;
const _defaultCharacterSpeed = 3.0;
const maxAIPathLength = 80;
const maxAIPathLengthMinusOne = maxAIPathLength - 3;

class AI {
  late Character character;
  Character? target;
  List<Vector2> objectives = [];
  NpcMode mode = NpcMode.Aggressive;
  double viewRange = 200;
  double chaseRange = 500;
  final pathX = Float32List(maxAIPathLength);
  final pathY = Float32List(maxAIPathLength);
  int _pathIndex = -1;
  double destX = -1;
  double destY = -1;
  int idleDuration = 0;

  int get pathIndex => _pathIndex;

  set pathIndex(int value){
    _pathIndex = value;
    if (value < 0) return;
    destX = pathX[value];
    destY = pathY[value];
  }

  double get x => character.x;
  double get y => character.y;


  AI({
    this.mode = _defaultMode,
    this.viewRange = _defaultViewRange,
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

class Character extends GameObject implements HasSquad {
  late CharacterType type;
  late int _health;
  late int maxHealth;
  late double _speed;
  late AI? ai;
  Ability? ability = null;
  Ability? performing = null;
  CharacterState state = CharacterState.Idle;
  CharacterState previousState = CharacterState.Idle;
  double angle = 0;
  int equippedIndex = 0;
  double aimAngle = 0;
  double accuracy = 0;
  int stateDurationRemaining = 0;
  int stateDuration = 0;
  /// This is updated every
  int animationFrame = 0;
  int frozenDuration = 0;
  double attackRange = 50;
  int damage = 1;
  /// the character that was highlighted when the player clicked
  Character? attackTarget;
  double speedModifier = 0;
  bool invincible = false;
  int team;
  Vector2 abilityTarget = Vector2(0, 0);

  SlotType weapon;


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

  bool get alive => state != CharacterState.Dead;

  bool get dead => state == CharacterState.Dead;

  bool get running => state == CharacterState.Running;

  bool get idling => state == CharacterState.Idle;

  bool get busy => stateDurationRemaining > 0;

  bool get deadOrBusy => dead || busy;

  Character({
    required this.type,
    required double x,
    required double y,
    required int health,
    required this.weapon,
    double speed = _defaultCharacterSpeed,
    this.team = noSquad,
    this.ai,
  }) : super(x, y, radius: settings.radius.character) {
    maxHealth = health;
    _health = health;
    _speed = speed;
    ai?.character = this;
  }

  @override
  int getSquad() {
    return team;
  }
}

bool sameTeam(Character a, Character b){
  if (a == b) return true;
  if (a.team == 0) return false;
  return a.team == b.team;
}