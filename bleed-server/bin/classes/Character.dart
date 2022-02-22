import 'dart:typed_data';

import 'package:lemon_math/Vector2.dart';

import '../common/CharacterState.dart';
import '../common/CharacterType.dart';
import '../common/WeaponType.dart';
import '../constants.dart';
import '../constants/no_squad.dart';
import '../enums/npc_mode.dart';
import '../interfaces/HasSquad.dart';
import '../settings.dart';
import '../utilities.dart';
import 'Ability.dart';
import 'GameObject.dart';
import 'Weapon.dart';

const _notFound = -1;
const _defaultMode = NpcMode.Defensive;
const _defaultViewRange = 300.0;
const _defaultCharacterSpeed = 3.0;
const maxAIPathLength = 80;
const maxAIPathLengthMinusOne = maxAIPathLength - 3;

class AI {
  late Character character;
  Character? target;
  // List<Vector2> path = [];
  List<Vector2> objectives = [];
  NpcMode mode = NpcMode.Aggressive;
  double viewRange = 200;
  double chaseRange = 500;
  Float32List pathX = Float32List(maxAIPathLength);
  Float32List pathY = Float32List(maxAIPathLength);
  int pathIndex = -1;

  double get x => character.x;
  double get y => character.y;

  double get destX => pathX[pathIndex];
  double get destY => pathY[pathIndex];

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
  int stateDuration = 0;
  int stateFrameCount = 0;
  bool frozen = false;
  int frozenDuration = 0;
  double attackRange = 50;
  int damage = 1;

  int get direction => (((angle + piEighth) % pi2) ~/ piQuarter) % 8;

  /// the character that was highlighted when the player clicked
  Character? attackTarget;

  double get speed {
    if (frozen) {
      return (_speed + speedModifier) * 0.5;
    }
    return (_speed + speedModifier);
  }

  double speedModifier = 0;
  bool invincible = false;

  int team;
  List<Weapon> weapons = [];
  bool weaponsDirty = false;

  Vector2 abilityTarget = Vector2(0, 0);

  late int _health;

  int get health => _health;

  Weapon get weapon => weapons[equippedIndex];

  set health(int value) {
    _health = clampInt(value, 0, maxHealth);
  }

  bool get alive => state != CharacterState.Dead;

  bool get dead => state == CharacterState.Dead;

  bool get firing => state == CharacterState.Firing;

  bool get running => state == CharacterState.Running;

  bool get idling => state == CharacterState.Idle;

  bool get busy => stateDuration > 0;

  bool get deadOrBusy => dead || busy;

  Character({
    required this.type,
    required double x,
    required double y,
    required int health,
    double speed = _defaultCharacterSpeed,
    this.team = noSquad,
    this.ai,
    List<Weapon>? weapons,
  }) : super(x, y, radius: settings.radius.character) {
    maxHealth = health;
    _health = health;
    _speed = speed;
    this.weapons = weapons ?? [
      Weapon(type: WeaponType.Unarmed, damage: 1, capacity: 0)
    ];
    ai?.character = this;
  }

  @override
  int getSquad() {
    return team;
  }

  void equip(WeaponType type){
    final weaponIndex = getIndexOfWeaponType(type);
    if (weaponIndex == _notFound) return;
    equippedIndex = weaponIndex;
  }

  /// returns -1 if the player does not have the weapon
  int getIndexOfWeaponType(WeaponType type){
    for(int i = 0; i < weapons.length; i++){
      if (weapons[i].type == type){
        return i;
      }
    }
    return _notFound;
  }
}
