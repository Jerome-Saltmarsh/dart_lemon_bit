

import 'package:lemon_math/library.dart';

import '../common/library.dart';
import 'library.dart';
import 'position3.dart';

abstract class GameObject extends Collider {
  GameObject({
    required double x,
    required double y,
    required double z,
    required double radius,
  }) : super(x: x, y: y, z: z, radius: radius);

  void write(Player player);

  int get type;

  bool get persist => true;
}

class GameObjectStatic extends GameObject {
  final int type;
  GameObjectStatic({
    required double x,
    required double y,
    required double z,
    required this.type,
  }) : super(x: x, y: y, z: z, radius: 10) {
    collidable = false;
    switch (type) {
      case GameObjectType.Crystal:
        collidable = true;
        movable = false;
        break;
      case GameObjectType.Barrel:
        collidable = true;
        movable = false;
        radius = 15;
        break;
      default:
        break;
    }
  }

  @override
  void write(Player player) {
    player.writeByte(ServerResponse.GameObject_Static);
    player.writePosition3(this);
    player.writeByte(type);
  }
}

abstract class Updatable {
  void update(Game game);
}

class GameObjectSpawn extends GameObjectStatic {
  int spawnType;
  dynamic instance;

  GameObjectSpawn({
    required double x,
    required double y,
    required double z,
    required this.spawnType,
  }) : super(x: x, y: y, z: z, type: GameObjectType.Spawn);
}

abstract class GameObjectAnimal extends GameObject with Velocity {
  final target = Position3();
  var spawnX = 0.0;
  var spawnY = 0.0;
  var spawnZ = 0.0;
  var wanderRadius = 100;

  GameObjectAnimal({
    required double x, required double y, required double z,
  }) : super(x: x, y: y, z: z, radius: 5) {
    target.x = x;
    target.y = y;
    target.z = z;
    spawnX = x;
    spawnY = y;
    spawnZ = z;
  }

  void assignNewTarget(){
    target.x = spawnX + giveOrTake(wanderRadius);
    target.y = spawnY + giveOrTake(wanderRadius);
  }

  @override
  bool get persist => false;
}

class GameObjectButterfly extends GameObjectAnimal with Velocity implements Updatable {
  var pause = 0;
  var visible = true;

  GameObjectButterfly({
    required double x,
    required double y,
    required double z,
  }) : super(x: x, y: y, z: z) {
    target.x = x;
    target.y = y;
    target.z = z;
    spawnX = x;
    spawnY = y;
    spawnZ = z;
    speed = 1.5;
    collidable = false;
    assignNewTarget();
  }

  @override
  void write(Player player) {
    if (!visible) return;
    player.writeByte(ServerResponse.GameObject_Butterfly);
    player.writePosition3(this);
    player.writeByte(direction);
  }

  @override
  void update(Game game) {
    const timeHourSix = 9 * secondsPerHour;
    const timeHourSeventeen = 16 * secondsPerHour;
    if (game.getTime() < timeHourSix || game.getTime() > timeHourSeventeen){
      visible = false;
      return;
    } else {
      visible = true;
    }

    if (pause > 0) {
       pause--;
       return;
    }

     if (distanceFromPos3(target) < 5){
       assignNewTarget();
       pause = 100;
       return;
     }
     angle = this.getAngle(target);
     x += xv;
     y += yv;
  }

  @override
  int get type => GameObjectType.Butterfly;
}

class GameObjectChicken extends GameObjectAnimal implements Updatable {

  var pause = 0;
  var state = CharacterState.Idle;

  GameObjectChicken({
    required double x,
    required double y,
    required double z,
  }) : super(x: x, y: y, z: z) {
    speed = 1.0;
  }

  @override
  void write(Player player) {
      player.writeByte(ServerResponse.GameObject_Chicken);
      player.writePosition3(this);
      player.writeByte(state);
      player.writeByte(direction);
  }

  @override
  void update(Game game){
    const timeHourSix = 6 * secondsPerHour;
    const timeHourSeventeen = 17 * secondsPerHour;
    if (game.getTime() < timeHourSix || game.getTime() > timeHourSeventeen){
       state = CharacterState.Sitting;
       return;
    }

    if (pause > 0) {
      pause--;
      if (pause <= 0){
        if (randomBool()){
           state = CharacterState.Performing;
           pause = 100;
        } else {
          assignNewTarget();
          angle = this.getAngle(target);
        }
      }
      return;
    }

    if (distanceFromPos3(target) < 5){
      state = CharacterState.Idle;
      pause = 100;
      return;
    }
    state = CharacterState.Running;
    angle = this.getAngle(target);
    x += xv;
    y += yv;
  }

  @override
  int get type => GameObjectType.Chicken;
}



class GameObjectJellyfish extends GameObjectAnimal implements Updatable {

  var pause = 0;
  var state = CharacterState.Idle;

  GameObjectJellyfish({
    required double x,
    required double y,
    required double z,
  }) : super(x: x, y: y, z: z) {
    speed = 1.0;
  }

  @override
  void write(Player player) {
    player.writeByte(ServerResponse.GameObject_Jellyfish);
    player.writePosition3(this);
    player.writeByte(state);
    player.writeByte(direction);
  }

  @override
  void update(Game game){
    const timeHourSix = 6 * secondsPerHour;
    const timeHourSeventeen = 17 * secondsPerHour;
    if (game.getTime() < timeHourSix || game.getTime() > timeHourSeventeen){
      state = CharacterState.Sitting;
      return;
    }

    if (pause > 0) {
      pause--;
      if (pause <= 0){
        if (randomBool()){
          state = CharacterState.Performing;
          pause = 100;
        } else {
          assignNewTarget();
          angle = this.getAngle(target);
        }
      }
      return;
    }

    if (distanceFromPos3(target) < 5){
      state = CharacterState.Idle;
      pause = 100;
      return;
    }
    state = CharacterState.Running;
    angle = this.getAngle(target);
    x += xv;
    y += yv;
  }

  @override
  int get type => GameObjectType.Jellyfish;
}
