import 'package:flutter_game_engine/game_engine/engine_state.dart';
import 'package:flutter_game_engine/game_engine/game_widget.dart';

import '../classes.dart';
import '../draw.dart';

void drawSpriteAnimation(SpriteAnimation animation){
  print('drawing sprite animation ${animation.currentFrame}  ${animation.rect}');

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
