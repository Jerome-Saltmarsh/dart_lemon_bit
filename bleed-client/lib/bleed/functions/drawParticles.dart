import 'package:flutter_game_engine/bleed/classes/Particle.dart';

import '../draw.dart';
import '../images.dart';
import '../rects.dart';
import '../state.dart';
import 'drawAtlas.dart';

void drawParticles2() {
  particleRects.clear();
  particleTransforms.clear();

  for (Particle particle in particles2) {
    particleRects.add(rectParticleSmoke);
    particleTransforms.add(rsTransform(x: particle.x, y: particle.y + particle.z, anchorX: 32, anchorY: 32, scale: particle.scale)
    );
  }
  drawAtlas(imageParticles, particleTransforms, particleRects);
}
