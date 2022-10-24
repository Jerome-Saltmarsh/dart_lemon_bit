import 'dart:math';
import 'dart:ui' as ui;

import 'package:bleed_common/node_size.dart';
import 'package:gamestream_flutter/isometric/nodes/render/atlas_src_gameobjects.dart';
import 'package:gamestream_flutter/isometric/nodes/render/render_node.dart';
import 'package:gamestream_flutter/isometric/render/highlight_character_nearest_mouse.dart';
import 'package:gamestream_flutter/isometric/render/renderCharacter.dart';
import 'package:gamestream_flutter/isometric/render/render_floating_texts.dart';
import 'package:gamestream_flutter/isometric/render/render_projectiles.dart';
import 'package:lemon_math/library.dart';

import 'library.dart';

class GameRender {
  static var totalRemaining = 0;
  static var totalIndex = 0;
  static final renderOrderGrid = RenderOrderNodes();
  static final renderOrderParticle = RenderOrderParticle();
  static final renderOrderProjectiles = RenderOrderProjectiles();
  static final renderOrderCharacters = RenderOrderCharacters();
  static final renderOrderGameObjects = RenderOrderGameObjects();

  static var indexShowPerceptible = false;
  static var playerRenderRow = 0;
  static var playerRenderColumn = 0;
  static var playerZ = 0;
  static var playerRow = 0;
  static var playerColumn = 0;

  static var offscreenNodesTop = 0;
  static var offscreenNodesRight = 0;
  static var offscreenNodesBottom = 0;
  static var offscreenNodesLeft = 0;

  static var onscreenNodes = 0;
  static var offscreenNodes = 0;

  static var screenTop = 0.0;
  static var screenRight = 0.0;
  static var screenBottom = 0.0;
  static var screenLeft = 0.0;

  static var currentNodeZ = 0;
  static var currentNodeRow = 0;
  static var currentNodeColumn = 0;
  static var currentNodeDstX = 0.0;
  static var currentNodeDstY = 0.0;
  static var currentNodeIndex = 0;
  static var currentNodeType = 0;

  static var indexShow = 0;
  static var indexShowRow = 0;
  static var indexShowColumn = 0;
  static var indexShowZ = 0;

  static late Particle currentParticle;
  static late Character currentRenderCharacter;
  static late GameObject currentRenderGameObject;
  static late Projectile currentRenderProjectile;

  static var nodesRowsMax = 0;
  static var nodesShiftIndex = 0;
  static var nodesScreenTopLeftRow = 0;
  static var nodesScreenBottomRightRow = 0;
  static var nodesGridTotalColumnsMinusOne = 0;
  static var nodesGridTotalZMinusOne = 0;
  static var nodesPlayerColumnRow = 0;
  static var nodesPlayerUnderRoof = false;
  static var nodesStartRow = 0;
  static var nodeStartColumn = 0;
  static var nodesMaxZ = 0;
  static var nodesMinZ = 0;

  static final maxZRender = Watch<int>(GameState.nodesTotalZ, clamp: (int value){
    return clamp<int>(value, 0, max(GameState.nodesTotalZ - 1, 0));
  });

  static double get currentNodeRenderX => (currentNodeRow - currentNodeColumn) * tileSizeHalf;
  static double get currentNodeRenderY => GameConvert.convertRowColumnZToRenderY(currentNodeRow, currentNodeColumn, currentNodeZ);

  static int get currentNodeShade => GameState.nodesShade[currentNodeIndex];
  static int get currentNodeColor => GameState.colorShades[currentNodeShade];


  static void renderCurrentParticle() =>
    renderParticle(currentParticle);

  static void renderCurrentProjectile() =>
    renderProjectile(currentRenderProjectile);

  static void renderCurrentGameObject() =>
    renderGameObject(currentRenderGameObject);

  static void updateCurrentParticle(){
    currentParticle = GameState.particles[renderOrderParticle.index];
    renderOrderParticle.order = currentParticle.renderOrder;
    renderOrderParticle.orderZ = currentParticle.indexZ;
  }

  static void updateCurrentProjectile(){
    currentRenderProjectile = GameState.projectiles[renderOrderProjectiles.index];
    renderOrderProjectiles.order = currentRenderProjectile.renderOrder;
    renderOrderProjectiles.orderZ = currentRenderProjectile.indexZ;
  }

  static void updateCurrentGameObject(){
    currentRenderGameObject = GameState.gameObjects[renderOrderGameObjects.index];
    renderOrderGameObjects.order = currentRenderGameObject.renderOrder;
    renderOrderGameObjects.orderZ = currentRenderGameObject.indexZ;
  }

  static void renderCurrentCharacter(){
    renderCharacter(currentRenderCharacter);
  }

  static void updateCurrentCharacter() {
    currentRenderCharacter = GameState.characters[renderOrderCharacters.index];
    renderOrderCharacters.order = currentRenderCharacter.renderOrder;
    renderOrderCharacters.orderZ = currentRenderCharacter.indexZ;
  }

  static void nodesTrimLeft(){
    final offscreen = countLeftOffscreen;
    if (offscreen <= 0) return;
    currentNodeColumn -= offscreen;
    currentNodeRow += offscreen;
    while (currentNodeRenderX < screenLeft){
      currentNodeRow++;
      currentNodeColumn--;
    }
    nodesSetStart();
  }

  static void nodesSetStart(){
    nodesStartRow = currentNodeRow;
    nodeStartColumn = currentNodeColumn;
  }

  static void nodesShiftIndexDown(){
    currentNodeColumn = currentNodeRow + currentNodeColumn + 1;
    currentNodeRow = 0;
    if (currentNodeColumn < GameState.nodesTotalColumns) {
      return nodesSetStart();
    }
    currentNodeRow = currentNodeColumn - nodesGridTotalColumnsMinusOne;
    currentNodeColumn = nodesGridTotalColumnsMinusOne;

    if (currentNodeRow >= GameState.nodesTotalRows){
      renderOrderGrid.remaining = false;
      return;
    }
    currentNodeDstY = ((currentNodeRow + currentNodeColumn) * nodeSizeHalf) - (currentNodeZ * nodeHeight);
    nodesSetStart();
  }

