
import 'package:gamestream_flutter/classes/Particle.dart';
import 'package:lemon_engine/engine.dart';

const zToScaleRatio = 0.4;
const zToHeightRatio = 20;

void mapParticleToDst(Particle particle){
  final renderScale = (1.0 + (particle.z * zToScaleRatio)) * particle.scale;
  final sizeHalf = particle.size * 0.5;

  assert(renderScale > 0);

  return engine.mapDst(
    scale: renderScale,
    rotation: particle.rotation,
    x: particle.x,
    y: particle.y - (particle.z * zToHeightRatio),
    anchorX: sizeHalf,
    anchorY: sizeHalf,
  );
}