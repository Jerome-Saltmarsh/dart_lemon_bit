import 'package:bleed_client/game_engine/game_variables.dart';
import 'package:bleed_client/spawners/spawnBlood.dart';

import '../../common.dart';
import '../keys.dart';
import '../state.dart';

void updateCharacters() {
  if (drawFrame % 2 == 0) return;

  for (int i = 0; i < npcs.length; i++) {
    if (npcs[i][state] == characterStateDead) {
      spawnBlood(npcs[i][x], npcs[i][y], 0);
    }
  }
}