  // ACTIONS

  static void renderParticle(Particle particle) {
    switch (particle.type) {
      case ParticleType.Bubble:
        if (particle.duration > 26) {
          particle.deactivate();
          break;
        }
        Engine.renderSprite(
          image: GameImages.gameobjects,
          dstX: getRenderV3X(particle),
          dstY: getRenderV3Y(particle),
          srcX: 0.0,
          srcY: 32,
          srcWidth: 8,
          srcHeight: 8,
          color: GameState.getV3RenderColor(particle),
        );
        break;
      // const size = 8.0;
        // return Engine.renderBuffer(
        //   dstX: particle.renderX,
        //   dstY: particle.renderY,
        //   srcX: 2864.0,
        //   srcY: ((particle.frame ~/ 2) % 6) * size,
        //   srcWidth: size,
        //   srcHeight: size,
        //   color: getRenderColor(particle),
        // );
      case ParticleType.Bubble_Small:
        Engine.renderSprite(
          image: GameImages.gameobjects,
          dstX: getRenderV3X(particle),
          dstY: getRenderV3Y(particle),
          srcX: 0.0,
          srcY: 32,
          srcWidth: 4,
          srcHeight: 4,
          color: GameState.getV3RenderColor(particle),
        );
        break;
      case ParticleType.Bullet_Ring:
        Engine.renderSprite(
          image: GameImages.gameobjects,
          dstX: getRenderV3X(particle),
          dstY: getRenderV3Y(particle),
          srcX: 0.0,
          srcY: 32,
          srcWidth: 4,
          srcHeight: 4,
          color: GameState.getV3RenderColor(particle),
        );
        break;
      case ParticleType.Water_Drop:
        Engine.renderSprite(
          image: GameImages.gameobjects,
          dstX: getRenderV3X(particle),
          dstY: getRenderV3Y(particle),
          srcX: 0.0,
          srcY: 40,
          srcWidth: 4,
          srcHeight: 4,
          color: GameState.getV3RenderColor(particle),
        );
        break;
      case ParticleType.Smoke:
        // Engine.renderBuffer(
        //   dstX: particle.renderX,
        //   dstY: particle.renderY,
        //   srcX: 5612,
        //   srcY: 0,
        //   srcWidth: 50,
        //   srcHeight: 50,
        //   scale: particle.scale,
        //   color: getRenderColor(particle),
        // );
        break;
      case ParticleType.Block_Wood:
        Engine.renderSprite(
          image: GameImages.gameobjects,
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 0,
          srcY: 56,
          srcWidth: 8,
          srcHeight: 8,
          scale: particle.scale,
          color: GameState.getV3RenderColor(particle),
        );
        break;
      case ParticleType.Block_Grass:
        Engine.renderSprite(
          image: GameImages.gameobjects,
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 0,
          srcY: 48,
          srcWidth: 8,
          srcHeight: 8,
          scale: particle.scale,
          color: GameState.getV3RenderColor(particle),
        );
        break;
      case ParticleType.Block_Brick:
        Engine.renderSprite(
          image: GameImages.gameobjects,
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 0,
          srcY: 64,
          srcWidth: 8,
          srcHeight: 8,
          scale: particle.scale,
          color: GameState.getV3RenderColor(particle),
        );
        break;
      case ParticleType.Fire:
        if (particle.frame > 12 ) {
          return particle.deactivate();
        }
        Engine.renderSprite(
          image: GameImages.particles,
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 1,
          srcY: 1 + 32.0 * particle.frame ,
          srcWidth: 32,
          srcHeight: 32,
          scale: particle.scale,
        );
        break;
      case ParticleType.Shell:
        Engine.renderSprite(
          image: GameImages.particles,
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 34 + (particle.direction * 32),
          srcY: 1,
          srcWidth: 32,
          srcHeight: 32,
          scale: 0.25,
          color: GameState.getV3RenderColor(particle),
        );
        break;
      case ParticleType.Fire_Purple:
        if (particle.frame > 24 ) {
          particle.deactivate();
          break;
        }
        Engine.renderSprite(
          image: GameImages.particles,
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 291,
          srcY: 1 + 32.0 * (particle.frame ~/ 2) ,
          srcWidth: 32,
          srcHeight: 32,
          scale: particle.scale,
        );
        break;
      case ParticleType.Blood:
        casteShadowDownV3(particle);
        Engine.renderSprite(
          image: GameImages.gameobjects,
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 16,
          srcY: 25,
          srcWidth: 8,
          srcHeight: 8,
          color: GameState.getV3RenderColor(particle),
        );
        break;
      case ParticleType.Orb_Shard:
        const size = 16.0;
        Engine.renderSprite(
          image: GameImages.gameobjects,
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 224 ,
          srcY: (particle.frame % 4) * size,
          srcWidth: size,
          srcHeight: size,
          scale: particle.scale,
        );
        break;
      case ParticleType.Star_Explosion:
        if (particle.frame >= 7) {
          return particle.deactivate();
        }
        Engine.renderSprite(
          image: GameImages.particles,
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 234.0,
          srcY: 1 + 32.0 + (32.0 * particle.frame),
          srcWidth: 32,
          srcHeight: 32,
        );
        return;
      case ParticleType.Zombie_Arm:
        casteShadowDownV3(particle);
        Engine.renderSprite(
          image: GameImages.particles,
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 34.0,
          srcY: 1 + 64.0 * particle.direction,
          srcWidth: 64,
          srcHeight: 64,
          color: GameState.getV3RenderColor(particle),
        );
        break;
      case ParticleType.Zombie_Head:
        casteShadowDownV3(particle);
        Engine.renderSprite(
          image: GameImages.particles,
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 34.0 + 64,
          srcY: 64.0 * particle.direction,
          srcWidth: 64,
          srcHeight: 64,
          color: GameState.getV3RenderColor(particle),
        );
        break;
      case ParticleType.Zombie_leg:
        casteShadowDownV3(particle);
        Engine.renderSprite(
          image: GameImages.particles,
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 34.0 + (64 * 2),
          srcY: 64.0 * particle.direction,
          srcWidth: 64,
          srcHeight: 64,
          color: GameState.getV3RenderColor(particle),
        );
        break;
      case ParticleType.Zombie_Torso:
        casteShadowDownV3(particle);
        Engine.renderSprite(
          image: GameImages.particles,
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 34.0 + (64 * 3),
          srcY: 64.0 * particle.direction,
          srcWidth: 64,
          srcHeight: 64,
          color: GameState.getV3RenderColor(particle),
        );
        break;
      case ParticleType.Strike_Blade:
        if (particle.frame >= 6 ) {
          particle.deactivate();
          break;
        }
        const size = 64.0;
        casteShadowDownV3(particle);
        Engine.renderSpriteRotated(
          image: GameImages.particles,
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 357,
          srcY: 1 + particle.frame * size,
          srcWidth: size,
          srcHeight: size,
          scale: particle.scale,
          rotation: particle.rotation + (Engine.PI_Half + Engine.PI_Quarter),
        );
        break;
      default:
        break;
    }
  }


