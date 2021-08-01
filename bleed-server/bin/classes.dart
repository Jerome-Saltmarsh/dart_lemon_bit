import 'settings.dart';

enum CharacterState { Idle, Walking, Dead, Aiming, Firing, Striking }
enum Weapon { Unarmed, HandGun, Shotgun }
enum Direction { Up, UpRight, Right, DownRight, Down, DownLeft, Left, UpLeft, None }

class GameObject {
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
  final int id;
  final String uuid;
  CharacterState state = CharacterState.Idle;
  Direction direction = Direction.Down;
  Weapon weapon;
  double aimAngle = 0;
  double accuracy = 0;
  int shotCoolDown = 0;
  double health;
  int frameOfDeath = 0;
  double speed;
  String name;

  bool get alive => state != CharacterState.Dead;
  bool get dead => state == CharacterState.Dead;
  bool get firing => state == CharacterState.Firing;
  bool get aiming => state == CharacterState.Aiming;

  Character({
    required this.id,
    required this.uuid,
    required double x,
    required double y,
    required this.weapon,
    required this.health,
    required this.speed,
    required this.name
  }) : super(x, y, 0, 0);

  void idle(){
    state = CharacterState.Idle;
  }

  void walk(){
    state = CharacterState.Walking;
  }

  void fire(){
    state = CharacterState.Firing;
  }
}

class Npc extends Character {
  int targetId = -1;
  double xDes = 0;
  double yDes = 0;

  Npc({required double x, required double y, required int id}) : super(
    id: id,
    uuid: "",
    x: x,
    y: y,
    weapon: Weapon.Unarmed,
    health: 5,
    speed: zombieSpeed,
    name: "Npc"
  );
  get targetSet => targetId != -1;
  get destinationSet => xDes == 0;

  void clearTarget(){
    targetId = -1;
  }

  void clearDestination(){
    xDes = 0;
    yDes = 0;
  }
}

class Bullet extends PhysicsGameObject {
  late double xStart;
  late double yStart;
  int ownerId;

  Bullet(double x, double y, double xVel, double yVel, this.ownerId) : super(x, y, xVel, yVel){
    xStart = x;
    yStart = y;
  }
}
