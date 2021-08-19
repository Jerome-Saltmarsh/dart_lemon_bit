
import 'package:bleed_client/instances/game.dart';

import 'updateParticle.dart';

void updateParticles() {
  for (int i = 0; i < game.particles.length; i++) {
    if (game.particles[i].duration-- < 0) {
      game.particles.removeAt(i);
      i--;
      continue;
    }
  }

  for (int i = 0; i < game.particles.length; i++) {
    updateParticle(game.particles[i]);
  }
  game.particles.sort((a, b) {
    if (a.type.index == b.type.index) return 0;
    if (a.type.index < b.type.index) return 1;
    return -1;
  });
}
