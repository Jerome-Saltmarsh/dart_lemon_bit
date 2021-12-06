import 'package:bleed_client/functions/spawners/spawnBlood.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/state/game.dart';


void updateDeadCharacterBlood() {
  if (drawFrame % 8 == 0) return;

  for (int i = 0; i < game.totalZombies.value; i++) {
    if (game.zombies[i].alive) continue;
    spawnBlood(game.zombies[i].x, game.zombies[i].y, 0);
  }
}
