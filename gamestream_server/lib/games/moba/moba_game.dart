
import 'package:gamestream_server/common/src.dart';
import 'package:gamestream_server/isometric/src.dart';

import 'moba_creep.dart';
import 'moba_player.dart';

class MobaGame extends IsometricGame<MobaPlayer> {

  static const Creeps_Per_Spawn = 3;

  late final IsometricGameObject teamRedBase;
  late final IsometricGameObject teamBlueBase;

  static const teamRed = 10;
  static const teamBlue = 20;

  MobaGame({
    required super.scene,
    required super.time,
    required super.environment,
  }) : super(gameType: GameType.Moba) {

    teamRedBase = IsometricGameObject(
        x: scene.rowLength - 100,
        y: 100,
        z: 24,
        type: GameObjectType.Object,
        subType: ObjectType.Base_Red,
        id: generateUniqueId(),
    );

    teamRedBase.hitable = true;

    teamBlueBase = IsometricGameObject(
        x: 100,
        y: scene.columnLength - 100,
        z: 24,
        type: GameObjectType.Object,
        subType: ObjectType.Base_Blue,
        id: generateUniqueId(),
    );

    gameObjects.add(teamRedBase);
    gameObjects.add(teamBlueBase);

    addJob(seconds: 10, action: spawnCreeps, repeat: true);
  }

  @override
  int get maxPlayers => 10;

  void spawnCreeps() {
    for (var i = 0; i < Creeps_Per_Spawn; i++){
      spawn(MobaCreep(
        game: this,
        health: 10,
        weaponDamage: 1,
        team: teamRed,
      )
      );

      spawn(MobaCreep(
        game: this,
        health: 10,
        weaponDamage: 1,
        team: teamBlue,
      )
      );
    }
  }

  @override
  MobaPlayer buildPlayer() {
    final player = MobaPlayer(game: this);
    player.x = teamRedBase.x;
    player.y = teamRedBase.y;
    player.z = teamRedBase.z;
    player.team = teamRed;
    return player;
  }
}