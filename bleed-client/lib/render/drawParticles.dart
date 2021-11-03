import 'package:bleed_client/classes/RenderState.dart';
import 'package:bleed_client/mappers/mapParticleToRSTransform.dart';
import 'package:bleed_client/mappers/mapParticleToRect.dart';

import '../../images.dart';
import '../engine/render/drawAtlas.dart';
import '../state.dart';

void drawParticles2() {
  render.particleRects = compiledGame.particles.map(mapParticleToRect).toList();
  render.particleTransforms = compiledGame.particles.map(mapParticleToRSTransform).toList();
  drawAtlas(images.particles, render.particleTransforms, render.particleRects);
}
