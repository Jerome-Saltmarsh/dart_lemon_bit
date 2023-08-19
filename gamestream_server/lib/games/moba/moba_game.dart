
import 'package:gamestream_server/common/src.dart';
import 'package:gamestream_server/isometric/src.dart';

import 'moba_creep.dart';
import 'moba_player.dart';

class MobaGame extends IsometricGame<MobaPlayer> {

  static const Creeps_Per_Spawn = 3;

  late final GameObject redSpawn;
  late final GameObject blueSpawn;

  late final GameObject redBase;
  late final GameObject blueBase;

  static const redTeam = 10;
  static const blueTeam = 20;

  static const Base_Health = 200;
  static const Base_Radius = 80.0;

  static const Teams = [redTeam, blueTeam];

  MobaGame({
    required super.scene,
    required super.time,
    required super.environment,
  }) : super(gameType: GameType.Moba) {

    redBase = GameObject(
      x: scene.rowLength - 300,
      y: 100,
      z: 24,
      type: ItemType.Object,
      subType: ObjectType.Base_Red,
      id: generateUniqueId(),
      radius: Base_Radius,
      health: Base_Health,
      team: redTeam,
    )
      ..fixed = true
      ..physical = true
      ..hitable = true
      ..collidable = true;

    blueBase = GameObject(
      x: 300,
      y: scene.columnLength - 100,
      z: 24,
      type: ItemType.Object,
      subType: ObjectType.Base_Blue,
      id: generateUniqueId(),
      radius: Base_Radius,
      health: Base_Health,
      team: blueTeam,
    )
      ..fixed = true
      ..physical = true
      ..hitable = true
      ..collidable = true;

    redSpawn = GameObject(
        x: scene.rowLength - 100,
        y: 100,
        z: 24,
        type: ItemType.Object,
        subType: ObjectType.Spawn_Red,
        id: generateUniqueId(),
        team: redTeam,
    )
      ..fixed = true
      ..physical = false
      ..collidable = false;

    blueSpawn = GameObject(
        x: 100,
        y: scene.columnLength - 100,
        z: 24,
        type: ItemType.Object,
        subType: ObjectType.Spawn_Blue,
        id: generateUniqueId(),
        team: blueTeam,
    ) ..fixed = true
      ..physical = false
      ..collidable = false;

    gameObjects.add(redBase);
    gameObjects.add(blueBase);
    gameObjects.add(redSpawn);
    gameObjects.add(blueSpawn);


    gameObjects.add(GameObject(
      x: scene.rowLength - 200,
      y: 400,
      z: 24,
      type: ItemType.Object,
      subType: ObjectType.Base_Blue,
      id: generateUniqueId(),
      radius: 80,
      health: 100,
      team: blueTeam,
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
  void updateCharacter(Character character) {
    super.updateCharacter(character);

    // if (character.weaponStatePerforming && character.weaponStateDuration == 2){
    //    final target = character.target;
    //    if (target is IsometricCollider){
    //      applyHit(
    //          srcCharacter: character,
    //          target: target,
    //          damage: character.weaponDamage,
    //      );
    //    }
    // }
  }

  @override
  void customOnGameObjectDestroyed(GameObject gameObject) {
    if (gameObject == redBase){
       return;
       // throw Exception('Blue Team Wins');
    }
    if (gameObject == blueBase){
      return;
       // throw Exception('Red Team Wins');
    }
  }

  void spawnCreeps() {
    for (final team in Teams) {
      for (var i = 0; i < Creeps_Per_Spawn; i++) {
        add(MobaCreep(
          game: this,
          health: 10,
          weaponDamage: 1,
          team: team,
        ));
      }
    }
  }

  @override
  MobaPlayer buildPlayer() => MobaPlayer(
        game: this,
        team: MobaGame.blueTeam,
        x : redSpawn.x,
        y : redSpawn.y,
        z : redSpawn.z,
    );
}