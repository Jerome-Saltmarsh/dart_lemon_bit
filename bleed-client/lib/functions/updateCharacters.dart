import 'package:bleed_client/functions/spawners/spawnBlood.dart';
import 'package:bleed_client/state.dart';


void updateDeadCharacterBlood() {
  if (drawFrame % 2 == 0) return;

  for (int i = 0; i < compiledGame.totalZombies; i++) {
    if (compiledGame.zombies[i].alive) continue;
    spawnBlood(compiledGame.zombies[i].x, compiledGame.zombies[i].y, 0);
  }
}
