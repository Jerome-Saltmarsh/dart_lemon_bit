

import 'package:gamestream_flutter/isometric/nodes/render/atlas_src_gameobjects.dart';
import 'package:gamestream_flutter/library.dart';

class RenderProjectiles {

  static void renderProjectile(Projectile value) {
    switch (value.type) {
      case ProjectileType.Arrow:
        renderArrow(value.renderX, value.renderY, value.angle);
        return;
      case ProjectileType.Orb:
        // return renderOrb(value.renderX, value.renderY);
      case ProjectileType.Fireball:
        break;
      case ProjectileType.Bullet:
        renderBullet(value.renderX, value.renderY, value.angle);
        break;
      case ProjectileType.Wave:
        break;
      default:
        return;
    }
  }


  static void renderBullet(double x, double y, double rotation) {
    Engine.renderSpriteRotated(
      image: GameImages.gameobjects,
      srcX: 87,
      srcY: 48,
      srcWidth: 2,
      srcHeight: 32,
      dstX: x,
      dstY: y,
      rotation: rotation,
      scale: 1,
    );
  }

  static void renderArrow(double x, double y, double rotation) {
    Engine.renderSpriteRotated(
      image: GameImages.gameobjects,
      srcX: AtlasGameObjects.arrow_shadow_x,
      srcY: AtlasGameObjects.arrow_shadow_y,
      srcWidth: AtlasGameObjects.arrow_width,
      srcHeight: AtlasGameObjects.arrow_height,
      dstX: x,
      dstY: y + 10,
      rotation: rotation,
      scale: 0.7,
    );

    Engine.renderSpriteRotated(
      image: GameImages.gameobjects,
      srcX: AtlasGameObjects.arrow_x,
      srcY: AtlasGameObjects.arrow_y,
      srcWidth: AtlasGameObjects.arrow_width,
      srcHeight: AtlasGameObjects.arrow_height,
      dstX: x,
      dstY: y,
      rotation: rotation - Engine.PI_Quarter,
      scale: 0.7,
    );

    // renderRotated(
    //     dstX: x,
    //     dstY: y + 10,
    //     srcX: 2172,
    //     srcY: 0,
    //     srcWidth: 9,
    //     srcHeight: 43,
    //     rotation: angle - piQuarter,
    //     scale: 0.5
    // );
    // renderRotated(
    //     dstX: x,
    //     dstY: y,
    //     srcX: 2182,
    //     srcY: 0,
    //     srcWidth: 9,
    //     srcHeight: 44,
    //     rotation: angle - piQuarter,
    //     scale: 0.5
    // );
  }

}