  static void resetRenderOrder(RenderOrder value){
    value.reset();
    if (value.remaining){
      totalRemaining++;
    }
  }
  
  static void renderGameObject(GameObject gameObject) {
    switch (gameObject.type) {
      case GameObjectType.Rock:
        Engine.renderSprite(
          image: GameImages.gameobjects,
          dstX: gameObject.renderX,
          dstY: gameObject.renderY,
          srcX: AtlasSrcGameObjects.Rock_X,
          srcY: AtlasSrcGameObjects.Rock_Y,
          srcWidth: AtlasSrcGameObjects.Rock_Width,
          srcHeight: AtlasSrcGameObjects.Rock_Height,
          color: GameState.getV3RenderColor(gameObject),
        );
        return;
      case GameObjectType.Loot:
        Engine.renderSprite(
          image: GameImages.gameobjects,
          dstX: getRenderV3X(gameObject),
          dstY: getRenderV3Y(gameObject),
          srcX: AtlasSrcGameObjects.Loot_X,
          srcY: AtlasSrcGameObjects.Loot_Y,
          srcWidth: AtlasSrcGameObjects.Loot_Width,
          srcHeight: AtlasSrcGameObjects.Loot_Height,
          color: GameState.getV3RenderColor(gameObject),
        );
        return;
      case GameObjectType.Barrel:
        Engine.renderSprite(
          image: GameImages.gameobjects,
          dstX: getRenderV3X(gameObject),
          dstY: getRenderV3Y(gameObject),
          srcX: AtlasSrcGameObjects.Barrel_X,
          srcY: AtlasSrcGameObjects.Barrel_Y,
          srcWidth: AtlasSrcGameObjects.Barrel_Width,
          srcHeight: AtlasSrcGameObjects.Barrel_Height,
          anchorY: AtlasSrcGameObjects.Barrel_Anchor,
          color: GameState.getV3RenderColor(gameObject),
        );
        return;
      case GameObjectType.Tavern_Sign:
        Engine.renderSprite(
          image: GameImages.gameobjects,
          dstX: getRenderV3X(gameObject),
          dstY: getRenderV3Y(gameObject),
          srcX: AtlasSrcGameObjects.Tavern_Sign_X,
          srcY: AtlasSrcGameObjects.Tavern_Sign_Y,
          srcWidth: AtlasSrcGameObjects.Tavern_Sign_Width,
          srcHeight: AtlasSrcGameObjects.Tavern_Sign_Height,
          color: GameState.getV3RenderColor(gameObject),
        );
        return;
      case GameObjectType.Candle:
        Engine.renderSprite(
          image: GameImages.gameobjects,
          dstX: getRenderV3X(gameObject),
          dstY: getRenderV3Y(gameObject),
          srcX: 1812,
          srcY: 0,
          srcWidth: 3,
          srcHeight: 10,
          anchorY: 0.95,
        );
        return;
      case GameObjectType.Bottle:
        Engine.renderSprite(
          image: GameImages.gameobjects,
          dstX: getRenderV3X(gameObject),
          dstY: getRenderV3Y(gameObject),
          srcX: 1811,
          srcY: 11,
          srcWidth: 5,
          srcHeight: 14,
          anchorY: 0.95,
          color: GameState.getV3RenderColor(gameObject),
        );
        return;
      case GameObjectType.Wheel:
        Engine.renderSprite(
          image: GameImages.gameobjects,
          dstX: getRenderV3X(gameObject),
          dstY: getRenderV3Y(gameObject),
          srcX: 1775,
          srcY: 0,
          srcWidth: 34,
          srcHeight: 40,
          anchorY: 0.9,
          color: GameState.getV3RenderColor(gameObject),
        );
        return;
      case GameObjectType.Flower:
        Engine.renderSprite(
          image: GameImages.gameobjects,
          dstX: getRenderV3X(gameObject),
          dstY: getRenderV3Y(gameObject),
          srcX: 1680,
          srcY: 0,
          srcWidth: 16,
          srcHeight: 16,
          color: GameState.getV3RenderColor(gameObject),
        );
        return;
      case GameObjectType.Stick:
        Engine.renderSprite(
          image: GameImages.gameobjects,
          dstX: getRenderV3X(gameObject),
          dstY: getRenderV3Y(gameObject),
          srcX: 1696,
          srcY: 0,
          srcWidth: 16,
          srcHeight: 16,
          color: GameState.getV3RenderColor(gameObject),
        );
        return;
      case GameObjectType.Crystal:
        Engine.renderSprite(
            image: GameImages.gameobjects,
            dstX: getRenderV3X(gameObject),
            dstY: getRenderV3Y(gameObject),
            srcX: AtlasSrcGameObjects.Crystal_Large_X,
            srcY: AtlasSrcGameObjects.Crystal_Large_Y,
            srcWidth: AtlasSrcGameObjects.Crystal_Large_Width,
            srcHeight: AtlasSrcGameObjects.Crystal_Large_Height,
            anchorY: AtlasSrcGameObjects.Crystal_Anchor_Y
        );
        return;
      case GameObjectType.Cup:
        Engine.renderSprite(
          image: GameImages.gameobjects,
          dstX: getRenderV3X(gameObject),
          dstY: getRenderV3Y(gameObject),
          srcX: AtlasSrcGameObjects.Cup_X,
          srcY: AtlasSrcGameObjects.Cup_Y,
          srcWidth: AtlasSrcGameObjects.Cup_Width,
          srcHeight: AtlasSrcGameObjects.Cup_Height,
          anchorY: AtlasSrcGameObjects.Cup_Anchor_Y,
        );
        return;
      case GameObjectType.Lantern_Red:
        Engine.renderSprite(
          image: GameImages.gameobjects,
          dstX:getRenderV3X(gameObject),
          dstY:getRenderV3Y(gameObject),
          srcX: 1744,
          srcY: 48,
          srcWidth: 12,
          srcHeight: 22,
          scale: 1.0,
          color: GameState.colorShades[Shade.Very_Bright],
        );
        return;
      case GameObjectType.Wooden_Shelf_Row:
        Engine.renderSprite(
            image: GameImages.gameobjects,
            dstX:getRenderV3X(gameObject),
            dstY:getRenderV3Y(gameObject),
            srcX: 1664,
            srcY: 16,
            srcWidth: 32,
            srcHeight: 38
        );
        return;
      case GameObjectType.Book_Purple:
        Engine.renderSprite(
          image: GameImages.gameobjects,
          dstX:getRenderV3X(gameObject),
          dstY:getRenderV3Y(gameObject),
          srcX: 1697,
          srcY: 16,
          srcWidth: 8,
          srcHeight: 15,
        );
        return;
      case GameObjectType.Crystal_Small_Blue:
        Engine.renderSprite(
          image: GameImages.gameobjects,
          dstX:getRenderV3X(gameObject),
          dstY:getRenderV3Y(gameObject),
          srcX: 1697,
          srcY: 33,
          srcWidth: 10,
          srcHeight: 19,
        );
        return;
      case GameObjectType.Flower_Green:
        Engine.renderSprite(
          image: GameImages.gameobjects,
          dstX:getRenderV3X(gameObject),
          dstY:getRenderV3Y(gameObject),
          srcX: 1696,
          srcY: 53,
          srcWidth: 9,
          srcHeight: 7,
        );
        return;

      case GameObjectType.Weapon_Shotgun:
        renderBouncingGameObjectShadow(gameObject);
        Engine.renderSprite(
            image: GameImages.gameobjects,
            dstX: getRenderV3X(gameObject),
            dstY: getRenderYBouncing(gameObject),
            srcX: AtlasSrcGameObjects.Shotgun_X,
            srcY: AtlasSrcGameObjects.Shotgun_Y,
            srcWidth: AtlasSrcGameObjects.Shotgun_Width,
            srcHeight: AtlasSrcGameObjects.Shotgun_Height,
            color: GameState.getV3RenderColor(gameObject)
        );
        break;

      case GameObjectType.Weapon_Handgun:
        renderBouncingGameObjectShadow(gameObject);
        Engine.renderSprite(
            image: GameImages.gameobjects,
            dstX: getRenderV3X(gameObject),
            dstY: getRenderYBouncing(gameObject),
            srcX: AtlasSrcGameObjects.Handgun_X,
            srcY: AtlasSrcGameObjects.Handgun_Y,
            srcWidth: AtlasSrcGameObjects.Handgun_Width,
            srcHeight: AtlasSrcGameObjects.Handgun_Height,
            color: GameState.getV3RenderColor(gameObject)
        );
        break;

      case GameObjectType.Weapon_Blade:
        renderBouncingGameObjectShadow(gameObject);
        Engine.renderSprite(
            image: GameImages.gameobjects,
            dstX: getRenderV3X(gameObject),
            dstY: getRenderYBouncing(gameObject),
            srcX: AtlasSrcGameObjects.Sword_X,
            srcY: AtlasSrcGameObjects.Sword_Y,
            srcWidth: AtlasSrcGameObjects.Sword_Width,
            srcHeight: AtlasSrcGameObjects.Sword_Height,
            color: GameState.getV3RenderColor(gameObject)
        );
        break;

      case GameObjectType.Weapon_Bow:
        renderBouncingGameObjectShadow(gameObject);
        Engine.renderSprite(
            image: GameImages.gameobjects,
            dstX: getRenderV3X(gameObject),
            dstY: getRenderYBouncing(gameObject),
            srcX: AtlasSrcGameObjects.Bow_X,
            srcY: AtlasSrcGameObjects.Bow_Y,
            srcWidth: AtlasSrcGameObjects.Bow_Width,
            srcHeight: AtlasSrcGameObjects.Bow_Height,
            color: GameState.getV3RenderColor(gameObject)
        );
        break;

      case GameObjectType.Weapon_Staff:
        renderBouncingGameObjectShadow(gameObject);
        Engine.renderSprite(
            image: GameImages.gameobjects,
            dstX: getRenderV3X(gameObject),
            dstY: getRenderYBouncing(gameObject),
            srcX: AtlasSrcGameObjects.Staff_X,
            srcY: AtlasSrcGameObjects.Staff_Y,
            srcWidth: AtlasSrcGameObjects.Staff_Width,
            srcHeight: AtlasSrcGameObjects.Staff_Height,
            color: GameState.getV3RenderColor(gameObject)
        );
        break;
    }
  }

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

