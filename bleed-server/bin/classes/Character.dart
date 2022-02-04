import 'package:lemon_math/Vector2.dart';

import '../common/CharacterState.dart';
import '../common/CharacterType.dart';
import '../common/WeaponType.dart';
import '../common/enums/Direction.dart';
import '../constants/no_squad.dart';
import '../interfaces/HasSquad.dart';
import '../settings.dart';
import '../utilities.dart';
import 'Ability.dart';
import 'GameObject.dart';
import 'Weapon.dart';

const _notFound = -1;

class Character extends GameObject implements HasSquad {
  late CharacterType type;
  Ability? ability = null;
  Ability? performing = null;
  CharacterState state = CharacterState.Idle;
  CharacterState previousState = CharacterState.Idle;
  Direction direction = Direction.Down;
  int equippedIndex = 0;
  double aimAngle = 0;
  double accuracy = 0;
  int stateDuration = 0;
  int stateFrameCount = 0;
  late int maxHealth;
  late double _speed;
  bool frozen = false;
  int frozenDuration = 0;
  double attackRange = 50;
  int damage = 1;

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
  int _armour = 0;
  int maxArmour = 100;

  int get armour => _armour;

  set armour(int value){
    _armour = clampInt(value, 0, maxArmour);
  }

  int get health => _health;

  Weapon get weapon => weapons[equippedIndex];

  set health(int value) {
    _health = clampInt(value, 0, maxHealth);
  }

  bool get alive => state != CharacterState.Dead;

  bool get dead => state == CharacterState.Dead;

  bool get firing => state == CharacterState.Firing;

  bool get aiming => state == CharacterState.Aiming;

  bool get running => state == CharacterState.Running;

  bool get idling => state == CharacterState.Idle;

  bool get striking => state == CharacterState.Striking;

  bool get busy => stateDuration > 0;

  bool get deadOrBusy => dead || busy;

  Character({
    required this.type,
    required double x,
    required double y,
    required int health,
    required double speed,
    this.team = noSquad,
    List<Weapon>? weapons,
  }) : super(x, y, radius: settings.radius.character) {
    maxHealth = health;
    _health = health;
    _speed = speed;
    this.weapons = weapons ?? [
      Weapon(type: WeaponType.Unarmed, damage: 1, capacity: 0)
    ];
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
