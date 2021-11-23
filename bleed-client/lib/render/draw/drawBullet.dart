import 'package:bleed_client/classes/Projectile.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/ProjectileType.dart';
import 'package:bleed_client/getters/inDarkness.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/mappers/mapDirectionToAngle.dart';
import 'package:bleed_client/rects.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/render/draw_circle.dart';
import 'package:lemon_engine/state/canvas.dart';
import 'package:lemon_engine/state/paint.dart';
import 'package:lemon_math/randomItem.dart';

void drawProjectile(Projectile projectile){
  switch(projectile.type){
    case ProjectileType.Bullet:
      if (inDarkness(projectile.x, projectile.y)) return;
      drawCircle(projectile.x, projectile.y, 2, Colors.white);
      break;
    case ProjectileType.Fireball:
      drawFireball(projectile.x, projectile.y, projectile.direction);
      break;
  }
}



void drawFireball(double x, double y, Direction direction){
  double angle = mapDirectionToAngle[direction];

  RSTransform rsTransform = RSTransform.fromComponents(
      rotation: angle,
      scale: 1,
      anchorX: 16,
      anchorY: 16,
      translateX: x,
      translateY: y
  );


  // Float32List transform = Float32List(4);
  // transform[0] = 0;
  // transform[1] = 0;
  // transform[2] = x;
  // transform[3] = y;
  //
  // Rect srcRec = randomItem(srcRects.fireballs);
  // Float32List src = Float32List(4);
  // src[0] = srcRec.left;
  // src[1] = 0;
  // src[2] = srcRec.right;
  // src[3] = 32;

  globalCanvas.drawAtlas(
      images.fireball,
      [rsTransform],
      [randomItem(srcRects.fireballs)],
      null,
      null,
      null,
      paint
  );
}