  static void renderMouseWireFrame() {
    GameIO.mouseRaycast(renderWireFrameBlue);
  }

  static void renderMouseTargetName() {
    if (!GameState.player.mouseTargetAllie.value) return;
    final mouseTargetName = GameState.player.mouseTargetName.value;
    if (mouseTargetName == null) return;
    renderText(
        text: mouseTargetName,
        x: GameState.player.attackTarget.renderX,
        y: GameState.player.attackTarget.renderY - 55);
  }

  static void renderSprites() {
    totalRemaining = 0;
    resetRenderOrder(renderOrderCharacters);
    resetRenderOrder(renderOrderGameObjects);
    resetRenderOrder(renderOrderGrid);
    resetRenderOrder(renderOrderParticle);
    resetRenderOrder(renderOrderProjectiles);

    RenderOrder first = renderOrderGrid;

    if (totalRemaining == 0) return;

    while (true) {
      RenderOrder next = first;
      if (renderOrderCharacters.remaining){
        next = next.compare(renderOrderCharacters);
      }
      if (renderOrderProjectiles.remaining){
        next = next.compare(renderOrderProjectiles);
      }
      if (renderOrderGameObjects.remaining){
        next = next.compare(renderOrderGameObjects);
      }
      if (renderOrderParticle.remaining){
        next = next.compare(renderOrderParticle);
      }
      next.renderNext();
      if (next.remaining) continue;
      totalRemaining--;
      if (totalRemaining == 0) return;

      if (totalRemaining > 1) {
        if (next == renderOrderGrid) {
          if (renderOrderCharacters.remaining) {
            next = renderOrderCharacters;
          }
          if (renderOrderProjectiles.remaining) {
            next = renderOrderProjectiles;
          }
          if (renderOrderGameObjects.remaining) {
            next = renderOrderGameObjects;
          }
          if (renderOrderParticle.remaining) {
            next = renderOrderParticle;
          }
        }
        continue;
      }

      while (renderOrderGrid.remaining) {
        renderOrderGrid.renderNext();
      }
      while (renderOrderCharacters.remaining) {
        renderOrderCharacters.renderNext();
      }
      return;
    }
  }

