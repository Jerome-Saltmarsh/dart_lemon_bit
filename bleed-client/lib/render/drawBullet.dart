

import 'package:bleed_client/classes/Projectile.dart';
import 'package:bleed_client/common/enums/ProjectileType.dart';
import 'package:bleed_client/getters/inDarkness.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/render/draw_circle.dart';

void drawProjectile(Projectile projectile){
  switch(projectile.type){
    case ProjectileType.Bullet:
      if (inDarkness(projectile.x, projectile.y)) return;
      drawCircle(projectile.x, projectile.y, 2, Colors.white);
      break;
    case ProjectileType.Fireball:
      drawCircle(projectile.x, projectile.y, 10, Colors.yellow);
      break;
  }
}