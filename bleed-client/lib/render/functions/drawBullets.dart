import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/render/drawBullet.dart';

void drawBullets(List bullets) {
  for (int i = 0; i < game.totalProjectiles; i++) {
    drawBullet(game.projectiles[i].x, game.projectiles[i].y);
  }
}