import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/animation_frame.dart';
import 'package:gamestream_flutter/isometric/classes/game_object.dart';
import 'package:gamestream_flutter/isometric/constants/color_pitch_black.dart';
import 'package:gamestream_flutter/isometric/render/get_character_render_color.dart';
import 'package:gamestream_flutter/isometric/render/src_utils.dart';
import 'package:lemon_engine/render.dart';

import 'render_shadow.dart';

void renderGameObject(GameObject gameObject) {

  if (gameObject.type == GameObjectType.Loot)
    return render(
      dstX: gameObject.renderX,
      dstY: gameObject.renderY,
      srcX: 4443,
      srcY: 11,
      srcWidth: 10,
      srcHeight: 15,
      color: getRenderColor(gameObject),
    );

  if (gameObject.type == GameObjectType.Rock)
    return render(
       dstX: gameObject.renderX,
       dstY: gameObject.renderY,
       srcX: 1664,
       srcY: 0,
       srcWidth: 16,
       srcHeight: 16,
      color: getRenderColor(gameObject),
    );

  if (gameObject.type == GameObjectType.Barrel)
    return render(
      dstX: gameObject.renderX,
      dstY: gameObject.renderY,
      srcX: 1747,
      srcY: 0,
      srcWidth: 28,
      srcHeight: 40,
      anchorY: 0.66,
      color: getRenderColor(gameObject),
    );

  if (gameObject.type == GameObjectType.Tavern_Sign)
    return render(
      dstX: gameObject.renderX,
      dstY: gameObject.renderY,
      srcX: 1645,
      srcY: 0,
      srcWidth: 19,
      srcHeight: 39,
      color: getRenderColor(gameObject),
    );

  if (gameObject.type == GameObjectType.Candle)
    return render(
      dstX: gameObject.renderX,
      dstY: gameObject.renderY,
      srcX: 1812,
      srcY: 0,
      srcWidth: 3,
      srcHeight: 10,
      anchorY: 0.95,
    );

  if (gameObject.type == GameObjectType.Bottle)
    return render(
      dstX: gameObject.renderX,
      dstY: gameObject.renderY,
      srcX: 1811,
      srcY: 11,
      srcWidth: 5,
      srcHeight: 14,
      anchorY: 0.95,
      color: getRenderColor(gameObject),
    );

  if (gameObject.type == GameObjectType.Wheel)
    return render(
      dstX: gameObject.renderX,
      dstY: gameObject.renderY,
      srcX: 1775,
      srcY: 0,
      srcWidth: 34,
      srcHeight: 40,
      anchorY: 0.9,
      color: getRenderColor(gameObject),
    );

  if (gameObject.type == GameObjectType.Flower)
    return render(
      dstX: gameObject.renderX,
      dstY: gameObject.renderY,
      srcX: 1680,
      srcY: 0,
      srcWidth: 16,
      srcHeight: 16,
      color: getRenderColor(gameObject),
    );

  if (gameObject.type == GameObjectType.Stick)
    return render(
      dstX: gameObject.renderX,
      dstY: gameObject.renderY,
      srcX: 1696,
      srcY: 0,
      srcWidth: 16,
      srcHeight: 16,
      color: getRenderColor(gameObject),
    );

  if (gameObject.type == GameObjectType.Crystal)
    return render(
      dstX: gameObject.renderX,
      dstY: gameObject.renderY,
      srcX: 2778,
      srcY: animationFrameJellyFish * 61.0,
      srcWidth: 22,
      srcHeight: 60,
      anchorY: 0.8
    );

  if (gameObject.type == GameObjectType.Cup)
    return render(
        dstX: gameObject.renderX,
        dstY: gameObject.renderY,
        srcX: 1816,
        srcY: 0,
        srcWidth: 6,
        srcHeight: 11,
        anchorY: 0.75
    );

  if (gameObject.type == GameObjectType.Butterfly)
    return render(
      dstX: gameObject.renderX,
      dstY: gameObject.renderY,
      srcX: 1984,
      srcY: (animationFrame8 % 2) * 23 + (gameObject.direction * 2 * 23),
      srcWidth: 30,
      srcHeight: 23,
      scale: 0.5,
      color: getRenderColor(gameObject),
    );

  if (gameObject.type == GameObjectType.Chicken)
    return renderGameObjectChicken(gameObject);

  if (gameObject.type == GameObjectType.Lantern_Red)
    return render(
      dstX: gameObject.renderX,
      dstY: gameObject.renderY,
      srcX: 1744,
      srcY: 48,
      srcWidth: 12,
      srcHeight: 22,
      scale: 1.0,
      color: colorShades[Shade.Very_Bright],
    );

  if (gameObject.type == GameObjectType.Jellyfish)
    return renderGameObjectJellyfish(gameObject);

  if (gameObject.type == GameObjectType.Jellyfish_Red)
    return renderGameObjectJellyfishRed(gameObject);

  if (gameObject.type == GameObjectType.Wooden_Shelf_Row)
    return render(
        dstX: gameObject.renderX,
        dstY: gameObject.renderY,
        srcX: 1664,
        srcY: 16,
        srcWidth: 32,
        srcHeight: 38,
    );

  if (gameObject.type == GameObjectType.Book_Purple)
    return render(
      dstX: gameObject.renderX,
      dstY: gameObject.renderY,
      srcX: 1697,
      srcY: 16,
      srcWidth: 8,
      srcHeight: 15,
    );


  if (gameObject.type == GameObjectType.Crystal_Small_Blue)
    return render(
      dstX: gameObject.renderX,
      dstY: gameObject.renderY,
      srcX: 1697,
      srcY: 33,
      srcWidth: 10,
      srcHeight: 19,
    );

  if (gameObject.type == GameObjectType.Flower_Green)
    return render(
      dstX: gameObject.renderX,
      dstY: gameObject.renderY,
      srcX: 1696,
      srcY: 53,
      srcWidth: 9,
      srcHeight: 7,
    );

  const shadowScale = 1.5;
  const shadowScaleHeight = 0.15;
  if (gameObject.type == GameObjectType.Weapon_Shotgun) {
    renderShadow(gameObject.x, gameObject.y, gameObject.z - 15, scale: shadowScale + (shadowScaleHeight * animationFrameWaterHeight.toDouble()));
    return render(
      dstX: gameObject.renderX,
      dstY: ((gameObject.y + gameObject.x) * 0.5) - gameObject.z + animationFrameWaterHeight,
      srcX: 262,
      srcY: 204,
      srcWidth: 26,
      srcHeight: 7,
      color: getRenderColor(gameObject)
    );
  }

  if (gameObject.type == GameObjectType.Weapon_Handgun) {
    renderShadow(gameObject.x, gameObject.y, gameObject.z - 15, scale: shadowScale + (shadowScaleHeight * animationFrameWaterHeight.toDouble()));
    return render(
      dstX: gameObject.renderX,
      dstY: ((gameObject.y + gameObject.x) * 0.5) - gameObject.z + animationFrameWaterHeight,
      srcX: 234,
      srcY: 200,
      srcWidth: 17,
      srcHeight: 10,
      color: getRenderColor(gameObject)
    );
  }

  if (gameObject.type == GameObjectType.Weapon_Blade) {
    renderShadow(gameObject.x, gameObject.y, gameObject.z - 15, scale: shadowScale + (shadowScaleHeight * animationFrameWaterHeight.toDouble()));
    render(
      dstX: gameObject.renderX,
      dstY: ((gameObject.y + gameObject.x) * 0.5) - gameObject.z + animationFrameWaterHeight,
      srcX: 1029,
      srcY: 1644,
      srcWidth: 33,
      srcHeight: 13,
      color: getRenderColor(gameObject)
    );
    return;
  }

  if (gameObject.type == GameObjectType.Weapon_Bow) {
    renderShadow(gameObject.x, gameObject.y, gameObject.z - 15, scale: shadowScale + (shadowScaleHeight * animationFrameWaterHeight.toDouble()));
    render(
      dstX: gameObject.renderX,
      dstY: ((gameObject.y + gameObject.x) * 0.5) - gameObject.z + animationFrameWaterHeight,
      srcX: 7181,
      srcY: 1838,
      srcWidth: 30,
      srcHeight: 28,
      color: getRenderColor(gameObject)
    );
    return;
  }

  if (gameObject.type == GameObjectType.Weapon_Staff) {
    renderShadow(gameObject.x, gameObject.y, gameObject.z - 15, scale: shadowScale + (shadowScaleHeight * animationFrameWaterHeight.toDouble()));
    render(
      dstX: gameObject.renderX,
      dstY: ((gameObject.y + gameObject.x) * 0.5) - gameObject.z + animationFrameWaterHeight,
      srcX: 7119,
      srcY: 1519,
      srcWidth: 24,
      srcHeight: 24,
      color: getRenderColor(gameObject)
    );
    return;
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
