

import 'package:gamestream_flutter/isometric/nodes/render/atlas_src_gameobjects.dart';
import 'package:gamestream_flutter/library.dart';

class RenderProjectiles {
  static void renderArrow(double x, double y, double rotation) {
    Engine.renderSpriteRotated(
      image: GameImages.gameobjects,
      srcX: AtlasSrcGameObjects.arrow_x,
      srcY: AtlasSrcGameObjects.arrow_y,
      srcWidth: AtlasSrcGameObjects.arrow_width,
      srcHeight: AtlasSrcGameObjects.arrow_height,
      dstX: x,
      dstY: y,
      rotation: rotation - Engine.PI_Quarter,
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