
import 'package:bleed_common/particle_type.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/classes/particle.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';



void sortParticlesActive(){
  Game.totalParticles = Game.particles.length;
  for (var pos = 1; pos < Game.totalParticles; pos++) {
    var min = 0;
    var max = pos;
    var element = Game.particles[pos];
    while (min < max) {
      var mid = min + ((max - min) >> 1);
      if (!Game.particles[mid].active) {
        max = mid;
      } else {
        min = mid + 1;
      }
    }
    Game.particles.setRange(min + 1, pos + 1, Game.particles, min);
    Game.particles[min] = element;
  }
}

bool verifyTotalActiveParticles() =>
   countActiveParticles() == Game.totalActiveParticles;

int countActiveParticles(){
  var active = 0;
  for (var i = 0; i < Game.particles.length; i++){
    if (Game.particles[i].active)
      active++;
  }
  return active;
}

void sortParticles(){
  sortParticlesActive();
  Game.totalActiveParticles = 0;
  Game.totalParticles = Game.particles.length;
  for (; Game.totalActiveParticles < Game.totalParticles; Game.totalActiveParticles++){
      if (!Game.particles[Game.totalActiveParticles].active) break;
  }

  if (Game.totalActiveParticles == 0) return;
  
  assert(verifyTotalActiveParticles());

  insertionSort(
    Game.particles,
    compare: _compareParticles,
    end: Game.totalActiveParticles,
  );
}

int _compareParticles(Particle a, Particle b) {
    return a.renderOrder > b.renderOrder ? 1 : -1;
}

void updateParticlesZombieParts() {
  if (Engine.paintFrame % 6 != 0) return;
  for (var i = 0; i < Game.totalActiveParticles; i++) {
    final particle = Game.particles[i];
    if (!particle.active) break;
    if (!particleEmitsBlood(particle.type)) continue;
    if (particle.speed < 2.0) continue;
    Game.spawnParticleBlood(
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
