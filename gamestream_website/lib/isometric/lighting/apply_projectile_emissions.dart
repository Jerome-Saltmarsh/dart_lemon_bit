
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/classes/projectile.dart';
import 'package:gamestream_flutter/isometric/projectiles.dart';

import 'apply_vector_emission.dart';

void applyProjectileEmissions() {
  for (var i = 0; i < totalProjectiles; i++){
    applyProjectileEmission(projectiles[i]);
  }
}

void applyProjectileEmission(Projectile projectile) {
  if (projectile.type == ProjectileType.Orb) {
    return applyVector3Emission(projectile, maxBrightness: Shade.Very_Bright);
  }
  if (projectile.type == ProjectileType.Fireball) {
    return applyVector3Emission(projectile, maxBrightness: Shade.Very_Bright);
  }
  if (projectile.type == ProjectileType.Arrow) {
    return applyVector3Emission(projectile, maxBrightness: Shade.Medium);
  }
}