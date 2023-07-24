import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/emission_type.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_gameobject.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_position.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_renderer.dart';
import 'package:gamestream_flutter/library.dart';

import '../functions/format_percentage.dart';

class RendererGameObjects extends IsometricRenderer {
  static late IsometricGameObject gameObject;

  RendererGameObjects(super.isometric);

  @override
  int getTotal() => isometric.gameObjects.length;

  @override
  void renderFunction() {
    final type = gameObject.type;
    final image = isometric.getImageForGameObjectType(type);
    final src = Atlas.getSrc(type, gameObject.subType);

    final isCollectable = const [
      GameObjectType.Weapon,
      GameObjectType.Head,
      GameObjectType.Body,
      GameObjectType.Legs,
      GameObjectType.Item,
    ].contains(type);

    if (isCollectable){
      renderBouncingGameObjectShadow(gameObject);
    }

    isometric.engine.renderSprite(
      image: image,
      dstX: gameObject.renderX,
      dstY: isCollectable ? getRenderYBouncing(gameObject) : gameObject.renderY,
      srcX: src[Atlas.SrcX],
      srcY: src[Atlas.SrcY],
      anchorY: src[Atlas.SrcAnchorY],
      srcWidth: src[Atlas.SrcWidth],
      srcHeight: src[Atlas.SrcHeight],
      scale: src[Atlas.SrcScale],
      color: switch (gameObject.colorType){
         EmissionType.Ambient => isometric.getRenderColorPosition(gameObject),
         EmissionType.None => isometric.getRenderColorPosition(gameObject),
         EmissionType.Color => gameObject.emissionColor,
         _ => throw Exception()
      }
    );


    if (gameObject.maxHealth > 0) {
      isometric.render.renderHealthBarPosition(
          position: gameObject,
          percentage: gameObject.healthPercentage,
        );
      isometric.render.renderTextPosition(gameObject, formatPercentage(gameObject.healthPercentage));
    }

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
    gameObject = isometric.gameObjects[index];

    while (!gameObject.active || !isometric.isOnscreen(gameObject) || !isometric.isPerceptiblePosition(gameObject)) {
      index++;
      if (!remaining) return;
      gameObject = isometric.gameObjects[index];
    }

    order = gameObject.sortOrder;
  }

  double getRenderYBouncing(IsometricPosition v3) =>
      ((v3.y + v3.x) * 0.5) - v3.z + isometric.animationFrameWaterHeight;

  void renderBouncingGameObjectShadow(IsometricPosition gameObject){
    const shadowScale = 1.5;
    const shadowScaleHeight = 0.15;
    isometric.renderShadow(
        gameObject.x,
        gameObject.y,
        gameObject.z - 15,
        scale: shadowScale + (shadowScaleHeight * isometric.animationFrameWaterHeight.toDouble())
    );
  }
}
