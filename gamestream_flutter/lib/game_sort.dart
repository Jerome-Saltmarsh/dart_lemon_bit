import 'library.dart';

class GameSort {
  static void sortParticlesActive(){
    GameState.totalParticles = GameState.particles.length;
    for (var pos = 1; pos < GameState.totalParticles; pos++) {
      var min = 0;
      var max = pos;
      var element = GameState.particles[pos];
      while (min < max) {
        var mid = min + ((max - min) >> 1);
        if (!GameState.particles[mid].active) {
          max = mid;
        } else {
          min = mid + 1;
        }
      }
      GameState.particles.setRange(min + 1, pos + 1, GameState.particles, min);
      GameState.particles[min] = element;
    }
  }

  static bool verifyTotalActiveParticles() =>
      countActiveParticles() == GameState.totalActiveParticles;

  static int countActiveParticles(){
    var active = 0;
    for (var i = 0; i < GameState.particles.length; i++){
      if (GameState.particles[i].active)
        active++;
    }
    return active;
  }

  static void sortParticles(){
    sortParticlesActive();
    GameState.totalActiveParticles = 0;
    GameState.totalParticles = GameState.particles.length;
    for (; GameState.totalActiveParticles < GameState.totalParticles; GameState.totalActiveParticles++){
      if (!GameState.particles[GameState.totalActiveParticles].active) break;
    }

    if (GameState.totalActiveParticles == 0) return;

    assert(verifyTotalActiveParticles());

    Engine.insertionSort(
      GameState.particles,
      compare: compareParticleRenderOrder,
      end: GameState.totalActiveParticles,
    );
  }

  static int compareParticleRenderOrder(Particle a, Particle b) {
    return a.renderOrder > b.renderOrder ? 1 : -1;
  }
}