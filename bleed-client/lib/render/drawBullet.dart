

import 'package:bleed_client/classes/Projectile.dart';
import 'package:bleed_client/common/enums/ProjectileType.dart';
import 'package:bleed_client/getters/inDarkness.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/rects.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/render/draw_circle.dart';
import 'package:lemon_engine/render/draw_image_rect.dart';
import 'package:lemon_math/randomItem.dart';

void drawProjectile(Projectile projectile){
  switch(projectile.type){
    case ProjectileType.Bullet:
      if (inDarkness(projectile.x, projectile.y)) return;
      drawCircle(projectile.x, projectile.y, 2, Colors.white);
      break;
    case ProjectileType.Fireball:
      drawFireball(projectile.x, projectile.y);
      break;
  }
}

void drawFireball(double x, double y){
  drawImageRect(images.fireball, randomItem(srcRects.fireballs), Rect.fromLTWH(x - 16, y - 16, 32, 32));
}