
import '../common/Ab.dart';
import '../common/CharacterState.dart';
import '../common/CharacterType.dart';
import '../common/classes/Vector2.dart';
import '../common/enums/Direction.dart';
import '../constants/no_squad.dart';
import '../interfaces/HasSquad.dart';
import '../utils.dart';
import 'Ability.dart';
import 'GameObject.dart';
import 'Weapon.dart';

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

  double get speed {
    if (frozen){
      return _speed * 0.5;
    }
    return _speed;
  }


  int squad;
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

  bool get aiming => state == CharacterState.Aiming;

  bool get walking => state == CharacterState.Walking;

  bool get running => state == CharacterState.Running;

  bool get idling => state == CharacterState.Idle;

  bool get striking => state == CharacterState.Striking;

  bool get busy => stateDuration > 0;

  Character({
    required this.type,
    required double x,
    required double y,
    required this.weapons,
    required int health,
    required double speed,
    this.squad = noSquad,
  }) : super(x, y) {
    maxHealth = health;
    _health = health;
    _speed = speed;
  }

  @override
  int getSquad() {
    return squad;
  }
}
