import 'classes/Ammunition.dart';
import 'enums.dart';
import 'enums/GameEventType.dart';
import 'enums/Weapons.dart';
import 'settings.dart';

class GameObject {
  static int _idGenerator = 0;
  final int id = _idGenerator++;
  double x;
  double y;
  double z = 0;
  double xv = 0;
  double yv = 0;
  double zv = 0;
  double radius;
  bool collidable = true;

  double get left => x - radius;
  double get right => x + radius;
  double get top => y - radius;
  double get bottom => y + radius;

  GameObject(this.x, this.y, {this.z = 0, this.xv = 0, this.yv = 0, this.zv = 0, this.radius = 5});
}

class Character extends GameObject {
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
  bool active = true;

  bool get alive => state != CharacterState.Dead;

  bool get dead => state == CharacterState.Dead;

  bool get firing => state == CharacterState.Firing;

  bool get aiming => state == CharacterState.Aiming;

  bool get walking => state == CharacterState.Walking;

  Character({
      required double x,
      required double y,
      required this.weapon,
      required this.health,
      required this.maxHealth,
      required this.speed,
      required this.name})
      : super(x, y);

  void idle() {
    state = CharacterState.Idle;
  }

  void walk() {
    state = CharacterState.Walking;
  }
}

final Character _nonTarget = Character(x: 0, y: 0, weapon: Weapon.MachineGun, health: 0, maxHealth: 0, speed: 0, name: "");

class Npc extends Character {
  Character target = _nonTarget;
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

  get targetSet => target != _nonTarget;

  get destinationSet => xDes != 0;

  void clearTarget() {
    target = _nonTarget;
  }

  void clearDestination() {
    xDes = 0;
    yDes = 0;
  }
}

class Player extends Character {
  final String uuid;
  final Ammunition handgunAmmunition = Ammunition(8, 8, 3, 3);
  final Ammunition shotgunAmmunition = Ammunition(4, 4, 3, 3);
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

class Bullet extends GameObject {
  late double xStart;
  late double yStart;
  int ownerId;
  final double range;
  final double damage;

  Bullet(double x, double y, double xVel, double yVel, this.ownerId, this.range, this.damage)
      : super(x, y, xv: xVel, yv: yVel) {
    xStart = x;
    yStart = y;
  }
}

class GameEvent extends GameObject {
  final GameEventType type;
  int frameDuration = 8;

  GameEvent(this.type, double x, double y, double xv, double yv) : super(x, y, xv: xv, yv: yv);
}

class Grenade extends GameObject {
  Grenade(double x, double y, double xv, double yv, double zVel) : super(x, y, xv:xv, yv: yv) {
    this.zv = zVel;
  }
}

