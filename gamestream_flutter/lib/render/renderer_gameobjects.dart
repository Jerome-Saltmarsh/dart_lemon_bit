import 'package:gamestream_flutter/library.dart';

import 'functions/render_shadow.dart';

class RendererGameObjects extends Renderer {
  static late GameObject gameObject;

  static final gameObjects = ServerState.gameObjects;

  @override
  int getTotal() {
    return gameObjects.length;
  }

  @override
  void renderFunction() {
    final type = gameObject.type;

    if (type == ItemType.Resource_Credit) {
      const srcY = 125.0 * 6;
      Engine.renderSprite(
          image: GameImages.atlas_weapons,
          dstX: gameObject.renderX,
          dstY: gameObject.renderY,
          srcX: GameAnimation.animationFrame16 * 125.0,
          srcY: srcY,
          srcWidth: 125,
          srcHeight: 125,
          color: GameState.getV3RenderColor(gameObject),
          scale: 0.3
      );
      return;
    }

    if (ItemType.isTypeGameObject(type)) {
      Engine.renderSprite(
        image: GameImages.atlas_gameobjects,
        dstX: gameObject.renderX,
        dstY: gameObject.renderY,
        srcX: AtlasItems.getSrcX(type),
        srcY: AtlasItems.getSrcY(type),
        anchorY: AtlasItems.getAnchorY(type),
        srcWidth: AtlasItems.getSrcWidth(type),
        srcHeight: AtlasItems.getSrcHeight(type),
        scale: AtlasItems.getSrcScale(type),
        color: gameObject.emission_type != EmissionType.Color
            ? GameState.getV3RenderColor(gameObject)
            : gameObject.emission_col,
      );
      if (GameRender.renderDebug) {
        renderGameObjectRadius(gameObject);
      }

      return;
    }

    if (type == ItemType.Weapon_Ranged_Plasma_Rifle) {
      Engine.renderSprite(
        image: GameImages.atlas_weapons,
        dstX: gameObject.renderX,
        dstY: gameObject.renderY,
        srcX: GameAnimation.animationFrame16 * 125.0,
        srcY: 125,
        srcWidth: 125,
        srcHeight: 125,
        color: GameState.getV3RenderColor(gameObject),
        scale: 0.3
      );
      return;
    }

    if (type == ItemType.Weapon_Ranged_Plasma_Pistol) {
      Engine.renderSprite(
          image: GameImages.atlas_weapons,
          dstX: gameObject.renderX,
          dstY: gameObject.renderY,
          srcX: GameAnimation.animationFrame16 * 125.0,
          srcY: 0,
          srcWidth: 125,
          srcHeight: 125,
          color: GameState.getV3RenderColor(gameObject),
          scale: 0.5
      );
      return;
    }

    if (type == ItemType.Weapon_Ranged_Shotgun) {
      Engine.renderSprite(
          image: GameImages.atlas_weapons,
          dstX: gameObject.renderX,
          dstY: gameObject.renderY,
          srcX: GameAnimation.animationFrame16 * 125.0,
          srcY: 250,
          srcWidth: 125,
          srcHeight: 125,
          color: GameState.getV3RenderColor(gameObject),
          scale: 0.5
      );
      return;
    }

    if (type == ItemType.Weapon_Ranged_Bazooka) {
      Engine.renderSprite(
          image: GameImages.atlas_weapons,
          dstX: gameObject.renderX,
          dstY: gameObject.renderY,
          srcX: GameAnimation.animationFrame16 * 125.0,
          srcY: 375,
          srcWidth: 125,
          srcHeight: 125,
          color: GameState.getV3RenderColor(gameObject),
          scale: 0.5
      );
      return;
    }

    if (type == ItemType.Weapon_Ranged_Flamethrower) {
      Engine.renderSprite(
          image: GameImages.atlas_weapons,
          dstX: gameObject.renderX,
          dstY: gameObject.renderY,
          srcX: GameAnimation.animationFrame16 * 125.0,
          srcY: 500,
          srcWidth: 125,
          srcHeight: 125,
          color: GameState.getV3RenderColor(gameObject),
          scale: 0.4
      );
      return;
    }

    if (type == ItemType.Weapon_Ranged_Sniper_Rifle) {
      Engine.renderSprite(
          image: GameImages.atlas_weapons,
          dstX: gameObject.renderX,
          dstY: gameObject.renderY,
          srcX: GameAnimation.animationFrame16 * 125.0,
          srcY: 625,
          srcWidth: 125,
          srcHeight: 125,
          color: GameState.getV3RenderColor(gameObject),
          scale: 0.4
      );
      return;
    }
    if (type == ItemType.Weapon_Ranged_Teleport) {
      Engine.renderSprite(
          image: GameImages.atlas_weapons,
          dstX: gameObject.renderX,
          dstY: gameObject.renderY,
          srcX: GameAnimation.animationFrame16 * 125.0,
          srcY: 875,
          srcWidth: 125,
          srcHeight: 125,
          color: GameState.getV3RenderColor(gameObject),
          scale: 0.5
      );
      return;
    }

    assert (ItemType.isTypeItem(type));

    renderBouncingGameObjectShadow(gameObject);
    Engine.renderSprite(
      image: GameImages.atlas_items,
      dstX: gameObject.renderX,
      dstY: getRenderYBouncing(gameObject),
      srcX: AtlasItems.getSrcX(type),
      srcY: AtlasItems.getSrcY(type),
      srcWidth: AtlasItems.getSrcWidth(type),
      srcHeight: AtlasItems.getSrcHeight(type),
      scale: AtlasItems.getSrcScale(gameObject.type),
      color: GameState.getV3RenderColor(gameObject),
    );
  }

  void renderGameObjectRadius(GameObject gameObject) {
    GameRender.renderCircle(
        gameObject.x,
        gameObject.y,
        gameObject.z, ItemType.getRadius(gameObject.type),
    );
  }

  @override
  void updateFunction() {
    gameObject = gameObjects[index];

    while (!gameObject.active || !gameObject.onscreenPadded || !gameObject.nodePerceptible) {
      index++;
      if (!remaining) return;
      gameObject = gameObjects[index];
    }

    order = gameObject.sortOrder;
    orderZ = gameObject.indexZ;
    indexSum = gameObject.indexSum;
  }

  static double getRenderYBouncing(Vector3 v3) =>
      ((v3.y + v3.x) * 0.5) - v3.z + GameAnimation.animationFrameWaterHeight;

  static void renderBouncingGameObjectShadow(Vector3 gameObject){
    const shadowScale = 1.5;
    const shadowScaleHeight = 0.15;
    renderShadow(
        gameObject.x,
        gameObject.y,
        gameObject.z - 15,
        scale: shadowScale + (shadowScaleHeight * GameAnimation.animationFrameWaterHeight.toDouble())
    );
  }
}
