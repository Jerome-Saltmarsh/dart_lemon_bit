

import '../functions/generate_random_name.dart';
import '../packages/src.dart';
import 'amulet_game.dart';
import 'amulet_player.dart';

class AmuletGameEditor extends AmuletGame {
  AmuletGameEditor({
    required super.amulet,
    required super.scene,
  }) : super(
     time: IsometricTime(),
     environment: IsometricEnvironment(enabled: false),
     name: generateRandomName(),
     amuletScene: AmuletScene.Editor,
  );

  @override
  void revive(AmuletPlayer player) {
    super.revive(player);
    player.x = scene.rowLength * 0.5;
    player.y = scene.columnLength * 0.5;
    player.z = scene.heightLength;
  }
}