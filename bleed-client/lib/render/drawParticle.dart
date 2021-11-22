

import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/getters/getShading.dart';
import 'package:bleed_client/render/drawCharacterMan.dart';
import 'package:bleed_client/render/functions/mapParticleToDst.dart';
import 'package:bleed_client/render/functions/mapParticleToSrc.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/render/draw_circle.dart';
import 'package:lemon_engine/state/paint.dart';
import 'package:lemon_math/adjacent.dart';
import 'package:lemon_math/opposite.dart';
import 'package:lemon_math/random_between.dart';

import '../utils.dart';

const _headSize = 5.0;

void drawParticle(Particle particle){

  Shade shading = getShadeAtPosition(particle.x, particle.y);
  if (shading.index >= Shade.VeryDark.index) return;

  double x = particle.x;
  double y = particle.y;
  double scaleShift = (1 + (particle.z * 0.4)) * particle.scale;
  double heightShift = -particle.z * 20;
  double rotation = particle.rotation;

  switch(particle.type){
    case ParticleType.Myst:
      drawAtlas(mapParticleToDst(particle), mapParticleToSrc(particle));
      break;
    case ParticleType.Smoke:
      double size = 5.33 * scaleShift;
      drawCircle(x, y + heightShift, size * scaleShift, Colors.white);
      break;
    case ParticleType.Shell:
      double size = 1.33 * scaleShift;
      Color color = colours.white;
      if (shading == Shade.Dark){
        color = colours.grey;
      }else if (shading == Shade.Medium){
        color = colours.greyDark;
      }
      drawCircle(x, y + heightShift, size * scaleShift, color);
      break;
    case ParticleType.Blood:
      double size = 2.5;
      Color color = colours.blood;
      if (shading == Shade.Dark){
        color = colours.redDarkest;
      }
      drawCircle(x, y + heightShift, size * scaleShift, color);
      break;
    case ParticleType.Head:
      drawCircle(x, y, _headSize / scaleShift, Colors.black45);
      drawCircle(x, y + heightShift, _headSize * scaleShift, getColorSkin(shading));
      break;
    case ParticleType.Arm:
      Color color = getColorSkin(shading);
      double length = randomBetween(4, 6);
      double handX = x + adjacent(rotation, length);
      double handY = y + opposite(rotation, length);
      setColor(color);
      drawLine3(x, y, handX, handY);
      drawCircle(handX, handY, 2 / scaleShift, color);
      drawLine3(x, y + heightShift, handX, handY + heightShift);
      drawCircle(handX, handY  + heightShift, 2 * scaleShift, color);
      break;
    case ParticleType.Organ:
      Color color = getColorSkin(shading);
      drawCircle(x, y, scaleShift / 2, color);
      drawCircle(x, y  + heightShift, 2 * scaleShift, color);
      break;
    case ParticleType.Shrapnel:
      double size = 2.5;
      drawCircle(x, y + heightShift, size * scaleShift, Colors.black);
      break;
    case ParticleType.FireYellow:
      double size = 2.5;
      drawCircle(x, y + heightShift, size * scaleShift, Colors.yellow);
      break;
  }
}