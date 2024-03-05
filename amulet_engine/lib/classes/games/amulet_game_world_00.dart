
import '../../common/src.dart';
import '../amulet_game.dart';

class AmuletGameWorld00 extends AmuletGame {
  AmuletGameWorld00({
    required super.amulet,
    required super.scene,
    required super.time,
    required super.environment,
  }) : super(
      amuletScene: AmuletScene.World_00,
      name: 'Forgotten Coast',
      level: 3,
  );
}