  static void renderShadow(double x, double y, double z, {double scale = 1}) =>
      Engine.renderSprite(
        image: GameImages.gameobjects,
        dstX: (x - y) * 0.5,
        dstY: ((y + x) * 0.5) - z,
        srcX: 0,
        srcY: 32,
        srcWidth: 8,
        srcHeight: 8,
        scale: scale,
      );

  static void renderCurrentNodeLine() {
    while (
        currentNodeColumn >= 0 &&
        currentNodeRow <= nodesRowsMax &&
        currentNodeDstX <= screenRight
    ){
      currentNodeType = GameState.nodesType[currentNodeIndex];
      if (currentNodeType != NodeType.Empty){
        renderNodeAt();
      }
      currentNodeRow++;
      currentNodeColumn--;
      currentNodeIndex += nodesGridTotalColumnsMinusOne;
      currentNodeDstX += GameConstants.spriteWidth;
    }
  }

  static void nodesUpdateFunction() {
    currentNodeZ++;
    if (currentNodeZ > nodesMaxZ) {
      currentNodeZ = 0;
      nodesShiftIndexDown();
      if (!renderOrderGrid.remaining) return;
      nodesCalculateMinMaxZ();
      if (!renderOrderGrid.remaining) return;
      nodesTrimLeft();

      while (currentNodeRenderY > screenBottom) {
        currentNodeZ++;
        if (currentNodeZ > nodesMaxZ) {
          renderOrderGrid.remaining = false;
          return;
        }
      }
    } else {
      currentNodeRow = nodesStartRow;
      currentNodeColumn = nodeStartColumn;
    }
    currentNodeDstX = (currentNodeRow - currentNodeColumn) * nodeSizeHalf;
    currentNodeDstY = ((currentNodeRow + currentNodeColumn) * nodeSizeHalf) - (currentNodeZ * nodeHeight);
    currentNodeIndex = (currentNodeZ * GameState.nodesArea) + (currentNodeRow * GameState.nodesTotalColumns) + currentNodeColumn;
    currentNodeType = GameState.nodesType[currentNodeIndex];
    renderOrderGrid.order = ((currentNodeRow + currentNodeColumn) * tileSize) + tileSizeHalf;
    renderOrderGrid.orderZ = currentNodeZ;
  }

