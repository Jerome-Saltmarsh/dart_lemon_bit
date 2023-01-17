import 'package:gamestream_flutter/library.dart';

import 'functions/render_shadow.dart';

class RendererGameObjects extends Renderer {
  static late GameObject gameObject;

  @override
  int getTotal() => ServerState.totalGameObjects;

  @override
  void renderFunction() {
    final type = gameObject.type;
      if (ItemType.isTypeGameObject(type)) {
        Engine.renderSprite(
          image: GameImages.atlas_gameobjects,
          dstX: GameConvert.convertV3ToRenderX(gameObject),
          dstY: GameConvert.convertV3ToRenderY(gameObject),
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

      if (ItemType.isTypeCollectable(type)) {
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
        return;
      }

      throw Exception('could not render gameobject type ${gameObject.type}');
    }

  @override
  void updateFunction() {
    gameObject = ServerState.gameObjects[index];
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
