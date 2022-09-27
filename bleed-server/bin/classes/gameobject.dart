

import 'package:lemon_math/library.dart';

import '../common/library.dart';
import 'library.dart';
import 'position3.dart';

class GameObject extends Collider {
  var active = true;
  int type;
  dynamic spawn;

  GameObject({
    required double x,
    required double y,
    required double z,
    required double radius,
    required this.type,
  }) : super(x: x, y: y, z: z, radius: radius);

  void write(Player player) {}

  /// Determines whether or not this object should be serialized
  bool get persist => true;
}

class GameObjectStatic extends GameObject {
  var respawn = 0;

  GameObjectStatic({
    required double x,
    required double y,
    required double z,
    required int type,
  }) : super(x: x, y: y, z: z, radius: 10, type: type) {
    collidable = false;
    switch (type) {
      case GameObjectType.Crystal:
        collidable = true;
        moveOnCollision = false;
        break;
      case GameObjectType.Barrel:
        collidable = true;
        moveOnCollision = false;
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

class GameObjectLoot extends GameObject {

  int lootType;

  GameObjectLoot({
    required double x,
    required double y,
    required double z,
    required this.lootType,
  }) : super(x: x, y: y, z: z, radius: 15, type: GameObjectType.Loot) {
    physical = false;
  }

  @override
  void write(Player player) {
    player.writeByte(ServerResponse.GameObject_Loot);
    player.writePosition3(this);
    player.writeByte(lootType);
  }
}

class GameObjectParticleEmitter extends GameObject with Updatable{
  int particleType;
  int nextSpawn = 0;
  int spawnRate = 30;
  int duration;
  double angle = 0.0;
  double speed = 0.0;
  double weight;
  double zv;

  GameObjectParticleEmitter({
    required double x,
    required double y,
    required double z,
    required this.particleType,
    required this.duration,
    required this.angle,
    required this.speed,
    required this.weight,
    required this.zv,
    required this.spawnRate,
  }) : super(x: x, y: y, z: z, radius: 0, type: GameObjectType.Loot) {
    collidable = false;
  }

  @override
  int get type => GameObjectType.Particle_Emitter;

  @override
  void write(Player player) {
     player.writeByte(ServerResponse.GameObject);
     player.writeByte(GameObjectType.Particle_Emitter);
     player.writePosition3(this);
  }

  @override
  void update(Game game) {
    if (nextSpawn-- > 0) return;
    nextSpawn = spawnRate;

    for (final player in game.players){
      player.writeByte(ServerResponse.Spawn_Particle);
      player.writePosition3(this);
      player.writeByte(particleType);
      player.writeInt(duration);
      player.writeAngle(angle);
      player.writeInt(speed * 100);
      player.writeInt(weight * 100);
      player.writeInt(zv * 100);
    }
  }
}

abstract class GameObjectAnimal extends GameObject with Velocity {
  var faceAngle = 0.0;
  var moveSpeed = 1.0;
  final target = Position3();
  var spawnX = 0.0;
  var spawnY = 0.0;
  var spawnZ = 0.0;
  var wanderRadius = 100.0;

  int get faceDirection => Direction.fromRadian(faceAngle);

  GameObjectAnimal({
    required double x, required double y, required double z, required int type,
  }) : super(x: x, y: y, z: z, radius: 5, type: type) {
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

class GameObjectWeapon extends GameObject {
  int weaponType;

  @override
  bool get persist => false;

  GameObjectWeapon({
    required double x,
    required double y,
    required double z,
    required this.weaponType,
  }) : super(x: x, y: y, z: z, radius: 14, type: GameObjectType.Weapon) {
    physical = false;
  }

  @override
  void write(Player player) {
    player.writeGameObject(this);
    player.writeByte(weaponType);
  }
}

class GameObjectButterfly extends GameObjectAnimal with Velocity implements Updatable {
  var pause = 0;
  var visible = true;

  GameObjectButterfly({
    required double x,
    required double y,
    required double z,
  }) : super(x: x, y: y, z: z, type: GameObjectType.Butterfly) {
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

  /// TODO illegal business logic
  @override
  void update(Game game) {
    // const timeHourSix = 9 * secondsPerHour;
    // const timeHourSeventeen = 16 * secondsPerHour;
    // if (game.getTime() < timeHourSix || game.getTime() > timeHourSeventeen){
    //   visible = false;
    //   return;
    // } else {
    //   visible = true;
    // }
    //
    // if (pause > 0) {
    //    pause--;
    //    return;
    // }
    //
    //  if (distanceFromPos3(target) < 5){
    //    assignNewTarget();
    //    pause = 100;
    //    return;
    //  }
    //  // angle = this.getAngle(target);
    //  x += xv;
    //  y += yv;
  }
}

class GameObjectChicken extends GameObjectAnimal implements Updatable {

  var pause = 0;
  var state = CharacterState.Idle;

  GameObjectChicken({
    required double x,
    required double y,
    required double z,
  }) : super(x: x, y: y, z: z, type: GameObjectType.Chicken);

  @override
  void write(Player player) {
      player.writeByte(ServerResponse.GameObject_Chicken);
      player.writePosition3(this);
      player.writeByte(state);
      player.writeByte(faceDirection);
  }

  @override
  void update(Game game){
    // const timeHourSix = 6 * secondsPerHour;
    // const timeHourSeventeen = 17 * secondsPerHour;
    // if (game.getTime() < timeHourSix || game.getTime() > timeHourSeventeen){
    //    state = CharacterState.Sitting;
    //    return;
    // }
    //
    // if (pause > 0) {
    //   pause--;
    //   if (pause <= 0){
    //     if (randomBool()){
    //        state = CharacterState.Performing;
    //        pause = 100;
    //     } else {
    //       assignNewTarget();
    //       faceAngle = this.getAngle(target);
    //     }
    //   }
    //   return;
    // }
    //
    // if (distanceFromPos3(target) < 5){
    //   state = CharacterState.Idle;
    //   pause = 100;
    //   return;
    // }
    // state = CharacterState.Running;
    // faceAngle = this.getAngle(target);
    // x += xv;
    // y += yv;
  }
}

class GameObjectJellyfish extends GameObjectAnimal implements Updatable {

  var pause = 0;
  var state = CharacterState.Idle;

  GameObjectJellyfish({
    required double x,
    required double y,
    required double z,
  }) : super(x: x, y: y, z: z, type: GameObjectType.Jellyfish) {
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
  }) : super(x: x, y: y, z: z, type: GameObjectType.Jellyfish) {
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
}
