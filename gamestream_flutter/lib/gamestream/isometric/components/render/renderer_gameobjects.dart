import 'dart:ui';

import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/render_group.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/emission_type.dart';
import 'package:gamestream_flutter/isometric/classes/gameobject.dart';
import 'package:gamestream_flutter/isometric/classes/position.dart';
import 'package:gamestream_flutter/packages/common.dart';

class RendererGameObjects extends RenderGroup {


  late GameObject gameObject;

  @override
  int getTotal() => scene.gameObjects.length;

  @override
  void renderFunction() {
    final gameObject = this.gameObject;
    final type = gameObject.type;
    final image = getImageForGameObjectType(type);
    final src = Atlas.getSrc(type, gameObject.subType);

    final isCollectable = const [
      ItemType.Weapon,
      ItemType.Helm,
      ItemType.Body,
      ItemType.Legs,
      ItemType.Consumable,
      ItemType.Spell,
    ].contains(type);

    if (isCollectable){
      renderBouncingGameObjectShadow(gameObject);
    }

    if (gameObject.type == ItemType.Object && gameObject.subType == ObjectType.Crystal){
      final crystalSouth =  images.crystalSouth;
      final crystalWest =  images.crystalWest;
      final gameObjectIndex = scene.getIndexPosition(gameObject);
      final colorSouth = scene.colorSouth(gameObjectIndex);
      final colorWest = scene.colorWest(gameObjectIndex);
      const scale = 0.25;
      final frame = animation.frameRate5;

      render.sprite(
          sprite: crystalSouth,
          frame: crystalSouth.getFrame(row: 0, column: frame),
          color: colorSouth,
          scale: scale,
          dstX: gameObject.renderX,
          dstY: gameObject.renderY,
      );

      render.sprite(
        sprite: crystalWest,
          frame: crystalWest.getFrame(row: 0, column: frame),
          color: colorWest,
          scale: scale,
          dstX: gameObject.renderX,
          dstY: gameObject.renderY,
      );

      return;
    }

    engine.renderSprite(
      image: image,
      dstX: gameObject.renderX,
      dstY: isCollectable ? getRenderYBouncing(gameObject) : gameObject.renderY,
      srcX: src[Atlas.SrcX],
      srcY: src[Atlas.SrcY],
      anchorY: src[Atlas.SrcAnchorY],
      srcWidth: src[Atlas.SrcWidth],
      srcHeight: src[Atlas.SrcHeight],
      scale: src[Atlas.SrcScale],
      color: switch (gameObject.emissionType){
         EmissionType.None => scene.getRenderColorPosition(gameObject),
         EmissionType.Ambient => scene.getRenderColorPosition(gameObject),
         EmissionType.Color => gameObject.emissionColor,
         EmissionType.Zero => 0,
         _ => throw Exception()
      }
    );

    // if (gameObject.maxHealth > 0) {
    //   render.healthBarPosition(
    //       position: gameObject,
    //       percentage: gameObject.healthPercentage,
    //     );
    //   render.textPosition(gameObject, formatPercentage(gameObject.healthPercentage));
    // }
  }

  @override
  void updateFunction() {
    gameObject = scene.gameObjects[index];

    while (!gameObject.active || !screen.contains(gameObject) || !scene.isPerceptiblePosition(gameObject)) {
      index++;
      if (!remaining) return;
      gameObject = scene.gameObjects[index];
    }

    order = gameObject.sortOrder;
  }

  double getRenderYBouncing(Position v3) =>
      ((v3.y + v3.x) * 0.5) - v3.z + animation.frameWaterHeight;

  void renderBouncingGameObjectShadow(Position gameObject){
    const shadowScale = 1.5;
    const shadowScaleHeight = 0.15;

    render.renderShadow(
        gameObject.x,
        gameObject.y,
        gameObject.z - 15,
        scale: shadowScale + (shadowScaleHeight * animation.frameWaterHeight.toDouble())
    );
  }

  Image getImageForGameObjectType(int type) =>
      images.itemTypeAtlases[type] ?? (
          throw Exception(
              'getImageForGameObjectType(type: ${ItemType.getName(type)}})'
          )
      );
}
