import 'package:flutter_game_engine/bleed/mappers/mapParticleToRSTransform.dart';
import 'package:flutter_game_engine/bleed/mappers/mapParticleToRect.dart';

import '../images.dart';
import '../state.dart';
import 'drawAtlas.dart';

void drawParticles2() {
  particleRects = particles.map(mapParticleToRect).toList();
  particleTransforms = particles.map(mapParticleToRSTransform).toList();
  drawAtlas(imageParticles, particleTransforms, particleRects);
}
