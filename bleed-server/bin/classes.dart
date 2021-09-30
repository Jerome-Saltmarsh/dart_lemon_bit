import 'classes/Player.dart';
import 'classes/Vector2.dart';
import 'common/classes/Vector2.dart';
import 'enums.dart';
import 'common/GameEventType.dart';
import 'common/Weapons.dart';
import 'settings.dart';

int _idCount = 0;

class GameObject {
  final int id = _idCount++;
  double x;
  double y;
  double z = 0;
  double xv = 0;
  double yv = 0;
  double zv = 0;
  double radius;
  bool collidable = true;
  bool active = true;

  double get left => x - radius;
  double get right => x + radius;
  double get top => y - radius;
  double get bottom => y + radius;
  bool get inactive => !active;

  GameObject(this.x, this.y, {this.z = 0, this.xv = 0, this.yv = 0, this.zv = 0, this.radius = 5});
}

const noSquad = -1;

class Character extends GameObject implements HasSquad {
  CharacterState state = CharacterState.Idle;
  CharacterState previousState = CharacterState.Idle;
  Direction direction = Direction.Down;
  Weapon weapon;
  double aimAngle = 0;
  double accuracy = 0;
  int stateDuration = 0;
  int stateFrameCount = 0;
  double health;
  double maxHealth;
  double speed;
  int squad;

  bool get alive => state != CharacterState.Dead;

  bool get dead => state == CharacterState.Dead;

  bool get firing => state == CharacterState.Firing;

  bool get aiming => state == CharacterState.Aiming;

  bool get walking => state == CharacterState.Walking;

  bool get running => state == CharacterState.Running;

  bool get idling => state == CharacterState.Idle;

  bool get busy => stateDuration > 0;

  Character({
      required double x,
      required double y,
      required this.weapon,
      required this.health,
      required this.maxHealth,
      required this.speed,
      this.squad = noSquad,
  })
      : super(x, y);

  @override
  int getSquad() {
    return squad;
  }
}

final Character _nonTarget = Character(x: 0, y: 0, weapon: Weapon.AssaultRifle, health: 0, maxHealth: 0, speed: 0);

class Npc extends Character {
  Character target = _nonTarget;
  List<Vector2> path = [];
  int pointMultiplier = 1;

  Npc(
      {required double x,
      required double y,
      required double health,
      required double maxHealth})
      : super(
            x: x,
            y: y,
            weapon: Weapon.Unarmed,
            health: health,
            maxHealth: maxHealth,
            speed: zombieSpeed);

  get targetSet => target != _nonTarget;

  void clearTarget() {
    target = _nonTarget;
    path.clear();
  }
}

abstract class HasSquad {
  int getSquad();
}

extension HasSquadExtensions on HasSquad {
  bool get noSquad => getSquad() == -1;
}

bool allies(HasSquad a, HasSquad b){
  if (a.noSquad) return false;
  if (b.noSquad) return false;
  return a.getSquad() == b.getSquad();
}

bool enemies(HasSquad a, HasSquad b){
  return !allies(a, b);
}

class Bullet extends GameObject implements HasSquad {
  late double xStart;
  late double yStart;
  Character owner;
  double range;
  double damage;

  int get squad => owner.squad;

  Bullet(double x, double y, double xVel, double yVel, this.owner, this.range, this.damage)
      : super(x, y, xv: xVel, yv: yVel) {
    xStart = x;
    yStart = y;
  }

  @override
  int getSquad() {
    return owner.squad;
  }
}

class GameEvent extends GameObject {
  final GameEventType type;
  int frameDuration = 2;

  GameEvent(this.type, double x, double y, double xv, double yv) : super(x, y, xv: xv, yv: yv);
}

class Grenade extends GameObject {
  final Player owner;

  Grenade(this.owner, double xv, double yv, double zVel) : super(owner.x, owner.y, xv:xv, yv: yv) {
    this.zv = zVel;
  }
}

