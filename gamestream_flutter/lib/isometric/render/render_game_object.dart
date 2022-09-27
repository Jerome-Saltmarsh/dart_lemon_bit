import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/animation_frame.dart';
import 'package:gamestream_flutter/isometric/classes/game_object.dart';
import 'package:gamestream_flutter/isometric/constants/color_pitch_black.dart';
import 'package:gamestream_flutter/isometric/render/get_character_render_color.dart';
import 'package:gamestream_flutter/isometric/render/src_utils.dart';
import 'package:lemon_engine/render.dart';

void renderGameObject(GameObject value) {

  if (value.type == GameObjectType.Loot)
    return render(
      dstX: value.renderX,
      dstY: value.renderY,
      srcX: 4443,
      srcY: 11,
      srcWidth: 10,
      srcHeight: 15,
      color: getNodeBelowColor(value),
    );

  if (value.type == GameObjectType.Rock)
    return render(
       dstX: value.renderX,
       dstY: value.renderY,
       srcX: 1664,
       srcY: 0,
       srcWidth: 16,
       srcHeight: 16,
      color: getNodeBelowColor(value),
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
      color: getNodeBelowColor(value),
    );

  if (value.type == GameObjectType.Tavern_Sign)
    return render(
      dstX: value.renderX,
      dstY: value.renderY,
      srcX: 1645,
      srcY: 0,
      srcWidth: 19,
      srcHeight: 39,
      color: getNodeBelowColor(value),
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
    );

  if (value.type == GameObjectType.Bottle)
    return render(
      dstX: value.renderX,
      dstY: value.renderY,
      srcX: 1811,
      srcY: 11,
      srcWidth: 5,
      srcHeight: 14,
      anchorY: 0.95,
      color: getNodeBelowColor(value),
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
      color: getNodeBelowColor(value),
    );

  if (value.type == GameObjectType.Flower)
    return render(
      dstX: value.renderX,
      dstY: value.renderY,
      srcX: 1680,
      srcY: 0,
      srcWidth: 16,
      srcHeight: 16,
      color: getNodeBelowColor(value),
    );

  if (value.type == GameObjectType.Stick)
    return render(
      dstX: value.renderX,
      dstY: value.renderY,
      srcX: 1696,
      srcY: 0,
      srcWidth: 16,
      srcHeight: 16,
      color: getNodeBelowColor(value),
    );

  if (value.type == GameObjectType.Crystal)
    return render(
      dstX: value.renderX,
      dstY: value.renderY,
      srcX: 2778,
      srcY: animationFrameJellyFish * 61.0,
      srcWidth: 22,
      srcHeight: 60,
      anchorY: 0.8
    );

  if (value.type == GameObjectType.Cup)
    return render(
        dstX: value.renderX,
        dstY: value.renderY,
        srcX: 1816,
        srcY: 0,
        srcWidth: 6,
        srcHeight: 11,
        anchorY: 0.75
    );

  if (value.type == GameObjectType.Butterfly)
    return render(
      dstX: value.renderX,
      dstY: value.renderY,
      srcX: 1984,
      srcY: (animationFrame8 % 2) * 23 + (value.direction * 2 * 23),
      srcWidth: 30,
      srcHeight: 23,
      scale: 0.5,
      color: getNodeBelowColor(value),
    );

  if (value.type == GameObjectType.Chicken)
    return renderGameObjectChicken(value);

  if (value.type == GameObjectType.Lantern_Red)
    return render(
      dstX: value.renderX,
      dstY: value.renderY,
      srcX: 1744,
      srcY: 48,
      srcWidth: 12,
      srcHeight: 22,
      scale: 1.0,
      color: colorShades[Shade.Very_Bright],
    );

  if (value.type == GameObjectType.Jellyfish)
    return renderGameObjectJellyfish(value);

  if (value.type == GameObjectType.Jellyfish_Red)
    return renderGameObjectJellyfishRed(value);

  if (value.type == GameObjectType.Wooden_Shelf_Row)
    return render(
        dstX: value.renderX,
        dstY: value.renderY,
        srcX: 1664,
        srcY: 16,
        srcWidth: 32,
        srcHeight: 38,
    );

  if (value.type == GameObjectType.Book_Purple)
    return render(
      dstX: value.renderX,
      dstY: value.renderY,
      srcX: 1697,
      srcY: 16,
      srcWidth: 8,
      srcHeight: 15,
    );


  if (value.type == GameObjectType.Crystal_Small_Blue)
    return render(
      dstX: value.renderX,
      dstY: value.renderY,
      srcX: 1697,
      srcY: 33,
      srcWidth: 10,
      srcHeight: 19,
    );

  if (value.type == GameObjectType.Flower_Green)
    return render(
      dstX: value.renderX,
      dstY: value.renderY,
      srcX: 1696,
      srcY: 53,
      srcWidth: 9,
      srcHeight: 7,
    );

  if (value.type == GameObjectType.Weapon) {
    switch(value.subType){
      case AttackType.Shotgun:
        return render(
          dstX: value.renderX,
          dstY: value.renderY,
          srcX: 262,
          srcY: 204,
          srcWidth: 26,
          srcHeight: 7,
        );
      case AttackType.Handgun:
        return render(
          dstX: value.renderX,
          dstY: value.renderY,
          srcX: 234,
          srcY: 200,
          srcWidth: 17,
          srcHeight: 10,
        );
      case AttackType.Handgun:
        return render(
          dstX: value.renderX,
          dstY: value.renderY,
          srcX: 234,
          srcY: 200,
          srcWidth: 17,
          srcHeight: 10,
        );
    }

  }

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
    color: getNodeBelowShade(value),
  );
}

void renderGameObjectJellyfish(GameObject value) {
  render(
    dstX: value.renderX,
    dstY: value.renderY,
    srcX: 2745,
    srcY: animationFrameJellyFish * 48.0,
    srcWidth: 32,
    srcHeight: 48,
    scale: 1,
    color: getNodeBelowShade(value),
  );
}

void renderGameObjectJellyfishRed(GameObject value) {
  render(
    dstX: value.renderX,
    dstY: value.renderY,
    srcX: 2801,
    srcY: animationFrameJellyFish * 48.0,
    srcWidth: 32,
    srcHeight: 48,
    scale: 1,
    color: getNodeBelowShade(value),
  );
}
