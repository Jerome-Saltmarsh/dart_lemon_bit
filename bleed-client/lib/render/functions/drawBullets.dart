import 'package:bleed_client/classes/Projectile.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/render/drawBullet.dart';

void drawProjectiles(List<Projectile> projectiles) {
  for (int i = 0; i < game.totalProjectiles; i++) {
    drawProjectile(game.projectiles[i]);
  }
}