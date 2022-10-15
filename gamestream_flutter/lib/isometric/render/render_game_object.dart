import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/atlases.dart';
import 'package:gamestream_flutter/isometric/animation_frame.dart';
import 'package:gamestream_flutter/isometric/classes/game_object.dart';
import 'package:gamestream_flutter/isometric/constants/color_pitch_black.dart';
import 'package:gamestream_flutter/isometric/nodes/render/atlas_src_gameobjects.dart';
import 'package:gamestream_flutter/isometric/render/get_character_render_color.dart';
import 'package:gamestream_flutter/isometric/render/render_util.dart';
import 'package:gamestream_flutter/isometric/render/src_utils.dart';
import 'package:lemon_engine/engine.dart';

import 'render_shadow.dart';

void renderGameObject(GameObject gameObject) {
  switch(gameObject.type){
    case GameObjectType.Rock:
      Engine.renderBuffer(
        dstX: gameObject.renderX,
        dstY: gameObject.renderY,
        srcX: AtlasSrcGameObjects.Rock_X,
        srcY: AtlasSrcGameObjects.Rock_Y,
        srcWidth: AtlasSrcGameObjects.Rock_Width,
        srcHeight: AtlasSrcGameObjects.Rock_Height,
        color: getRenderColor(gameObject),
      );
      return;
    case GameObjectType.Loot:
      Engine.renderSprite(
        image: Images.gameobjects,
        dstX: RenderUtil.getRenderX(gameObject),
        dstY: RenderUtil.getRenderY(gameObject),
        srcX: AtlasSrcGameObjects.Loot_X,
        srcY: AtlasSrcGameObjects.Loot_Y,
        srcWidth: AtlasSrcGameObjects.Loot_Width,
        srcHeight: AtlasSrcGameObjects.Loot_Height,
        color: getRenderColor(gameObject),
      );
      return;
    case GameObjectType.Barrel:
      Engine.renderSprite(
        image: Images.gameobjects,
        dstX: RenderUtil.getRenderX(gameObject),
        dstY: RenderUtil.getRenderY(gameObject),
        srcX: AtlasSrcGameObjects.Barrel_X,
        srcY: AtlasSrcGameObjects.Barrel_Y,
        srcWidth: AtlasSrcGameObjects.Barrel_Width,
        srcHeight: AtlasSrcGameObjects.Barrel_Height,
        anchorY: AtlasSrcGameObjects.Barrel_Anchor,
        color: getRenderColor(gameObject),
      );
      return;
    case GameObjectType.Tavern_Sign:
      Engine.renderSprite(
        image: Images.gameobjects,
        dstX: RenderUtil.getRenderX(gameObject),
        dstY: RenderUtil.getRenderY(gameObject),
        srcX: AtlasSrcGameObjects.Tavern_Sign_X,
        srcY: AtlasSrcGameObjects.Tavern_Sign_Y,
        srcWidth: AtlasSrcGameObjects.Tavern_Sign_Width,
        srcHeight: AtlasSrcGameObjects.Tavern_Sign_Height,
        color: getRenderColor(gameObject),
      );
      return;
    case GameObjectType.Candle:
      Engine.renderBuffer(
        dstX: RenderUtil.getRenderX(gameObject),
        dstY: RenderUtil.getRenderY(gameObject),
        srcX: 1812,
        srcY: 0,
        srcWidth: 3,
        srcHeight: 10,
        anchorY: 0.95,
      );
      return;
    case GameObjectType.Bottle:
      Engine.renderBuffer(
        dstX: RenderUtil.getRenderX(gameObject),
        dstY: RenderUtil.getRenderY(gameObject),
        srcX: 1811,
        srcY: 11,
        srcWidth: 5,
        srcHeight: 14,
        anchorY: 0.95,
        color: getRenderColor(gameObject),
      );
      return;
    case GameObjectType.Wheel:
      Engine.renderBuffer(
        dstX: RenderUtil.getRenderX(gameObject),
        dstY: RenderUtil.getRenderY(gameObject),
        srcX: 1775,
        srcY: 0,
        srcWidth: 34,
        srcHeight: 40,
        anchorY: 0.9,
        color: getRenderColor(gameObject),
      );
      return;
    case GameObjectType.Flower:
      Engine.renderBuffer(
        dstX: RenderUtil.getRenderX(gameObject),
        dstY: RenderUtil.getRenderY(gameObject),
        srcX: 1680,
        srcY: 0,
        srcWidth: 16,
        srcHeight: 16,
        color: getRenderColor(gameObject),
      );
      return;
    case GameObjectType.Stick:
      Engine.renderBuffer(
        dstX: RenderUtil.getRenderX(gameObject),
        dstY: RenderUtil.getRenderY(gameObject),
        srcX: 1696,
        srcY: 0,
        srcWidth: 16,
        srcHeight: 16,
        color: getRenderColor(gameObject),
      );
      return;
    case GameObjectType.Crystal:
      Engine.renderSprite(
          image: Images.gameobjects,
          dstX: RenderUtil.getRenderX(gameObject),
          dstY: RenderUtil.getRenderY(gameObject),
          srcX: AtlasSrcGameObjects.Crystal_Large_X,
          srcY: AtlasSrcGameObjects.Crystal_Large_Y,
          srcWidth: AtlasSrcGameObjects.Crystal_Large_Width,
          srcHeight: AtlasSrcGameObjects.Crystal_Large_Height,
          anchorY: AtlasSrcGameObjects.Crystal_Anchor_Y
      );
      return;
    case GameObjectType.Cup:
      Engine.renderBuffer(
        dstX: RenderUtil.getRenderX(gameObject),
        dstY: RenderUtil.getRenderY(gameObject),
        srcX: AtlasSrcGameObjects.Cup_X,
        srcY: AtlasSrcGameObjects.Cup_Y,
        srcWidth: AtlasSrcGameObjects.Cup_Width,
        srcHeight: AtlasSrcGameObjects.Cup_Height,
        anchorY: AtlasSrcGameObjects.Cup_Anchor_Y,
      );
      return;
    case GameObjectType.Lantern_Red:
      Engine.renderBuffer(
        dstX:RenderUtil.getRenderX(gameObject),
        dstY:RenderUtil.getRenderY(gameObject),
        srcX: 1744,
        srcY: 48,
        srcWidth: 12,
        srcHeight: 22,
        scale: 1.0,
        color: colorShades[Shade.Very_Bright],
      );
      return;
    case GameObjectType.Wooden_Shelf_Row:
      Engine.renderBuffer(
          dstX:RenderUtil.getRenderX(gameObject),
          dstY:RenderUtil.getRenderY(gameObject),
          srcX: 1664,
          srcY: 16,
          srcWidth: 32,
          srcHeight: 38
      );
      return;
    case GameObjectType.Book_Purple:
      Engine.renderBuffer(
        dstX:RenderUtil.getRenderX(gameObject),
        dstY:RenderUtil.getRenderY(gameObject),
        srcX: 1697,
        srcY: 16,
        srcWidth: 8,
        srcHeight: 15,
      );
      return;
    case GameObjectType.Crystal_Small_Blue:
      Engine.renderBuffer(
        dstX:RenderUtil.getRenderX(gameObject),
        dstY:RenderUtil.getRenderY(gameObject),
        srcX: 1697,
        srcY: 33,
        srcWidth: 10,
        srcHeight: 19,
      );
      return;
    case GameObjectType.Flower_Green:
        Engine.renderBuffer(
          dstX:RenderUtil.getRenderX(gameObject),
          dstY:RenderUtil.getRenderY(gameObject),
          srcX: 1696,
          srcY: 53,
          srcWidth: 9,
          srcHeight: 7,
        );
        return;
  }


  const shadowScale = 1.5;
  const shadowScaleHeight = 0.15;
  if (gameObject.type == GameObjectType.Weapon_Shotgun) {
    renderShadow(gameObject.x, gameObject.y, gameObject.z - 15, scale: shadowScale + (shadowScaleHeight * animationFrameWaterHeight.toDouble()));
    return Engine.renderBuffer(
      dstX:RenderUtil.getRenderX(gameObject),
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
    return Engine.renderBuffer(
      dstX:RenderUtil.getRenderX(gameObject),
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
    Engine.renderBuffer(
      dstX:RenderUtil.getRenderX(gameObject),
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
    Engine.renderBuffer(
      dstX:RenderUtil.getRenderX(gameObject),
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
    Engine.renderBuffer(
      dstX: RenderUtil.getRenderX(gameObject),
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

  Engine.renderBuffer(
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
  Engine.renderBuffer(
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
  // Engine.renderSprite(
  //   dstX: value.renderX,
  //   dstY: value.renderY,
  //   srcX: 2801,
  //   srcY: animationFrameJellyFish * 48.0,
  //   srcWidth: 32,
  //   srcHeight: 48,
  //   scale: 1,
  //   color: getNodeBelowShade(value),
  // );
}