  static void resetNodes() {
    nodesRowsMax = GameState.nodesTotalRows - 1;
    nodesGridTotalZMinusOne = GameState.nodesTotalZ - 1;
    offscreenNodesTop = 0;
    offscreenNodesRight = 0;
    offscreenNodesBottom = 0;
    offscreenNodesLeft = 0;
    offscreenNodes = 0;
    onscreenNodes = 0;
    nodesMinZ = 0;
    renderOrderGrid.order = 0;
    renderOrderGrid.orderZ = 0;
    currentNodeZ = 0;
    nodesGridTotalColumnsMinusOne = GameState.nodesTotalColumns - 1;
    playerZ = GameState.player.indexZ;
    playerRow = GameState.player.indexRow;
    playerColumn = GameState.player.indexColumn;
    nodesPlayerColumnRow = playerRow + playerColumn;
    playerRenderRow = playerRow - (GameState.player.indexZ ~/ 2);
    playerRenderColumn = playerColumn - (GameState.player.indexZ ~/ 2);
    nodesPlayerUnderRoof = GameState.gridIsUnderSomething(playerZ, playerRow, playerColumn);

    indexShow = GameQueries.inBoundsVector3(GameState.player) ? GameState.player.nodeIndex : 0;
    indexShowRow = GameState.convertNodeIndexToRow(indexShow);
    indexShowColumn = GameState.convertNodeIndexToColumn(indexShow);
    indexShowZ = GameState.convertNodeIndexToZ(indexShow);

    indexShowPerceptible =
        GameState.gridIsPerceptible(indexShow) &&
            GameState.gridIsPerceptible(indexShow + 1) &&
            GameState.gridIsPerceptible(indexShow - 1) &&
            GameState.gridIsPerceptible(indexShow + GameState.nodesTotalColumns) &&
            GameState.gridIsPerceptible(indexShow - GameState.nodesTotalColumns) &&
            GameState.gridIsPerceptible(indexShow + GameState.nodesTotalColumns + 1) ;

    screenRight = Engine.screen.right + tileSize;
    screenLeft = Engine.screen.left - tileSize;
    screenTop = Engine.screen.top - 72;
    screenBottom = Engine.screen.bottom + 72;
    var screenTopLeftColumn = GameConvert.convertWorldToColumn(screenLeft, screenTop, 0);
    nodesScreenBottomRightRow = clamp(GameConvert.convertWorldToRow(screenRight, screenBottom, 0), 0, GameState.nodesTotalRows - 1);
    nodesScreenTopLeftRow = GameConvert.convertWorldToRow(screenLeft, screenTop, 0);

    if (nodesScreenTopLeftRow < 0){
      screenTopLeftColumn += nodesScreenTopLeftRow;
      nodesScreenTopLeftRow = 0;
    }
    if (screenTopLeftColumn < 0){
      nodesScreenTopLeftRow += screenTopLeftColumn;
      screenTopLeftColumn = 0;
    }
    if (screenTopLeftColumn >= GameState.nodesTotalColumns){
      nodesScreenTopLeftRow = screenTopLeftColumn - nodesGridTotalColumnsMinusOne;
      screenTopLeftColumn = nodesGridTotalColumnsMinusOne;
    }
    if (nodesScreenTopLeftRow < 0 || screenTopLeftColumn < 0){
      nodesScreenTopLeftRow = 0;
      screenTopLeftColumn = 0;
    }

    currentNodeRow = nodesScreenTopLeftRow;
    currentNodeColumn = screenTopLeftColumn;

    nodesShiftIndex = 0;
    nodesCalculateMinMaxZ();
    nodesTrimTop();
    nodesTrimLeft();

    currentNodeDstX = (currentNodeRow - currentNodeColumn) * nodeSizeHalf;
    currentNodeDstY = ((currentNodeRow + currentNodeColumn) * nodeSizeHalf) - (currentNodeZ * nodeHeight);
    currentNodeIndex = (currentNodeZ * GameState.nodesArea) + (currentNodeRow * GameState.nodesTotalColumns) + currentNodeColumn;
    currentNodeType = GameState.nodesType[currentNodeIndex];

    while (GameState.visibleIndex > 0) {
      GameState.nodesVisible[GameState.nodesVisibleIndex[GameState.visibleIndex]] = true;
      GameState.visibleIndex--;
    }
    GameState.nodesVisible[GameState.nodesVisibleIndex[0]] = true;


    if (!indexShowPerceptible) {
      const radius = 3;
      for (var r = -radius; r <= radius + 2; r++){
        for (var c = -radius; c <= radius + 2; c++){
          if (indexShowRow + r < 0) continue;
          if (indexShowRow + r >= GameState.nodesTotalRows) continue;
          if (indexShowColumn + c < 0) continue;
          if (indexShowColumn + c >= GameState.nodesTotalColumns) continue;
          nodesHideIndex(indexShow - (GameState.nodesTotalColumns * r) + c);
        }
      }
    }

    renderOrderGrid.total = renderOrderGrid.getTotal();
    renderOrderGrid.index = 0;
    renderOrderGrid.remaining = renderOrderGrid.total > 0;
    GameState.refreshDynamicLightGrid();
    GameState.applyEmissions();

    if (GameState.editMode){
      GameState.applyEmissionDynamic(
        index: GameEditor.nodeIndex.value,
        maxBrightness: Shade.Very_Bright,
      );
    }

    highlightCharacterNearMouse();
  }

  static void nodesHideIndex(int index){
    var i = index + GameState.nodesArea + GameState.nodesTotalColumns + 1;
    while (true) {
      if (i >= GameState.nodesTotal) break;
      GameState.nodesVisible[i] = false;
      GameState.nodesVisibleIndex[GameState.visibleIndex] = i;
      GameState.visibleIndex++;
      i += GameState.nodesArea + GameState.nodesArea + GameState.nodesTotalColumns + 1;
    }
    i = index + GameState.nodesArea + GameState.nodesArea + GameState.nodesTotalColumns + 1;
    while (true) {
      if (i >= GameState.nodesTotal) break;
      GameState.nodesVisible[i] = false;
      GameState.nodesVisibleIndex[GameState.visibleIndex] = i;
      GameState.visibleIndex++;
      i += GameState.nodesArea + GameState.nodesArea + GameState.nodesTotalColumns + 1;
    }
  }

  static void nodesRevealRaycast(int z, int row, int column){
    if (!GameQueries.isInboundZRC(z, row, column)) return;

    for (; z < GameState.nodesTotalZ; z += 2){
      row++;
      column++;
      if (row >= GameState.nodesTotalRows) return;
      if (column >= GameState.nodesTotalColumns) return;
      GameState.nodesVisible[GameState.getNodeIndexZRC(z, row, column)] = false;
      if (z < GameState.nodesTotalZ - 2){
        GameState.nodesVisible[GameState.getNodeIndexZRC(z + 1, row, column)] = false;
      }
    }
  }

  static void nodesRevealAbove(int z, int row, int column){
    for (; z < GameState.nodesTotalZ; z++){
      GameState.nodesVisible[GameState.getNodeIndexZRC(z, row, column)] = false;
    }
  }

  static void nodesTrimTop() {
    while (currentNodeRenderY < screenTop){
      nodesShiftIndexDown();
    }
    nodesCalculateMinMaxZ();
    nodesSetStart();
  }

