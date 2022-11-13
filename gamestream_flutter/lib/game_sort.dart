import 'library.dart';

class GameSort {
  static void sortParticlesActive(){
    GameState.totalParticles = ClientState.particles.length;
    for (var pos = 1; pos < GameState.totalParticles; pos++) {
      var min = 0;
      var max = pos;
      var element = ClientState.particles[pos];
      while (min < max) {
        var mid = min + ((max - min) >> 1);
        if (!ClientState.particles[mid].active) {
          max = mid;
        } else {
          min = mid + 1;
        }
      }
      ClientState.particles.setRange(min + 1, pos + 1, ClientState.particles, min);
      ClientState.particles[min] = element;
    }
  }

  static bool verifyTotalActiveParticles() =>
      countActiveParticles() == ClientState.totalActiveParticles;

  static int countActiveParticles(){
    var active = 0;
    for (var i = 0; i < ClientState.particles.length; i++){
      if (ClientState.particles[i].active)
        active++;
    }
    return active;
  }

  static void sortParticles(){
    sortParticlesActive();
    ClientState.totalActiveParticles = 0;
    GameState.totalParticles = ClientState.particles.length;
    for (; ClientState.totalActiveParticles < GameState.totalParticles; ClientState.totalActiveParticles++){
      if (!ClientState.particles[ClientState.totalActiveParticles].active) break;
    }

    if (ClientState.totalActiveParticles == 0) return;

    assert(verifyTotalActiveParticles());

    Engine.insertionSort(
      ClientState.particles,
      compare: compareParticleRenderOrder,
      end: ClientState.totalActiveParticles,
    );
  }

  static int compareParticleRenderOrder(Particle a, Particle b) {
    return a.renderOrder > b.renderOrder ? 1 : -1;
  }
}