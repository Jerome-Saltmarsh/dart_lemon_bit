import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/emission_type.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_gameobject.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_position.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_renderer.dart';
import 'package:gamestream_flutter/library.dart';

import 'functions/render_shadow.dart';

class RendererGameObjects extends IsometricRenderer {
  static late IsometricGameObject gameObject;

  static final gameObjects = gamestream.isometric.server.gameObjects;

  RendererGameObjects(super.scene);

  @override
  int getTotal() {
    return gameObjects.length;
  }

  @override
  void renderFunction() {
    final type = gameObject.type;
    final subType = gameObject.subType;

    final src = Atlas.getSrc(type, subType);

    engine.renderSprite(
      image: Images.atlas_gameobjects,
      dstX: gameObject.renderX,
      dstY: gameObject.renderY,
      srcX: src[Atlas.SrcX],
      srcY: src[Atlas.SrcY],
      anchorY: src[Atlas.SrcAnchorY],
      srcWidth: src[Atlas.SrcWidth],
      srcHeight: src[Atlas.SrcHeight],
      scale: src[Atlas.SrcScale],
      color: gameObject.emissionType != IsometricEmissionType.Color
          ? scene.getRenderColorPosition(gameObject)
          : gameObject.emissionColor,
    );
    //
    // switch (type) {
    //
    //   case GameObjectType.Object:
    //     engine.renderSprite(
    //       image: GameImages.atlas_gameobjects,
    //       dstX: gameObject.renderX,
    //       dstY: gameObject.renderY,
    //       srcX: AtlasItems.getSrcX(type, subType),
    //       srcY: AtlasItems.getSrcY(type, subType),
    //       anchorY: AtlasItems.getAnchorY(type, subType),
    //       srcWidth: AtlasItems.getSrcWidth(type, subType),
    //       srcHeight: AtlasItems.getSrcHeight(type, subType),
    //       scale: AtlasItems.getSrcScale(type, subType),
    //       color: gameObject.emission_type != IsometricEmissionType.Color
    //           ? nodes.getV3RenderColor(gameObject)
    //           : gameObject.emission_col,
    //     );
    //
    //   default:
    //     renderBouncingGameObjectShadow(gameObject);
    //     engine.renderSprite(
    //       image: GameImages.atlas_items,
    //       dstX: gameObject.renderX,
    //       dstY: getRenderYBouncing(gameObject),
    //       srcX: AtlasItems.getSrcX(type, subType),
    //       srcY: AtlasItems.getSrcY(type, subType),
    //       srcWidth: AtlasItems.getSrcWidth(type, subType),
    //       srcHeight: AtlasItems.getSrcHeight(type, subType),
    //       scale: AtlasItems.getSrcScale(type, subType),
    //       color: nodes.getV3RenderColor(gameObject),
    //     );
    //     break;
    // }
  }

  @override
  void updateFunction() {
    gameObject = gameObjects[index];

    while (!gameObject.active || !gameObject.onscreen || !scene.isPerceptiblePosition(gameObject)) {
      index++;
      if (!remaining) return;
      gameObject = gameObjects[index];
    }

    orderZ = gameObject.indexZ;
    orderRowColumn = gameObject.indexSum;
  }

  static double getRenderYBouncing(IsometricPosition v3) =>
      ((v3.y + v3.x) * 0.5) - v3.z + gamestream.animation.animationFrameWaterHeight;

  static void renderBouncingGameObjectShadow(IsometricPosition gameObject){
    const shadowScale = 1.5;
    const shadowScaleHeight = 0.15;
    renderShadow(
        gameObject.x,
        gameObject.y,
        gameObject.z - 15,
        scale: shadowScale + (shadowScaleHeight * gamestream.animation.animationFrameWaterHeight.toDouble())
    );
  }
}