  // given a grid coordinate row / column workout the maximum z before it goes above the top of the screen.
  // otherwise use totalZ;
  // calculate the world position Y at row / column, then workout its distance from the top of the screen;
  static void nodesCalculateMinMaxZ(){
    final bottom = GameConvert.convertRowColumnToRenderY(currentNodeRow, currentNodeColumn);
    final distance =  bottom - screenTop;
    nodesMaxZ = (distance ~/ tileHeight);
    if (nodesMaxZ > nodesGridTotalZMinusOne){
      nodesMaxZ = nodesGridTotalZMinusOne;
    }
    if (nodesMaxZ < 0){
      nodesMaxZ = 0;
    }

    while (GameConvert.convertRowColumnZToRenderY(currentNodeRow, currentNodeColumn, nodesMinZ) > screenBottom){
      nodesMinZ++;
      if (nodesMinZ >= GameState.nodesTotalZ){
        return renderOrderGrid.end();
      }
    }
  }

  static int get countLeftOffscreen {
    final x = GameConvert.convertRowColumnToRenderX(currentNodeRow, currentNodeColumn);
    if (Engine.screen.left < x) return 0;
    final diff = Engine.screen.left - x;
    return diff ~/ tileSize;
  }

  static double getRenderV3X(Vector3 v3) => getRenderX(v3.x, v3.y, v3.z);
  static double getRenderV3Y(Vector3 v3) => getRenderY(v3.x, v3.y, v3.z);

  static double getRenderX(double x, double y, double z) => (x - y) * 0.5;
  static double getRenderY(double x, double y, double z) => ((y + x) * 0.5) - z;

  static double getRenderYBouncing(Vector3 v3) => ((v3.y + v3.x) * 0.5) - v3.z + GameAnimation.animationFrameWaterHeight;

  static void renderTextV3(Vector3 v3, dynamic text, {double offsetY = 0}){
    renderText(
      text: text.toString(),
      x: GameRender.getRenderV3X(v3),
      y: GameRender.getRenderV3Y(v3) + offsetY,
    );
  }

  static void casteShadowDownV3(Vector3 vector3){
    if (vector3.z < nodeHeight) return;
    if (vector3.z >= GameState.nodesLengthZ) return;
    final nodeIndex = GameQueries.getGridNodeIndexV3(vector3);
    if (nodeIndex > GameState.nodesArea) {
      final nodeBelowIndex = nodeIndex - GameState.nodesArea;
      final nodeBelowOrientation = GameState.nodesOrientation[nodeBelowIndex];
      if (nodeBelowOrientation == NodeOrientation.Solid){
        final topRemainder = vector3.z % tileHeight;
        GameRender.renderShadow(vector3.x, vector3.y, vector3.z - topRemainder, scale: topRemainder > 0 ? (topRemainder / tileHeight) * 2 : 2.0);
      }
    }
  }

  static void renderWireFrameBlue(
      int z,
      int row,
      int column,
      ) {
    Engine.renderSprite(
      image: GameImages.gameobjects,
      dstX: getTileWorldX(row, column),
      dstY: getTileWorldY(row, column) - (z * tileHeight),
      srcX: 6944,
      srcY: 0,
      srcWidth: 48,
      srcHeight: 72,
      anchorY: 0.3334,
    );
    return;
  }

  static void renderWireFrameRed(int row, int column, int z) {
    Engine.renderSprite(
      image: GameImages.gameobjects,
      dstX: getTileWorldX(row, column),
      dstY: getTileWorldY(row, column) - (z * tileHeight),
      srcX: 6895,
      srcY: 0,
      srcWidth: 48,
      srcHeight: 72,
      anchorY: 0.3334,
    );
  }

  static void renderCharacterShadow(Character character, int frameLegs, int upperBodyDirection){
    if (GameState.outOfBoundsV3(character)) return;
    // find the nearest torch and move the shadow behind the character
    final characterNodeIndex = GameState.getNodeIndexV3(character);
    final initialSearchIndex = characterNodeIndex - GameState.nodesTotalColumns - 1; // shifts the selectIndex - 1 row and - 1 column
    var torchIndex = -1;

    for (var row = 0; row < 3; row++){
      for (var column = 0; column < 3; column++){
        final searchIndex = initialSearchIndex + (row * GameState.nodesTotalColumns) + column;
        if (GameState.nodesType[searchIndex] != NodeType.Torch) continue;
        torchIndex = searchIndex;
        break;
      }
    }

    // final angle = ang
    var angle = 0.0;
    var distance = 0.0;

    if (torchIndex != -1) {
      final torchRow = GameState.convertNodeIndexToRow(torchIndex);
      final torchColumn = GameState.convertNodeIndexToColumn(torchIndex);
      final torchPosX = torchRow * nodeSize + nodeSizeHalf;
      final torchPosY = torchColumn * nodeSize + nodeSizeHalf;
      angle = getAngleBetween(character.x, character.y, torchPosX, torchPosY);
      distance = min(20, distanceBetween(character.x, character.y, torchPosX, torchPosY) * 0.15);
    }

    final shadowX = character.x + getAdjacent(angle, distance);
    final shadowY = character.y + getOpposite(angle, distance);
    final shadowZ = character.z;

    Engine.renderSprite(
      image: GameImages.template_shadow,
      srcX: frameLegs * 64,
      srcY: upperBodyDirection * 64,
      srcWidth: 64,
      srcHeight: 64,
      dstX: GameRender.getRenderX(shadowX, shadowY, shadowZ),
      dstY: GameRender.getRenderY(shadowX, shadowY, shadowZ),
      scale: 0.75,
      color: GameState.getV3RenderColor(character),
      anchorY: 0.75,
    );
  }

