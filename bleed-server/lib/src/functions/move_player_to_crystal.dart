import 'package:bleed_server/gamestream.dart';

import 'package:lemon_math/library.dart';

void movePlayerToCrystal(IsometricPlayer player) {
  for (final gameObject in player.game.gameObjects) {
    if (gameObject.type != ItemType.GameObjects_Crystal) continue;
    final angle = randomAngle();
    const distance = 50.0;
    player.x = gameObject.x + getAdjacent(angle, distance);
    player.y = gameObject.y + getOpposite(angle, distance);
    player.z = gameObject.z;
    return;
  }
}