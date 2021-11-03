
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/engine/functions/drawCircle.dart';
import 'package:bleed_client/engine/render/drawImage.dart';
import 'package:bleed_client/engine/state/paint.dart';
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/getters/getShading.dart';
import 'package:bleed_client/mappers/mapDurationToMystImage.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:flutter/material.dart';

import '../maths.dart';
import '../utils.dart';

const _headSize = 5.0;

void drawParticle(Particle particle){
  double x = particle.x;
  double y = particle.y;

  Shading shading = getShadeAtPosition(particle.x, particle.y);
  if (shading == Shading.VeryDark) return;

  double scaleShift = (1 + (particle.z * 0.4)) * particle.scale;
  double heightShift = -particle.z * 20;
  double rotation = particle.rotation;

  switch(particle.type){
    case ParticleType.Myst:
      drawImage(mapMystDurationToImage(particle.duration), x - 32, y - 32);
      break;
    case ParticleType.Smoke:
      double size = 5.33 * scaleShift;
      drawCircle(x, y + heightShift, size * scaleShift, Colors.white);
      break;
    case ParticleType.Shell:
      double size = 1.33 * scaleShift;
      Color color = colours.white;
      if (shading == Shading.Dark){
        color = colours.grey;
      }else if (shading == Shading.Medium){
        color = colours.greyDark;
      }
      drawCircle(x, y + heightShift, size * scaleShift, color);
      break;
    case ParticleType.Blood:
      double size = 2.5;
      Color color = colours.blood;
      if (shading == Shading.Dark){
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
      double handX = x + velX(rotation, length);
      double handY = y + velY(rotation, length);
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