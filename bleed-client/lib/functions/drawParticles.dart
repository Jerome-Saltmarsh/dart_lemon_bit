import 'package:bleed_client/instances/game.dart';
import 'package:bleed_client/mappers/mapParticleToRSTransform.dart';
import 'package:bleed_client/mappers/mapParticleToRect.dart';

import '../../images.dart';
import '../state.dart';
import 'drawAtlas.dart';

void drawParticles2() {
  particleRects = game.particles.map(mapParticleToRect).toList();
  particleTransforms = game.particles.map(mapParticleToRSTransform).toList();
  drawAtlas(imageParticles, particleTransforms, particleRects);
}