  static void renderCharacterCustomShadow({
    required Character character,
    required int frame,
    required int direction,
    required ui.Image image,
  }){
    if (GameState.outOfBoundsV3(character)) return;
    // find the nearest torch and move the shadow behind the character
    final characterNodeIndex = GameState.getNodeIndexV3(character);
    final initialSearchIndex = characterNodeIndex - GameState.nodesTotalColumns - 1; // shifts the selectIndex - 1 row and - 1 column
    var torchIndex = -1;

    for (var row = 0; row < 3; row++){
      for (var column = 0; column < 3; column++){
        final searchIndex = initialSearchIndex + (row * GameState.nodesTotalColumns) + column;
        if (GameState.nodesType[searchIndex] != NodeType.Torch) continue;
        torchIndex = searchIndex;
        break;
      }
    }

    // final angle = ang
    var angle = 0.0;
    var distance = 0.0;

    if (torchIndex != -1) {
      final torchRow = GameState.convertNodeIndexToRow(torchIndex);
      final torchColumn = GameState.convertNodeIndexToColumn(torchIndex);
      final torchPosX = torchRow * nodeSize + nodeSizeHalf;
      final torchPosY = torchColumn * nodeSize + nodeSizeHalf;
      angle = getAngleBetween(character.x, character.y, torchPosX, torchPosY);
      distance = min(20, distanceBetween(character.x, character.y, torchPosX, torchPosY) * 0.15);
    }

    final shadowX = character.x + getAdjacent(angle, distance);
    final shadowY = character.y + getOpposite(angle, distance);
    final shadowZ = character.z;

    Engine.renderSprite(
      image: image,
      srcX: frame * 64,
      srcY: direction * 64,
      srcWidth: 64,
      srcHeight: 64,
      dstX: GameRender.getRenderX(shadowX, shadowY, shadowZ),
      dstY: GameRender.getRenderY(shadowX, shadowY, shadowZ),
      scale: 0.75,
      color: GameState.getV3RenderColor(character),
      anchorY: 0.75,
    );
  }

  static void renderProjectileFireball(Position position) =>
      Engine.renderSprite(
        image: GameImages.projectiles,
        dstX: position.x,
        dstY: position.y,
        srcY: ((position.x + position.y + Engine.paintFrame) % 6) * 23,
        srcX: 0,
        srcWidth: 18,
        srcHeight: 23,
        anchorY: 0.9,
      );
}

class RenderOrderCharacters extends RenderOrder {
  @override
  void renderFunction() => GameRender.renderCurrentCharacter();
  void updateFunction() => GameRender.updateCurrentCharacter();
  @override
  int getTotal() => GameState.totalCharacters;
}

class RenderOrderGameObjects extends RenderOrder {

  @override
  int getTotal() => GameState.totalGameObjects;

  @override
  void renderFunction() => GameRender.renderCurrentGameObject();

  @override
  void updateFunction() => GameRender.updateCurrentGameObject();

  @override
  void reset() {
    super.reset();
  }
}

class RenderOrderProjectiles extends RenderOrder {
  @override
  void renderFunction() => GameRender.renderCurrentProjectile();

  @override
  void updateFunction() => GameRender.updateCurrentProjectile();

  @override
  int getTotal() {
    return GameState.totalProjectiles;
  }
}

class RenderOrderParticle extends RenderOrder {

  @override
  void renderFunction() => GameRender.renderCurrentParticle();

  @override
  void updateFunction() => GameRender.updateCurrentParticle();
  @override
  int getTotal() => GameState.totalActiveParticles;

  @override
  void reset() {
    GameSort.sortParticles();
    super.reset();
  }
}

int get renderNodeShade => GameState.nodesShade[GameRender.currentNodeIndex];
int get renderNodeOrientation => GameState.nodesOrientation[GameRender.currentNodeIndex];
int get renderNodeColor => GameState.colorShades[renderNodeShade];
int get renderNodeWind => GameState.nodesWind[renderNodeShade];
int get renderNodeBelowIndex => GameRender.currentNodeIndex + GameState.nodesArea;

int get renderNodeBelowShade {
  if (renderNodeBelowIndex < 0) return GameState.ambientShade.value;
  if (renderNodeBelowIndex >= GameState.nodesTotal) return GameState.ambientShade.value;
  return GameState.nodesShade[renderNodeBelowIndex];
}

int get renderNodeBelowColor => GameState.colorShades[renderNodeBelowShade];

int getRenderLayerColor(int layers) =>
    GameState.colorShades[getRenderLayerShade(layers)];

int getRenderLayerShade(int layers){
   final index = GameRender.currentNodeIndex + (layers * GameState.nodesArea);
   if (index < 0) return GameState.ambientShade.value;
   if (index >= GameState.nodesTotal) return GameState.ambientShade.value;
   return GameState.nodesShade[index];
}

class RenderOrderNodes extends RenderOrder {

  @override
  void renderFunction() => GameRender.renderCurrentNodeLine();
  @override
  void updateFunction() => GameRender.nodesUpdateFunction();
  @override
  void reset() => GameRender.resetNodes();
  @override
  int getTotal() {
    return GameState.nodesTotalZ * GameState.nodesTotalRows * GameState.nodesTotalColumns;
  }
}

abstract class RenderOrder {
  var _index = 0;
  var total = 0;
  var order = 0.0;
  var orderZ = 0;
  var remaining = true;

  void renderFunction();
  void updateFunction();
  int getTotal();

  int get index => _index;

  void reset(){
    total = getTotal();
    _index = 0;
    remaining = total > 0;
    if (remaining){
      updateFunction();
    }
  }

  @override
  String toString(){
    return "$order: $order, orderZ: $orderZ, index: $_index, total: $total";
  }

  RenderOrder compare(RenderOrder that){
    // if (!remaining) return that;
    // if (!that.remaining) return this;
    if (order < that.order) return this;
    if (orderZ < that.orderZ) return this;
    return that;
  }

  void set index(int value){
    _index = value;
    remaining = _index < total;
  }

  void end(){
     index = total;
     remaining = false;
  }

  void renderNext() {
    if (!remaining) return;
    // assert(remaining);
    renderFunction();
    _index = (_index + 1);
    remaining = _index < total;
    if (remaining) {
      updateFunction();
    }
  }
}

int getRenderRow(int row, int z){
  return row - (z ~/ 2);
}

int getRenderColumn(int column, int z){
  return column - (z ~/ 2);
}

void renderTotalIndex(Vector3 position){
  renderText(text: GameRender.totalIndex.toString(), x: position.renderX, y: position.renderY - 100);
}