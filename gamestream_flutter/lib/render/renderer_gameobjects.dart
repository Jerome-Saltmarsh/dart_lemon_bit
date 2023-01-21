import 'package:gamestream_flutter/library.dart';

import 'functions/render_shadow.dart';

class RendererGameObjects extends Renderer {
  static late GameObject gameObject;

  static final gameObjects = ServerState.gameObjects;

  @override
  int getTotal() => ServerState.totalGameObjects;

  @override
  void renderFunction() {
    final type = gameObject.type;
    if (ItemType.isTypeGameObject(type)) {
      Engine.renderSprite(
        image: gameObject.nodeVisibilityOpaque
            ? GameImages.atlas_gameobjects
            : GameImages.atlas_gameobjects_transparent,
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

  @override
  void updateFunction() {
    gameObject = gameObjects[index];


    while (!gameObject.nodePerceptible) {
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
