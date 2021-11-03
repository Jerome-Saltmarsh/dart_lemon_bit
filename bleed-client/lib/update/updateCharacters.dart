import 'package:bleed_client/functions/spawners/spawnBlood.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state.dart';


void updateDeadCharacterBlood() {
  if (drawFrame % 2 == 0) return;

  for (int i = 0; i < game.totalZombies; i++) {
    if (game.zombies[i].alive) continue;
    spawnBlood(game.zombies[i].x, game.zombies[i].y, 0);
  }
}
