import 'enums.dart';
import 'maths.dart';
import 'settings.dart';

class GameObject {
  static int _idGenerator = 0;
  final int id = _idGenerator++;
  double x;
  double y;

  GameObject(this.x, this.y);
}

class PhysicsGameObject extends GameObject {
  double xVel = 0;
  double yVel = 0;

  PhysicsGameObject(double x, double y, this.xVel, this.yVel) : super(x, y);
}

class Character extends PhysicsGameObject {
  CharacterState state = CharacterState.Idle;
  Direction direction = Direction.Down;
  Weapon weapon;
  double aimAngle = 0;
  double accuracy = 0;
  int shotCoolDown = 0;
  double health;
  double maxHealth;
  double speed;
  String name;

  bool get alive => state != CharacterState.Dead;

  bool get dead => state == CharacterState.Dead;

  bool get firing => state == CharacterState.Firing;

  bool get aiming => state == CharacterState.Aiming;

  bool get walking => state == CharacterState.Walking;

  Character(
      {required double x,
      required double y,
      required this.weapon,
      required this.health,
      required this.maxHealth,
      required this.speed,
      required this.name})
      : super(x, y, 0, 0);

  void idle() {
    state = CharacterState.Idle;
  }

  void walk() {
    state = CharacterState.Walking;
  }
}

class Npc extends Character {
  int targetId = -1;
  double xDes = 0;
  double yDes = 0;

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
            speed: zombieSpeed,
            name: "Npc");

  get targetSet => targetId != -1;

  get destinationSet => xDes != 0;

  void clearTarget() {
    targetId = -1;
  }

  void clearDestination() {
    xDes = 0;
    yDes = 0;
  }
}

class Player extends Character {
  final String uuid;
  int lastEventFrame = 0;

  Player(
      {required this.uuid,
      required double x,
      required double y,
      required String name})
      : super(
            x: x,
            y: y,
            weapon: Weapon.HandGun,
            health: settingsPlayerStartHealth,
            maxHealth: settingsPlayerStartHealth,
            speed: playerSpeed,
            name: name);
}

class Bullet extends PhysicsGameObject {
  late double xStart;
  late double yStart;
  int ownerId;
  final double range;

  Bullet(double x, double y, double xVel, double yVel, this.ownerId, this.range)
      : super(x, y, xVel, yVel) {
    xStart = x;
    yStart = y;
  }
}

class Blood extends PhysicsGameObject {
  int lifeTime = randomBetween(45, 90).toInt();

  Blood(double x, double y, double xVel, double yVel) : super(x, y, xVel, yVel);
}

class GameEvent extends GameObject {
  final GameEventType type;
  int frameDuration = 8;

  GameEvent(double x, double y, this.type) : super(x, y);
}

class Grenade extends PhysicsGameObject {
  Grenade(double x, double y, double xVel, double yVel) : super(x, y, xVel, yVel);
}

