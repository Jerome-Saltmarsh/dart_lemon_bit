
import 'package:bleed_client/classes/Particle.dart';
import 'package:lemon_engine/engine.dart';

const zToScaleRatio = 0.4;
const zToHeightRatio = 20;
const zero = 0.0;
const half = 0.5;
const one = 1;

void mapParticleToDst(Particle particle){
  final renderScale = (one + (particle.z * zToScaleRatio)) * particle.scale;
  final sizeHalf = particle.size * half;

  return engine.mapDst(
    scale: renderScale,
    rotation: zero,
    x: particle.x,
    y: particle.y,
    anchorX: sizeHalf,
    anchorY: sizeHalf + (particle.z * zToHeightRatio)
  );
}