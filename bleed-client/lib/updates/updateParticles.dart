
import 'package:bleed_client/instances/game.dart';

import 'updateParticle.dart';

void updateParticles() {
  for (int i = 0; i < compiledGame.particles.length; i++) {
    if (compiledGame.particles[i].duration-- < 0) {
      compiledGame.particles.removeAt(i);
      i--;
      continue;
    }
  }

  for (int i = 0; i < compiledGame.particles.length; i++) {
    updateParticle(compiledGame.particles[i]);
  }
  compiledGame.particles.sort((a, b) {
    if (a.type.index == b.type.index) return 0;
    if (a.type.index < b.type.index) return 1;
    return -1;
  });
}
