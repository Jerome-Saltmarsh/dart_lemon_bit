import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/game_engine/global_paint.dart';

import '../classes/SpriteAnimation.dart';
import '../draw.dart';

void drawSpriteAnimation(SpriteAnimation animation){
  globalCanvas.drawAtlas(
      animation.sprite.image,
      [
        rsTransform(
            x: animation.x,
            y: animation.y,
            anchorX: animation.sprite.frameWidth * 0.5,
            anchorY: animation.sprite.frameHeight * 0.5,
            scale: animation.scale)
      ],
      [animation.rect],
      null,
      null,
      null,
      globalPaint);

  animation.nextFrame();
}
