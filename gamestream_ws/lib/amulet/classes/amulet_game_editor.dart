

import 'package:gamestream_ws/amulet.dart';
import 'package:gamestream_ws/packages.dart';

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