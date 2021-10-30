import 'package:bleed_client/render/drawCharacterMan.dart';
import 'package:bleed_client/state.dart';

void drawZombies() {
  for (int i = 0; i < compiledGame.totalZombies; i++) {
    drawCharacterMan(compiledGame.zombies[i]);
  }
}
