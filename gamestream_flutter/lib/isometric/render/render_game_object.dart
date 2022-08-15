import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/animation_frame.dart';
import 'package:gamestream_flutter/isometric/classes/game_object.dart';
import 'package:gamestream_flutter/isometric/render/src_utils.dart';
import 'package:lemon_engine/render.dart';

void renderGameObject(GameObject value) {

  if (value.type == GameObjectType.Rock)
    return render(
       dstX: value.renderX,
       dstY: value.renderY,
       srcX: 1664,
       srcY: value.shade * 16,
       srcWidth: 16,
       srcHeight: 16,
    );

  if (value.type == GameObjectType.Barrel)
    return render(
      dstX: value.renderX,
      dstY: value.renderY,
      srcX: 1747,
      srcY: 0,
      srcWidth: 28,
      srcHeight: 40,
      anchorY: 0.66,
      color: value.renderColor,
    );

  if (value.type == GameObjectType.Candle)
    return render(
      dstX: value.renderX,
      dstY: value.renderY,
      srcX: 1812,
      srcY: 0,
      srcWidth: 3,
      srcHeight: 10,
      anchorY: 0.95,
      color: value.renderColor,
    );

  if (value.type == GameObjectType.Wheel)
    return render(
      dstX: value.renderX,
      dstY: value.renderY,
      srcX: 1775,
      srcY: 0,
      srcWidth: 34,
      srcHeight: 40,
      anchorY: 0.9,
      color: value.renderColor,
    );

  if (value.type == GameObjectType.Flower)
    return render(
      dstX: value.renderX,
      dstY: value.renderY,
      srcX: 1680,
      srcY: 0,
      srcWidth: 16,
      srcHeight: 16,
      color: value.renderColor,
    );

  if (value.type == GameObjectType.Stick)
    return render(
      dstX: value.renderX,
      dstY: value.renderY,
      srcX: 1696,
      srcY: 0,
      srcWidth: 16,
      srcHeight: 16,
      color: value.renderColor,
    );

  if (value.type == GameObjectType.Crystal)
    return render(
      dstX: value.renderX,
      dstY: value.renderY,
      srcX: 1712,
      srcY: 0,
      srcWidth: 22,
      srcHeight: 45,
      anchorY: 0.66
    );

  if (value.type == GameObjectType.Butterfly)
    return render(
      dstX: value.renderX,
      dstY: value.renderY,
      srcX: (animationFrame8 % 2) * 64 + (value.direction * 2 * 64),
      srcY: 718,
      srcWidth: 64,
      srcHeight: 64,
      scale: 0.25,
      color: value.renderColor,
    );

  if (value.type == GameObjectType.Chicken)
    return renderGameObjectChicken(value);
}

void renderGameObjectChicken(GameObject value) {

  const framesPerDirection = 7;
  var srcX = value.direction * (framesPerDirection * 64.0);

  if (value.state == CharacterState.Running){
    srcX = getSrc(
        animation: const [3, 4, 5, 6],
        direction: value.direction,
        frame: frameChicken,
        framesPerDirection: framesPerDirection,
    );
  }
  if (value.state == CharacterState.Performing){
    srcX = getSrc(
      animation: const [1, 2],
      direction: value.direction,
      frame: frameChicken,
      framesPerDirection: framesPerDirection,
    );
  }
  if (value.state == CharacterState.Sitting){
    srcX = getSrc(
      animation: const [7],
      direction: value.direction,
      frame: frameChicken,
      framesPerDirection: framesPerDirection,
    );
  }

  render(
    dstX: value.renderX,
    dstY: value.renderY,
    srcX: srcX,
    srcY: 928,
    srcWidth: 64,
    srcHeight: 64,
    scale: 0.66,
    color: value.renderColor,
  );
}
