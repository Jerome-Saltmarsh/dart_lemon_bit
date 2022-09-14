

import 'package:lemon_math/library.dart';

import '../classes/library.dart';
import '../common/game_object_type.dart';

void movePlayerToCrystal(Player player) {
  for (final gameObject in player.game.gameObjects) {
    if (gameObject.type != GameObjectType.Crystal) continue;
    final angle = randomAngle();
    const distance = 50.0;
    player.x = gameObject.x + getAdjacent(angle, distance);
    player.y = gameObject.y + getOpposite(angle, distance);
  }
}