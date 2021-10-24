import 'package:bleed_client/engine/state/canvas.dart';
import 'package:bleed_client/engine/state/paint.dart';

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
      paint);

  animation.nextFrame();
}
