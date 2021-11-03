import 'package:bleed_client/render/drawCharacterZombie.dart';
import 'package:bleed_client/state.dart';

void drawZombies() {
  for (int i = 0; i < compiledGame.totalZombies; i++) {
    drawCharacterZombie(compiledGame.zombies[i]);
  }
}
