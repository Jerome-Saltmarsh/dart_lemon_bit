
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/game_engine/engine_draw.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/game_engine/global_paint.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/state/colours.dart';
import 'package:flutter/material.dart';

import '../maths.dart';
import '../utils.dart';
import 'drawImage.dart';


void drawParticle(Particle particle){

  if(!particle.active){
    throw Exception("Drawning inactive particle");
  }

  double scaleShift = (1 + (particle.z * 0.4)) * particle.scale;
  double heightShift = -particle.z * 20;
  double x = particle.x;
  double y = particle.y;
  double rotation = particle.rotation;

  switch(particle.type){
    case ParticleType.Myst:
      drawImage(images.radial64, x, y);
      break;
    case ParticleType.Smoke:
      double size = 5.33 * scaleShift;
      drawCircle(x, y + heightShift, size * scaleShift, Colors.white);
      break;
    case ParticleType.Shell:
      double size = 1.33 * scaleShift;
      drawCircle(x, y + heightShift, size * scaleShift, Colors.white);
      break;
    case ParticleType.Blood:
      double size = 2.5;
      drawCircle(x, y + heightShift, size * scaleShift, colours.blood);
      break;
    case ParticleType.Head:
      double size = 5;
      drawCircle(x, y, size / scaleShift, Colors.black45);
      drawCircle(x, y + heightShift, size * scaleShift, white);
      break;
    case ParticleType.Arm:
      double length = randomBetween(4, 6);
      double handX = x + velX(rotation, length);
      double handY = y + velY(rotation, length);
      setColor(Colors.black45);
      drawLine3(x, y, handX, handY);
      drawCircle(handX, handY, 2 / scaleShift, Colors.black45);
      paint.color = white;
      drawLine3(x, y + heightShift, handX, handY + heightShift);
      drawCircle(handX, handY  + heightShift, 2 * scaleShift, white);
      break;
    case ParticleType.Organ:
      setColor(Colors.black45);
      drawCircle(x, y, scaleShift / 2, white);
      drawCircle(x, y  + heightShift, 2 * scaleShift, white);
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