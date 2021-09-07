import 'package:bleed_client/spawners/spawnBlood.dart';

import '../../common.dart';
import '../keys.dart';
import '../state.dart';

void updateCharacters() {
  if (drawFrame % 2 == 0) return;

  for (int i = 0; i < compiledGame.npcs.length; i++) {
    if (compiledGame.npcs[i][0] == characterStateDead) {
      spawnBlood(compiledGame.npcs[i][x], compiledGame.npcs[i][y], 0);
    }
  }
}
