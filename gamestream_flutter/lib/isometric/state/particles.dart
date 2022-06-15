
import 'package:lemon_math/library.dart';
import 'package:gamestream_flutter/isometric/classes/particle.dart';

final particles = <Particle>[];


void sortParticles(){
  insertionSort(
    particles,
    compare: _compareParticles,
  );
}

int _compareParticles(Particle a, Particle b) {
  if (!a.active) {
    if (!b.active){
      return 0;
    }
    return 1;
  }
  if (!b.active) {
    return -1;
  }
  return a.y > b.y ? 1 : -1;
}
