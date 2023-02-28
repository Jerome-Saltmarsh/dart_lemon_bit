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
      renderBouncingGameObjectShadow(gameObject);
      Engine.renderSprite(
        image: GameImages.atlas_weapons,
        dstX: GameConvert.convertV3ToRenderX(gameObject),
        dstY: getRenderYBouncing(gameObject),
        srcX: GameAnimation.animationFrame8 * 125.0,
        // srcX: 0,
        srcY: 125,
        srcWidth: 125,
        srcHeight: 125,
        color: GameState.getV3RenderColor(gameObject),
        scale: 0.4
      );
      return;
    }

    if (type == ItemType.Weapon_Ranged_Plasma_Pistol) {
      renderBouncingGameObjectShadow(gameObject);
      Engine.renderSprite(
          image: GameImages.atlas_weapons,
          dstX: GameConvert.convertV3ToRenderX(gameObject),
          dstY: getRenderYBouncing(gameObject),
          srcX: GameAnimation.animationFrame8 * 125.0,
          // srcX: 0,
          srcY: 0,
          srcWidth: 125,
          srcHeight: 125,
          color: GameState.getV3RenderColor(gameObject),
          scale: 0.4
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
      srcWidth: AtlasItems.getSrcWidth(type),
      srcHeight: AtlasItems.getSrcHeight(type),
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

      if (gameObject.renderY > Engine.Screen_Bottom) {
        end();
        return;
      }
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
