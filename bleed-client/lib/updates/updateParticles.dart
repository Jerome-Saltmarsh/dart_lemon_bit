
import '../state.dart';
import 'updateParticle.dart';

void updateParticles() {
  for (int i = 0; i < particles.length; i++) {
    if (particles[i].duration-- < 0) {
      particles.removeAt(i);
      i--;
      continue;
    }
  }

  for (int i = 0; i < particles.length; i++) {
    updateParticle(particles[i]);
  }
  particles.sort((a, b) {
    if (a.type.index == b.type.index) return 0;
    if (a.type.index < b.type.index) return 1;
    return -1;
  });
}
