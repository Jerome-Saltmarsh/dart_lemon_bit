import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/getters/getShading.dart';
import 'package:bleed_client/render/draw/drawAtlas.dart';
import 'package:bleed_client/render/mappers/mapParticleToDst.dart';
import 'package:bleed_client/render/mappers/mapParticleToSrc.dart';
import 'package:bleed_client/render/queries/equalOrDarkerToVeryDark.dart';
import 'package:lemon_engine/queries/on_screen.dart';

void drawParticle(Particle particle){
  if (!onScreen(particle.x, particle.y)) return;
  Shade shade = getShadeAtPosition(particle.x, particle.y);
  if (equalOrDarkerToVeryDark(shade)) return;
  drawAtlas(
      dst: mapParticleToDst(particle),
      src: mapParticleToSrc(particle)
  );
}