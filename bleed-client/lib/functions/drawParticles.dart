import 'package:bleed_client/classes/RenderState.dart';
import 'package:bleed_client/instances/game.dart';
import 'package:bleed_client/mappers/mapParticleToRSTransform.dart';
import 'package:bleed_client/mappers/mapParticleToRect.dart';

import '../../images.dart';
import 'drawAtlas.dart';

void drawParticles2() {
  render.particleRects = game.particles.map(mapParticleToRect).toList();
  render.particleTransforms = game.particles.map(mapParticleToRSTransform).toList();
  drawAtlas(imageParticles, render.particleTransforms, render.particleRects);
}
