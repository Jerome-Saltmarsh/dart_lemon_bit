

import 'package:gamestream_flutter/isometric/nodes/render/atlas_src_gameobjects.dart';
import 'package:gamestream_flutter/library.dart';

class RenderProjectiles {
  static void renderArrow(double x, double y, double rotation) {
    Engine.renderSpriteRotated(
      image: GameImages.gameobjects,
      srcX: AtlasGameObjects.arrow_shadow_x,
      srcY: AtlasGameObjects.arrow_shadow_y,
      srcWidth: AtlasGameObjects.arrow_width,
      srcHeight: AtlasGameObjects.arrow_height,
      dstX: x,
      dstY: y + 10,
      rotation: rotation - Engine.PI_Quarter,
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