

import 'projectile_type.dart';

enum DamageType {
  Bludgeon,
  Slash,
  Pierce,
  Fire,
  Ice;

  static DamageType fromProjectileType(int projectileType){
    switch (projectileType){
      case ProjectileType.Fireball:
        return Fire;
      case ProjectileType.FrostBall:
        return Ice;
      case ProjectileType.Arrow:
        return Pierce;
      case ProjectileType.Ice_Arrow:
        return Ice;
      case ProjectileType.Fire_Arrow:
        return Fire;
      default:
        throw Exception('DamageType.fromProjectileType($projectileType)');
    }
  }
}