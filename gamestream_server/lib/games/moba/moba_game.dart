
import 'package:gamestream_server/common/src.dart';
import 'package:gamestream_server/isometric/src.dart';

import 'moba_creep.dart';
import 'moba_player.dart';

class MobaGame extends IsometricGame<MobaPlayer> {

  static const Creeps_Per_Spawn = 3;

  late final IsometricGameObject redSpawn;
  late final IsometricGameObject blueSpawn;

  late final IsometricGameObject redBase;
  late final IsometricGameObject blueBase;

  static const redTeam = 10;
  static const blueTeam = 20;

  static const Teams = [redTeam, blueTeam];

  MobaGame({
    required super.scene,
    required super.time,
    required super.environment,
  }) : super(gameType: GameType.Moba) {
    redBase = IsometricGameObject(
      x: scene.rowLength - 300,
      y: 100,
      z: 24,
      type: GameObjectType.Object,
      subType: ObjectType.Base_Red,
      id: generateUniqueId(),
      radius: 80,
    )
      ..fixed = true
      ..physical = true
      ..hitable = true
      ..collidable = true;

    blueBase = IsometricGameObject(
      x: 300,
      y: scene.columnLength - 100,
      z: 24,
      type: GameObjectType.Object,
      subType: ObjectType.Base_Blue,
      id: generateUniqueId(),
      radius: 80,
    )
      ..fixed = true
      ..physical = true
      ..hitable = true
      ..collidable = true;

    redSpawn = IsometricGameObject(
        x: scene.rowLength - 100,
        y: 100,
        z: 24,
        type: GameObjectType.Object,
        subType: ObjectType.Spawn_Red,
        id: generateUniqueId(),
    )
      ..fixed = true
      ..physical = false
      ..collidable = false;

    blueSpawn = IsometricGameObject(
        x: 100,
        y: scene.columnLength - 100,
        z: 24,
        type: GameObjectType.Object,
        subType: ObjectType.Spawn_Blue,
        id: generateUniqueId(),
    ) ..fixed = true
      ..physical = false
      ..collidable = false;

    gameObjects.add(redBase);
    gameObjects.add(blueBase);
    gameObjects.add(redSpawn);
    gameObjects.add(blueSpawn);


    gameObjects.add(IsometricGameObject(
      x: scene.rowLength - 200,
      y: 300,
      z: 24,
      type: GameObjectType.Object,
      subType: ObjectType.Base_Blue,
      id: generateUniqueId(),
      radius: 80,
    )
      ..fixed = true
      ..physical = true
      ..hitable = true
      ..collidable = true);

    addJob(seconds: 10, action: spawnCreeps, repeat: true);
  }

  @override
  int get maxPlayers => 10;

  @override
  void customOnGameObjectDestroyed(IsometricGameObject gameObject) {
    if (gameObject == redBase){
       throw Exception('Blue Team Wins');
    }
    if (gameObject == blueBase){
       throw Exception('Red Team Wins');
    }
  }


  void spawnCreeps() {
    for (final team in Teams) {
      for (var i = 0; i < Creeps_Per_Spawn; i++) {
        spawn(MobaCreep(
          game: this,
          health: 10,
          weaponDamage: 1,
          team: team,
        ));
      }
    }
  }

  @override
  MobaPlayer buildPlayer() {
    final player = MobaPlayer(game: this);
    player.x = redSpawn.x;
    player.y = redSpawn.y;
    player.z = redSpawn.z;
    player.team = redTeam;
    return player;
  }
}