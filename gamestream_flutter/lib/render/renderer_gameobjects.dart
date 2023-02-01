import 'dart:math';

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
    if (ItemType.isTypeGameObject(type)) {

      if (type == ItemType.GameObjects_Crate_Wooden){
        GameNodes.markShadow(gameObject);
        final shadowAngle = GameNodes.shadow.z + pi;
        final shadowDistance = min(GameNodes.shadow.magnitudeXY, 10.0);
        final shadowX = gameObject.x + getAdjacent(shadowAngle, shadowDistance);
        final shadowY = gameObject.y + getOpposite(shadowAngle, shadowDistance);
        final shadowZ = gameObject.z;

        Engine.renderSprite(
          image: GameImages.atlas_gameobjects,
          dstX: GameConvert.getRenderX(shadowX, shadowY, shadowZ),
          dstY: GameConvert.getRenderY(shadowX, shadowY, shadowZ),
          srcX: 49,
          srcY: 256,
          srcWidth: 48,
          srcHeight: 48,
          scale: AtlasItems.getSrcScale(type),
          color: GameState.getV3RenderColor(gameObject),
        );
      }

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
        color: GameState.getV3RenderColor(gameObject),
      );
      if (GameRender.renderDebug) {
        renderGameObjectRadius(gameObject);
      }

      return;
    }

    assert (ItemType.isTypeItem(type));

    renderBouncingGameObjectShadow(gameObject);
    Engine.renderSprite(
      image: GameImages.atlas_items,
      dstX: GameConvert.convertV3ToRenderX(gameObject),
      dstY: getRenderYBouncing(gameObject),
      srcX: AtlasItems.getSrcX(type),
      srcY: AtlasItems.getSrcY(type),
      srcWidth: AtlasItems.size,
      srcHeight: AtlasItems.size,
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

  // @override
  // void reset(){
  //   Engine.insertionSort(
  //     ServerState.gameObjects,
  //     compare: ClientState.compareRenderOrder,
  //   );
  //   super.reset();
  // }

  @override
  void updateFunction() {
    gameObject = gameObjects[index];

    while (!gameObject.active || !gameObject.onscreen || !gameObject.nodePerceptible) {
      index++;
      if (!remaining) return;
      gameObject = gameObjects[index];
    }

    order = gameObject.renderOrder;
    orderZ = gameObject.indexZ;
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
