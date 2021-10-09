import 'package:bleed_client/spawners/spawnBlood.dart';

import '../../common.dart';
import '../keys.dart';
import '../state.dart';

void updateCharacters() {
  if (drawFrame % 2 == 0) return;

  for (int i = 0; i < compiledGame.zombies.length; i++) {
    if (compiledGame.zombies[i][0] == characterStateDead) {
      spawnBlood(compiledGame.zombies[i][x], compiledGame.zombies[i][y], 0);
    }
  }
}
