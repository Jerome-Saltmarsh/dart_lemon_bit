
import 'package:bleed_common/particle_type.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/classes/particle.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';



void sortParticlesActive(){
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

bool verifyTotalActiveParticles() =>
   countActiveParticles() == GameState.totalActiveParticles;

int countActiveParticles(){
  var active = 0;
  for (var i = 0; i < GameState.particles.length; i++){
    if (GameState.particles[i].active)
      active++;
  }
  return active;
}

void sortParticles(){
  sortParticlesActive();
  GameState.totalActiveParticles = 0;
  GameState.totalParticles = GameState.particles.length;
  for (; GameState.totalActiveParticles < GameState.totalParticles; GameState.totalActiveParticles++){
      if (!GameState.particles[GameState.totalActiveParticles].active) break;
  }

  if (GameState.totalActiveParticles == 0) return;
  
  assert(verifyTotalActiveParticles());

  insertionSort(
    GameState.particles,
    compare: _compareParticles,
    end: GameState.totalActiveParticles,
  );
}

int _compareParticles(Particle a, Particle b) {
    return a.renderOrder > b.renderOrder ? 1 : -1;
}

void updateParticlesZombieParts() {
  if (Engine.paintFrame % 6 != 0) return;
  for (var i = 0; i < GameState.totalActiveParticles; i++) {
    final particle = GameState.particles[i];
    if (!particle.active) break;
    if (!particleEmitsBlood(particle.type)) continue;
    if (particle.speed < 2.0) continue;
    GameState.spawnParticleBlood(
      x: particle.x,
      y: particle.y,
      z: particle.z,
      zv: 0,
      angle: 0,
      speed: 0,
    );
  }
}

bool particleEmitsBlood(int type){
  if (type == ParticleType.Zombie_Head) return true;
  if (type == ParticleType.Zombie_Torso) return true;
  if (type == ParticleType.Zombie_Arm) return true;
  if (type == ParticleType.Zombie_leg) return true;
  return false;
}


int get bodyPartDuration => randomInt(120, 200);
