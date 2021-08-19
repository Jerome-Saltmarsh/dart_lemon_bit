import 'package:bleed_client/instances/game.dart';
import 'package:bleed_client/spawners/spawnBlood.dart';

import '../../common.dart';
import '../keys.dart';
import '../state.dart';

void updateCharacters() {
  if (drawFrame % 2 == 0) return;

  for (int i = 0; i < game.npcs.length; i++) {
    if (game.npcs[i][state] == characterStateDead) {
      spawnBlood(game.npcs[i][x], game.npcs[i][y], 0);
    }
  }
}
