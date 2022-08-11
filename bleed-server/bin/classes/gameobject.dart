

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

  void update(){

  }
}

class GameObjectRock extends GameObject {
  GameObjectRock({
    required double x,
    required double y,
    required double z,
  }) : super(x: x, y: y, z: z, radius: 10){
    collidable = false;
  }

  @override
  void write(Player player) {
      player.writeByte(ServerResponse.GameObject_Rock);
      player.writePosition3(this);
  }
}


class GameObjectFlower extends GameObject {
  GameObjectFlower({
    required double x,
    required double y,
    required double z,
  }) : super(x: x, y: y, z: z, radius: 10) {
    collidable = false;
  }

  @override
  void write(Player player) {
    player.writeByte(ServerResponse.GameObject_Flower);
    player.writePosition3(this);
  }
}


class GameObjectStick extends GameObject {
  GameObjectStick({
    required double x,
    required double y,
    required double z,
  }) : super(x: x, y: y, z: z, radius: 10) {
    collidable = false;
  }

  @override
  void write(Player player) {
    player.writeByte(ServerResponse.GameObject_Stick);
    player.writePosition3(this);
  }
}

abstract class GameObjectAnimal extends GameObject with Velocity {
  final target = Position3();
  var spawnX = 0.0;
  var spawnY = 0.0;
  var spawnZ = 0.0;

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

  void assignNewTarget({double radius = 100}){
    target.x = spawnX + giveOrTake(radius);
    target.y = spawnY + giveOrTake(radius);
  }
}

class GameObjectButterfly extends GameObject with Velocity {
  final target = Position3();
  var spawnX = 0.0;
  var spawnY = 0.0;
  var spawnZ = 0.0;
  var pause = 0;

  GameObjectButterfly({
    required double x,
    required double y,
    required double z,
  }) : super(x: x, y: y, z: z, radius: 10) {
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
    player.writeByte(ServerResponse.GameObject_Butterfly);
    player.writePosition3(this);
    player.writeByte(direction);
  }

  @override
  void update() {
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

  void assignNewTarget(){
    const radius = 100;
    target.x = spawnX + giveOrTake(radius);
    target.y = spawnY + giveOrTake(radius);
  }
}

class GameObjectChicken extends GameObjectAnimal {

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
  void update(){
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
}

class GameObjectCrystal extends GameObject {
  GameObjectCrystal({
    required double x,
    required double y,
    required double z,
  }) : super(x: x, y: y, z: z, radius: 10);

  @override
  void write(Player player) {
    player.writeByte(ServerResponse.GameObject_Crystal);
    player.writePosition3(this);
  }
}
