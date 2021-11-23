import 'dart:typed_data';

import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/render/functions/mapDst.dart';

Float32List mapParticleToDst(Particle particle){
  return mapDst(
    scale: particle.scale,
    rotation: particle.rotation,
    x: particle.x,
    y: particle.y
  );
}