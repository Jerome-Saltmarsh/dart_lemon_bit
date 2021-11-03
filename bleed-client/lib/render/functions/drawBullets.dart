import 'package:bleed_client/render/drawBullet.dart';
import 'package:bleed_client/state.dart';

void drawBullets(List bullets) {
  for (int i = 0; i < compiledGame.totalBullets; i++) {
    drawBullet(compiledGame.bullets[i].x, compiledGame.bullets[i].y);
  }
}