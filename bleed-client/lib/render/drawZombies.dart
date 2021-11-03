import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/render/drawCharacterZombie.dart';

void drawZombies() {
  for (int i = 0; i < game.totalZombies; i++) {
    drawCharacterZombie(game.zombies[i]);
  }
}
