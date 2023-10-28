import 'dart:ui';

import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/render_group.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/emission_type.dart';
import 'package:gamestream_flutter/isometric/classes/gameobject.dart';
import 'package:gamestream_flutter/isometric/classes/position.dart';
import 'package:gamestream_flutter/packages/common.dart';

class SurfaceIndex {
  static const east = 0;
  static const north = 1;
  static const solid = 2;
  static const south = 3;
  static const top = 4;
  static const west = 5;
}

class RendererGameObjects extends RenderGroup {


  late GameObject gameObject;

  @override
  int getTotal() => scene.gameObjects.length;

  @override
  void renderFunction() {
    final gameObject = this.gameObject;
    final type = gameObject.type;
    final subType = gameObject.subType;
    final render = this.render;
    final engine = this.engine;
    final images = this.images;
    final scene = this.scene;

    if (type == ItemType.Object && subType == ObjectType.Sphere){

      final gameObjectIndex = scene.getIndexPosition(gameObject);
      final dstX = gameObject.renderX;
      final dstY = gameObject.renderY;

      engine.renderSprite(
          image: images.sphereTop,
          srcX: 0,
          srcY: 0,
          srcWidth: 256,
          srcHeight: 256,
          dstX: dstX,
          dstY: dstY,
          color: scene.colorAbove(gameObjectIndex)
      );

      engine.renderSprite(
          image: images.sphereNorth,
          srcX: 0,
          srcY: 0,
          srcWidth: 256,
          srcHeight: 256,
          dstX: dstX,
          dstY: dstY,
          color: scene.colorNorth(gameObjectIndex)
      );

      engine.renderSprite(
          image: images.sphereEast,
          srcX: 0,
          srcY: 0,
          srcWidth: 256,
          srcHeight: 256,
          dstX: dstX,
          dstY: dstY,
          color: scene.colorEast(gameObjectIndex)
      );

      engine.renderSprite(
          image: images.sphereSouth,
          srcX: 0,
          srcY: 0,
          srcWidth: 256,
          srcHeight: 256,
          dstX: dstX,
          dstY: dstY,
          color: scene.colorSouth(gameObjectIndex)
      );

      engine.renderSprite(
          image: images.sphereWest,
          srcX: 0,
          srcY: 0,
          srcWidth: 256,
          srcHeight: 256,
          dstX: dstX,
          dstY: dstY,
          color: scene.colorWest(gameObjectIndex)
      );

      return;
    }


    if (
      type == ItemType.Object &&
      const [
        ObjectType.Crystal_Glowing_False,
        ObjectType.Crystal_Glowing_True,
      ].contains(subType)
    ){
      final scene = this.scene;
      final gameObjectIndex = scene.getIndexPosition(gameObject);
      const scale = 0.35;

      final dstX = gameObject.renderX;
      final dstY = gameObject.renderY;
      const anchorY = 0.66;

      final sprite = images.crystal;

      engine.setBlendModeModulate();

      final color = (subType == ObjectType.Crystal_Glowing_False ? colors.purple_3 : colors.aqua_2).value;

      render.sprite(
          sprite: sprite,
          frame: sprite.getFrame(row: 0, column: 0),
          color: color,
          scale: scale,
          dstX: dstX,
          dstY: dstY,
          anchorY: anchorY,
      );

      render.sprite(
          sprite: sprite,
          frame: sprite.getFrame(row: 0, column: 1),
          color: color,
          scale: scale,
          dstX: dstX,
          dstY: dstY,
          anchorY: anchorY,
      );

      render.sprite(
          sprite: sprite,
          frame: sprite.getFrame(row: 0, column: 2),
          color: color,
          scale: scale,
          dstX: dstX,
          dstY: dstY,
        anchorY: anchorY,
      );

      render.sprite(
          sprite: sprite,
          frame: sprite.getFrame(row: 0, column: 3),
          color: color,
          scale: scale,
          dstX: dstX,
          dstY: dstY,
        anchorY: anchorY,
      );

      if (subType == ObjectType.Crystal_Glowing_False){
        render.sprite(
          sprite: sprite,
          frame: sprite.getFrame(row: 0, column: 0),
          color: scene.colorEast(gameObjectIndex),
          scale: scale,
          dstX: dstX,
          dstY: dstY,
          anchorY: anchorY,
        );

        render.sprite(
          sprite: sprite,
          frame: sprite.getFrame(row: 0, column: 1),
          color: scene.colorNorth(gameObjectIndex),
          scale: scale,
          dstX: dstX,
          dstY: dstY,
          anchorY: anchorY,
        );

        render.sprite(
          sprite: sprite,
          frame: sprite.getFrame(row: 0, column: 2),
          color: scene.colorSouth(gameObjectIndex),
          scale: scale,
          dstX: dstX,
          dstY: dstY,
          anchorY: anchorY,
        );

        render.sprite(
          sprite: sprite,
          frame: sprite.getFrame(row: 0, column: 3),
          color: scene.colorWest(gameObjectIndex),
          scale: scale,
          dstX: dstX,
          dstY: dstY,
          anchorY: anchorY,
        );
      }

      engine.setBlendModeDstATop();
      return;
    }

    if (
      type == ItemType.Object &&
      const [
        ObjectType.Rock1,
      ].contains(subType)
    ){
      final scene = this.scene;
      final gameObjectIndex = scene.getIndexPosition(gameObject);
      const scale = 0.15;

      final dstX = gameObject.renderX;
      final dstY = gameObject.renderY;
      const anchorY = 0.66;

      final sprite = images.rock1;

      // engine.setBlendModeModulate();

      // render.sprite(
      //   sprite: sprite,
      //   frame: sprite.getFrame(row: 0, column: SurfaceIndex.solid),
      //   color: colors.grey_1.value,
      //   scale: scale,
      //   dstX: dstX,
      //   dstY: dstY,
      //   anchorY: anchorY,
      // );

      render.sprite(
        sprite: sprite,
        frame: sprite.getFrame(row: 0, column: SurfaceIndex.south),
        color: scene.colorSouth(gameObjectIndex),
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      render.sprite(
        sprite: sprite,
        frame: sprite.getFrame(row: 0, column: SurfaceIndex.top),
        color: scene.nodeColors[gameObjectIndex],
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      render.sprite(
        sprite: sprite,
        frame: sprite.getFrame(row: 0, column: SurfaceIndex.west),
        color: scene.colorWest(gameObjectIndex),
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      render.sprite(
        sprite: sprite,
        frame: sprite.getFrame(row: 0, column: SurfaceIndex.north),
        color: scene.colorNorth(gameObjectIndex),
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      render.sprite(
        sprite: sprite,
        frame: sprite.getFrame(row: 0, column: SurfaceIndex.east),
        color: scene.colorEast(gameObjectIndex),
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      // engine.setBlendModeDstATop();
      return;
    }

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

    final image = getImageForGameObjectType(type);
    final src = Atlas.getSrc(type, subType);

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
