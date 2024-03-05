

import 'package:amulet_engine/common/src/amulet/amulet_scene.dart';

import '../../isometric/src.dart';
import '../amulet_game.dart';
import '../amulet_player.dart';

class AmuletGameEditor extends AmuletGame {
  AmuletGameEditor({
    required super.amulet,
    required super.scene,
  }) : super(
     time: IsometricTime(),
     environment: IsometricEnvironment(enabled: false),
     name: generateRandomName(),
     amuletScene: AmuletScene.Editor,
     level: 1,
  );

  @override
  void customOnPlayerRevived(AmuletPlayer player) {
    player.x = scene.rowLength * 0.5;
    player.y = scene.columnLength * 0.5;
    player.z = scene.heightLength;
  }
}