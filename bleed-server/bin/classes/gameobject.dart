

import 'package:lemon_math/library.dart';

import '../common/library.dart';
import 'library.dart';
import 'position3.dart';

abstract class GameObject extends Collider {
  var active = true;
  var respawn = 0;
  dynamic spawn;

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

  GameObjectSpawn({
    required double x,
    required double y,
    required double z,
    required this.spawnType,
  }) : super(x: x, y: y, z: z, type: GameObjectType.Spawn);
}

abstract class GameObjectAnimal extends GameObject with Velocity {
  var faceAngle = 0.0;
  var moveSpeed = 1.0;
  final target = Position3();
  var spawnX = 0.0;
  var spawnY = 0.0;
  var spawnZ = 0.0;
  var wanderRadius = 100;

  int get faceDirection => convertAngleToDirection(faceAngle);

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
    collidable = false;
    assignNewTarget();
  }

  @override
  void write(Player player) {
    if (!visible) return;
    player.writeByte(ServerResponse.GameObject_Butterfly);
    player.writePosition3(this);
    player.writeByte(faceDirection);
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
     // angle = this.getAngle(target);
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
  }) : super(x: x, y: y, z: z);

  @override
  void write(Player player) {
      player.writeByte(ServerResponse.GameObject_Chicken);
      player.writePosition3(this);
      player.writeByte(state);
      player.writeByte(faceDirection);
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
          faceAngle = this.getAngle(target);
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
    faceAngle = this.getAngle(target);
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
    faceAngle = 1.0;
  }

  @override
  void write(Player player) {
    player.writeByte(ServerResponse.GameObject_Jellyfish);
    player.writePosition3(this);
    player.writeByte(state);
    player.writeByte(faceDirection);
  }

  @override
  void update(Game game){
    if (pause > 0) {
      pause--;
      if (pause <= 0){
        if (randomBool()){
          state = CharacterState.Performing;
          pause = 100;
        } else {
          assignNewTarget();
          faceAngle = this.getAngle(target);
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
    faceAngle = this.getAngle(target);
    x += xv;
    y += yv;
  }

  @override
  int get type => GameObjectType.Jellyfish;
}

class GameObjectJellyfishRed extends GameObjectAnimal implements Updatable {

  var pause = 0;
  var state = CharacterState.Idle;

  GameObjectJellyfishRed({
    required double x,
    required double y,
    required double z,
  }) : super(x: x, y: y, z: z) {
  }

  @override
  void write(Player player) {
    player.writeByte(ServerResponse.GameObject_Jellyfish_Red);
    player.writePosition3(this);
    player.writeByte(state);
    player.writeByte(faceDirection);
  }

  @override
  void update(Game game){
    if (pause > 0) {
      pause--;
      if (pause <= 0){
        if (randomBool()){
          state = CharacterState.Performing;
          pause = 100;
        } else {
          assignNewTarget();
          faceAngle = this.getAngle(target);
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
    faceAngle = this.getAngle(target);
    x += xv;
    y += yv;
  }

  @override
  int get type => GameObjectType.Jellyfish_Red;
}
