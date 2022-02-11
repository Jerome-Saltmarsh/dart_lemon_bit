


import 'package:bleed_client/classes/Projectile.dart';
import 'package:bleed_client/common/enums/ProjectileType.dart';
import 'package:bleed_client/modules/isometric/atlas.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:lemon_engine/engine.dart';

// TODO Refactor
// void mapProjectileToSrc(Projectile projectile) {
//   switch(projectile.type){
//     case ProjectileType.Bullet:
//       final shade = isometric.properties.getShadeAtPosition(projectile.x, projectile.y);
//       return engine.state.mapSrc(
//           x: atlas.particles.shell.x + (projectile.direction.index * 32.0),
//           y: atlas.particles.shell.y + shade * 32.0,
//           width: 32,
//           height: 32
//       );
//     case ProjectileType.Fireball:
//       throw Exception();
//   }
//   throw Exception();
// }
