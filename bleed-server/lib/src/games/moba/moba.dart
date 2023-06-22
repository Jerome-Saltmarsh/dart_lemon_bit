
import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/src/isometric/src.dart';

import 'moba_player.dart';

class Moba extends IsometricGame<MobaPlayer> {

  late final IsometricGameObject redBase1;
  late final IsometricGameObject blueBase1;

  Moba({
    required super.scene,
    required super.time,
    required super.environment,
  }) : super(gameType: GameType.Moba) {
    redBase1 = IsometricGameObject(
        x: scene.gridRowLength - 100,
        y: 100,
        z: 24,
        type: ItemType.GameObjects_Base_Red,
        id: generateUniqueId(),
    );

    blueBase1 = IsometricGameObject(
        x: 100,
        y: scene.gridColumnLength - 100,
        z: 24,
        type: ItemType.GameObjects_Base_Blue,
        id: generateUniqueId(),
    );

    gameObjects.add(redBase1);
    gameObjects.add(blueBase1);
  }


  @override
  int get maxPlayers => 10;

  @override
  MobaPlayer buildPlayer() {
    final player = MobaPlayer(game: this);
    player.x = redBase1.x;
    player.y = redBase1.y;
    player.z = redBase1.z;
    return player;
  }
}