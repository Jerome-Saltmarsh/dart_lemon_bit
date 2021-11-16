
import '../common/Weapons.dart';
import '../common/enums/Direction.dart';
import '../constants/no_squad.dart';
import '../enums.dart';
import '../interfaces/HasSquad.dart';
import '../utils.dart';
import 'GameObject.dart';

class Character extends GameObject implements HasSquad {
  CharacterState state = CharacterState.Idle;
  CharacterState previousState = CharacterState.Idle;
  Direction direction = Direction.Down;
  Weapon weapon;
  double aimAngle = 0;
  double accuracy = 0;
  int stateDuration = 0;
  int stateFrameCount = 0;
  late int maxHealth;
  double speed;
  int squad;

  late int _health;

  int get health => _health;

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
    required double x,
    required double y,
    required this.weapon,
    required int health,
    required this.speed,
    this.squad = noSquad,
  }) : super(x, y) {
    maxHealth = health;
    _health = health;
  }

  @override
  int getSquad() {
    return squad;
  }
}
