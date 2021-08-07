import 'package:flutter_game_engine/bleed/mappers/mapParticleToRSTransform.dart';
import 'package:flutter_game_engine/bleed/mappers/mapParticleToRect.dart';

import '../images.dart';
import '../state.dart';
import 'drawAtlas.dart';

void drawParticles2() {
  particleRects = particles2.map(mapParticleToRect).toList();
  particleTransforms = particles2.map(mapParticleToRSTransform).toList();
  drawAtlas(imageParticles, particleTransforms, particleRects);
}
