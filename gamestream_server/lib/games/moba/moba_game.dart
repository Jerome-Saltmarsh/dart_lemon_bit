
import 'package:gamestream_server/common/src.dart';
import 'package:gamestream_server/isometric/src.dart';

import 'moba_creep.dart';
import 'moba_player.dart';

class MobaGame extends IsometricGame<MobaPlayer> {

  late final IsometricGameObject redBase1;
  late final IsometricGameObject blueBase1;

  final team1 = 10;
  final team2 = 20;

  MobaGame({
    required super.scene,
    required super.time,
    required super.environment,
  }) : super(gameType: GameType.Moba) {
    redBase1 = IsometricGameObject(
        x: scene.rowLength - 100,
        y: 100,
        z: 24,
        type: ItemType.GameObjects_Base_Red,
        id: generateUniqueId(),
    );

    redBase1.hitable = true;

    blueBase1 = IsometricGameObject(
        x: 100,
        y: scene.columnLength - 100,
        z: 24,
        type: ItemType.GameObjects_Base_Blue,
        id: generateUniqueId(),
    );

    gameObjects.add(redBase1);
    gameObjects.add(blueBase1);

    addJob(seconds: 10, action: spawnCreeps, repeat: true);
  }

  @override
  int get maxPlayers => 10;

  void spawnCreeps() {
    for (var i = 0; i < 3; i++){
      spawn(MobaCreep(
        game: this,
        characterType: CharacterType.Zombie,
        health: 10,
        damage: 1,
        team: team1,
        weaponType: ItemType.Empty,
        weaponRange: 20,
        x: redBase1.x,
        y: redBase1.y,
        z: redBase1.z,
      ));
    }
  }

  @override
  MobaPlayer buildPlayer() {
    final player = MobaPlayer(game: this);
    player.x = redBase1.x;
    player.y = redBase1.y;
    player.z = redBase1.z;
    player.team = team1;
    return player;
  }

  @override
  void onPlayerUpdateRequestReceived({
    required MobaPlayer player,
    required int direction,
    required bool mouseLeftDown,
    required bool mouseRightDown,
    required bool keySpaceDown,
    required bool inputTypeKeyboard}) {

    if (player.deadOrBusy) return;
    if (!player.active) return;

    if (mouseRightDown){
      player.selectDebugCharacterNearestToMouse();
    }

    if (direction != IsometricDirection.None){
      player.runToDestinationEnabled = false;
      characterRunInDirection(player, IsometricDirection.fromInputDirection(direction));
    } else if (!player.runToDestinationEnabled){
      player.setCharacterStateIdle();
    }
  }
}