import 'dart:math';
import 'dart:ui' as ui;

import 'package:gamestream_flutter/isometric/nodes/render/atlas_src_gameobjects.dart';
import 'package:gamestream_flutter/isometric/render/highlight_character_nearest_mouse.dart';
import 'package:gamestream_flutter/isometric/render/render_floating_texts.dart';

import 'library.dart';

int capIndex(List<int> values, int index){
   return index < values.length ? values[index] : values.last;
}

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
  static var indexRow = 0;
  static var indexColumn = 0;
  static var indexZ = 0;

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

  static double get currentNodeRenderX => (currentNodeRow - currentNodeColumn) * Node_Size_Half;
  static double get currentNodeRenderY => GameConvert.rowColumnZToRenderY(currentNodeRow, currentNodeColumn, currentNodeZ);

  static int get currentNodeShade => GameNodes.nodesShade[currentNodeIndex];
  static int get currentNodeColor => (currentNodeVisibilityOpaque ? GameLighting.values : GameLighting.values_transparent)[currentNodeShade];
  static int get currentNodeOrientation => GameNodes.nodesOrientation[currentNodeIndex];
  static int get currentNodeVisibility => GameNodes.nodesVisible[currentNodeIndex];
  static int get currentNodeWind => GameNodes.nodesWind[currentNodeIndex];

  static bool get currentNodeVisible => currentNodeVisibility == Visibility.Invisible;
  static bool get currentNodeInvisible => currentNodeVisibility == Visibility.Invisible;
  static bool get currentNodeVisibilityOpaque => GameNodes.nodesVisible[currentNodeIndex] == Visibility.Opaque;
  static bool get currentNodeVariation => GameNodes.nodesVariation[currentNodeIndex];

  static final bufferClr = Engine.bufferClr;
  static final bufferSrc = Engine.bufferSrc;
  static final bufferDst = Engine.bufferDst;
  static final atlas = GameImages.atlas_nodes;

  static void renderCurrentParticle() =>
    renderParticle(currentParticle);

  static void renderCurrentProjectile() =>
    RenderProjectiles.renderProjectile(currentRenderProjectile);

  static void renderCurrentGameObject() =>
    renderGameObject(currentRenderGameObject);

  static void updateCurrentParticle(){
    currentParticle = ClientState.particles[renderOrderParticle.index];
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
    RenderCharacter.renderCharacter(currentRenderCharacter);
  }

  static void updateCurrentCharacter() {
    currentRenderCharacter = GameState.characters[renderOrderCharacters.index];
    renderOrderCharacters.order = currentRenderCharacter.renderOrder;
    renderOrderCharacters.orderZ = currentRenderCharacter.indexZ;
  }

  static void nodesTrimLeft(){
    final offscreen = countLeftOffscreen;
    if (offscreen <= 0) return;

    if (currentNodeColumn - offscreen < 0){
      nodesSetStart();
      return;
    }
    if (currentNodeRow + offscreen >= GameState.nodesTotalRows){
      nodesSetStart();
      return;
    }

    currentNodeColumn -= offscreen;
    currentNodeRow += offscreen;

    while (currentNodeRenderX < screenLeft && currentNodeColumn > 0 && currentNodeRow < GameState.nodesTotalRows){
      currentNodeRow++;
      currentNodeColumn--;
    }
    nodesSetStart();
  }

  static void nodesSetStart(){
    // nodesStartRow = min(currentNodeRow, GameState.nodesTotalRows);
    nodesStartRow = clamp(currentNodeRow, 0, GameState.nodesTotalRows - 1);
    nodeStartColumn = clamp(currentNodeColumn, 0, GameState.nodesTotalColumns - 1);

    assert (nodesStartRow >= 0);
    assert (nodeStartColumn >= 0);
    assert (nodesStartRow < GameState.nodesTotalRows);
    assert (nodeStartColumn < GameState.nodesTotalColumns);
  }

  static void nodesShiftIndexDown(){

    currentNodeColumn = currentNodeRow + currentNodeColumn + 1;
    currentNodeRow = 0;
    if (currentNodeColumn < GameState.nodesTotalColumns) {
      nodesSetStart();
      return;
    }

    if (currentNodeColumn - nodesGridTotalColumnsMinusOne >= GameState.nodesTotalRows){
      renderOrderGrid.remaining = false;
      return;
    }

    currentNodeRow = currentNodeColumn - nodesGridTotalColumnsMinusOne;
    currentNodeColumn = nodesGridTotalColumnsMinusOne;
    currentNodeDstY = ((currentNodeRow + currentNodeColumn) * Node_Size_Half) - (currentNodeZ * Node_Height);
    nodesSetStart();
  }

  // ACTIONS

  static void renderParticle(Particle particle) {
    assert (particle.active);
    if (particle.delay > 0) return;
    switch (particle.type) {
      case ParticleType.Water_Drop:
        Engine.renderSprite(
          image: GameImages.atlas_gameobjects,
          dstX: GameConvert.convertV3ToRenderX(particle),
          dstY: GameConvert.convertV3ToRenderY(particle),
          srcX: 0.0,
          srcY: 40,
          srcWidth: 4,
          srcHeight: 4,
          color: GameState.getV3RenderColor(particle),
        );
        break;
      case ParticleType.Blood:
        casteShadowDownV3(particle);
        Engine.renderSprite(
          image: GameImages.atlas_gameobjects,
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: AtlasParticleX.Blood,
          srcY: AtlasParticleY.Blood,
          srcWidth: 8,
          srcHeight: 8,
          color: GameState.getV3RenderColor(particle),
        );
        break;
      case ParticleType.Bubble:
        if (particle.duration > 26) {
          particle.deactivate();
          break;
        }
        Engine.renderSprite(
          image: GameImages.atlas_gameobjects,
          dstX: GameConvert.convertV3ToRenderX(particle),
          dstY: GameConvert.convertV3ToRenderY(particle),
          srcX: 0.0,
          srcY: 32,
          srcWidth: 8,
          srcHeight: 8,
          color: GameState.getV3RenderColor(particle),
        );
        break;
      case ParticleType.Bubble_Small:
        Engine.renderSprite(
          image: GameImages.atlas_gameobjects,
          dstX: GameConvert.convertV3ToRenderX(particle),
          dstY: GameConvert.convertV3ToRenderY(particle),
          srcX: 0.0,
          srcY: 32,
          srcWidth: 4,
          srcHeight: 4,
          color: GameState.getV3RenderColor(particle),
        );
        break;
      case ParticleType.Bullet_Ring:
        Engine.renderSprite(
          image: GameImages.atlas_gameobjects,
          dstX: GameConvert.convertV3ToRenderX(particle),
          dstY: GameConvert.convertV3ToRenderY(particle),
          srcX: 0.0,
          srcY: 32,
          srcWidth: 4,
          srcHeight: 4,
          color: GameState.getV3RenderColor(particle),
        );
        break;
      case ParticleType.Smoke:
      if (particle.frame >= 24) {
        particle.deactivate();
        return;
      }
        final frame = particle.frame <= 11 ? particle.frame : 23 - particle.frame;

        Engine.renderSprite(
          image: GameImages.particles,
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 432,
          srcY: 32.0 * frame,
          srcWidth: 32,
          srcHeight: 32,
          scale: particle.scale,
        );
        break;
      case ParticleType.Block_Wood:
        Engine.renderSprite(
          image: GameImages.atlas_gameobjects,
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
          image: GameImages.atlas_gameobjects,
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
          image: GameImages.atlas_gameobjects,
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
          srcX: 0,
          srcY: 32.0 * particle.frame,
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
      case ParticleType.Myst:
        const size = 48.0;
        final shade = GameState.getV3RenderShade(particle);
        if (shade >= 5) return;
        Engine.renderSprite(
          image: GameImages.particles,
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 480 ,
          srcY: shade * size,
          srcWidth: size,
          srcHeight: size,
          scale: particle.scale,
          color: 1,
        );
        break;
      case ParticleType.Orb_Shard:
        const size = 16.0;
        Engine.renderSprite(
          image: GameImages.atlas_gameobjects,
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

      case ParticleType.Character_Animation_Dog_Death:
        final frame = capIndex(const [1, 1, 6, 6, 7], particle.frame);

        Engine.renderSprite(
          image: GameImages.character_dog,
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 64.0 * frame,
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
        Engine.renderSpriteRotated(
          image: GameImages.particles,
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 357,
          srcY: 1 + particle.frame * size,
          srcWidth: size,
          srcHeight: size,
          scale: particle.scale,
          rotation: particle.rotation,
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

    if (ItemType.isTypeGameObject(gameObject.type)) {
      Engine.renderSprite(
        image: GameImages.atlas_gameobjects,
        dstX: GameConvert.convertV3ToRenderX(gameObject),
        dstY: GameConvert.convertV3ToRenderY(gameObject),
        srcX: AtlasItems.getSrcX(gameObject.type),
        srcY: AtlasItems.getSrcY(gameObject.type),
        srcWidth: AtlasItems.getSrcWidth(gameObject.type),
        srcHeight: AtlasItems.getSrcHeight(gameObject.type),
        color: GameState.getV3RenderColor(gameObject),
      );
      return;
    }

    if (ItemType.isTypeCollectable(gameObject.type)) {
      renderBouncingGameObjectShadow(gameObject);
      Engine.renderSprite(
        image: GameImages.atlas_items,
        dstX: GameConvert.convertV3ToRenderX(gameObject),
        dstY: getRenderYBouncing(gameObject),
        srcX: AtlasItems.getSrcX(gameObject.type),
        srcY: AtlasItems.getSrcY(gameObject.type),
        srcWidth: AtlasItems.size,
        srcHeight: AtlasItems.size,
        color: GameState.getV3RenderColor(gameObject),
      );
      return;
    }

    throw Exception('could not render gameobject type ${gameObject.type}');
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
        x: GamePlayer.aimTargetPosition.renderX,
        y: GamePlayer.aimTargetPosition.renderY - 55);
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
        image: GameImages.atlas_gameobjects,
        dstX: (x - y) * 0.5,
        dstY: ((y + x) * 0.5) - z,
        srcX: 0,
        srcY: 32,
        srcWidth: 8,
        srcHeight: 8,
        scale: scale,
      );

  static void renderCurrentNodeLine() {
    Engine.bufferImage = GameImages.atlas_nodes;
    while (
        currentNodeColumn >= 0 &&
        currentNodeRow <= nodesRowsMax &&
        currentNodeDstX <= screenRight
    ){
      currentNodeType = GameNodes.nodesType[currentNodeIndex];
      if (currentNodeType != NodeType.Empty){
        renderNodeAt();
      }
      if (currentNodeRow + 1 > nodesRowsMax) return;
      currentNodeRow++;
      currentNodeColumn--;
      currentNodeIndex += nodesGridTotalColumnsMinusOne;
      currentNodeDstX += GameConstants.Sprite_Width;
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

      assert (currentNodeColumn >= 0);
      assert (currentNodeRow >= 0);
      assert (currentNodeRow < GameState.nodesTotalRows);
      assert (currentNodeColumn < GameState.nodesTotalColumns);

      nodesTrimLeft();

      while (currentNodeRenderY > screenBottom) {
        currentNodeZ++;
        if (currentNodeZ > nodesMaxZ) {
          renderOrderGrid.remaining = false;
          return;
        }
      }
    } else {
      assert (nodesStartRow < GameState.nodesTotalRows);
      assert (currentNodeColumn < GameState.nodesTotalColumns);
      currentNodeRow = nodesStartRow;
      currentNodeColumn = nodeStartColumn;
    }

    // currentNodeZ = clamp(currentNodeZ, 0, GameState.nodesTotalZ - 1);
    // currentNodeRow = clamp(currentNodeRow, 0, GameState.nodesTotalRows - 1);
    // currentNodeColumn = clamp(currentNodeColumn, 0, GameState.nodesTotalColumns - 1);

    currentNodeIndex = (currentNodeZ * GameNodes.nodesArea) + (currentNodeRow * GameState.nodesTotalColumns) + currentNodeColumn;
    assert (currentNodeZ >= 0);
    assert (currentNodeRow >= 0);
    assert (currentNodeColumn >= 0);
    assert (currentNodeIndex >= 0);
    assert (currentNodeZ < GameState.nodesTotalZ);
    assert (currentNodeRow < GameState.nodesTotalRows);
    assert (currentNodeColumn < GameState.nodesTotalColumns);
    assert (currentNodeIndex < GameNodes.nodesTotal);
    currentNodeDstX = (currentNodeRow - currentNodeColumn) * Node_Size_Half;
    currentNodeDstY = ((currentNodeRow + currentNodeColumn) * Node_Size_Half) - (currentNodeZ * Node_Height);
    currentNodeType = GameNodes.nodesType[currentNodeIndex];
    renderOrderGrid.order = ((currentNodeRow + currentNodeColumn) * Node_Size) + Node_Size_Half;
    renderOrderGrid.orderZ = currentNodeZ;
  }

  static void showIndexFinal(int index){
    showIndex(index + GameNodes.nodesArea);
    showIndex(index + GameNodes.nodesArea + GameNodes.nodesArea);
  }
  
  static void showIndex(int index) {
    if (index < 0) return;
    if (index >= GameNodes.nodesTotal) return;
    indexZ = GameState.convertNodeIndexToZ(index);
    indexRow = GameState.convertNodeIndexToRow(index);
    indexColumn = GameState.convertNodeIndexToColumn(index);
    const radius = 3;
    for (var r = -radius; r <= radius + 2; r++) {
      final row = indexRow + r;
      if (row < 0) continue;
      if (row >= GameState.nodesTotalRows) break;
      for (var c = -radius; c <= radius + 2; c++) {
        final column = indexColumn + c;
        if (column < 0) continue;
        if (column >= GameState.nodesTotalColumns) break;
        nodesHideIndex(indexZ, row, column, indexRow, indexColumn);
      }
    }
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
    playerZ = GamePlayer.position.indexZ;
    playerRow = GamePlayer.position.indexRow;
    playerColumn = GamePlayer.position.indexColumn;
    nodesPlayerColumnRow = playerRow + playerColumn;
    playerRenderRow = playerRow - (GamePlayer.position.indexZ ~/ 2);
    playerRenderColumn = playerColumn - (GamePlayer.position.indexZ ~/ 2);
    nodesPlayerUnderRoof = GameState.gridIsUnderSomething(playerZ, playerRow, playerColumn);


    screenRight = Engine.screen.right + Node_Size;
    screenLeft = Engine.screen.left - Node_Size;
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

    currentNodeDstX = (currentNodeRow - currentNodeColumn) * Node_Size_Half;
    currentNodeDstY = ((currentNodeRow + currentNodeColumn) * Node_Size_Half) - (currentNodeZ * Node_Height);
    currentNodeIndex = (currentNodeZ * GameNodes.nodesArea) + (currentNodeRow * GameState.nodesTotalColumns) + currentNodeColumn;
    currentNodeType = GameNodes.nodesType[currentNodeIndex];

    while (GameNodes.visibleIndex > 0) {
      GameNodes.nodesVisible[GameNodes.nodesVisibleIndex[GameNodes.visibleIndex]] = Visibility.Opaque;
      GameNodes.visibleIndex--;
    }
    GameNodes.nodesVisible[GameNodes.nodesVisibleIndex[0]] = Visibility.Opaque;

    showIndexPlayer();
    showIndexMouse();

    renderOrderGrid.total = renderOrderGrid.getTotal();
    renderOrderGrid.index = 0;
    renderOrderGrid.remaining = renderOrderGrid.total > 0;
    GameState.refreshDynamicLightGrid();
    GameState.applyEmissions();

    if (GameState.editMode){
      GameNodes.applyEmissionDynamic(
        index: GameEditor.nodeSelectedIndex.value,
        maxBrightness: Shade.Very_Bright,
      );
    }

    highlightCharacterNearMouse();
  }

  static void showIndexPlayer() {
    if (GamePlayer.position.outOfBounds) return;
    showIndexFinal(GamePlayer.position.nodeIndex);
  }

  static void showIndexMouse(){
    var x1 = GamePlayer.position.x;
    var y1 = GamePlayer.position.y;
    final z = GamePlayer.position.z + Node_Height_Half;

    if (!GameQueries.inBounds(x1, y1, z)) return;
    if (!GameQueries.inBounds(GameMouse.positionX, GameMouse.positionY, GameMouse.positionZ)) return;

    final mouseAngle = GameMouse.playerAngle;
    final mouseDistance = min(200.0, GameMouse.playerDistance);
    final jumps = mouseDistance ~/ Node_Height_Half;
    final tX = Engine.calculateAdjacent(mouseAngle, Node_Height_Half);
    final tY = Engine.calculateOpposite(mouseAngle, Node_Height_Half);
    var i1 = GamePlayer.position.nodeIndex;

    for (var i = 0; i < jumps; i++) {
      final x2 = x1 - tX;
      final y2 = y1 - tY;
      final i2 = GameQueries.getNodeIndex(x2, y2, z);
      if (!NodeType.isTransient(GameNodes.nodesType[i2])) break;
      x1 = x2;
      y1 = y2;
      i1 = i2;
    }
    showIndexFinal(i1);
  }

  static void nodesHideIndex(int z, int row, int column, int initRow, int initColumn){

    var index = (z * GameNodes.nodesArea) + (row * GameState.nodesTotalColumns) + column;
    while (index < GameNodes.nodesTotal) {
      if (NodeType.isRainOrEmpty(GameNodes.nodesType[index])) {
        row += 1;
        column += 1;
        z += 2;
        index = (z * GameNodes.nodesArea) + (row * GameState.nodesTotalColumns) + column;
        continue;
      }

      final distance = (z - GamePlayer.indexZ).abs();
     final transparent = distance <= 2;

      if (column >= initColumn && row >= initRow) {

        if (transparent){
          GameNodes.addTransparentIndex(index);
        } else {
          GameNodes.addInvisibleIndex(index);
        }

        row += 1;
        column += 1;
        z += 2;
        index = (z * GameNodes.nodesArea) + (row * GameState.nodesTotalColumns) + column;
        continue;
      }
      var nodeIndexBelow = index - GameNodes.nodesArea;

      if (nodeIndexBelow < 0) continue;

      if (GameNodes.nodesType[nodeIndexBelow] == NodeType.Empty) {

        if (transparent){
          GameNodes.addTransparentIndex(index);
        } else {
          GameNodes.addInvisibleIndex(index);
        }

        row += 1;
        column += 1;
        z += 2;
        index = (z * GameNodes.nodesArea) + (row * GameState.nodesTotalColumns) + column;
        continue;
      }

      if (GameNodes.nodesVisible[nodeIndexBelow] == Visibility.Invisible) {

        if (transparent){
          GameNodes.addTransparentIndex(index);
        } else {
          GameNodes.addInvisibleIndex(index);
        }

        row += 1;
        column += 1;
        z += 2;
        index = (z * GameNodes.nodesArea) + (row * GameState.nodesTotalColumns) + column;
        continue;
      }
      row += 1;
      column += 1;
      z += 2;
      index = (z * GameNodes.nodesArea) + (row * GameState.nodesTotalColumns) + column;
    }
  }

  static void nodesRevealRaycast(int z, int row, int column){
    if (!GameQueries.isInboundZRC(z, row, column)) return;

    for (; z < GameState.nodesTotalZ; z += 2){
      row++;
      column++;
      if (row >= GameState.nodesTotalRows) return;
      if (column >= GameState.nodesTotalColumns) return;
      GameNodes.nodesVisible[GameState.getNodeIndexZRC(z, row, column)] = Visibility.Invisible;;
      if (z < GameState.nodesTotalZ - 2){
        GameNodes.nodesVisible[GameState.getNodeIndexZRC(z + 1, row, column)] = Visibility.Invisible;;
      }
    }
  }

  static void nodesRevealAbove(int z, int row, int column){
    for (; z < GameState.nodesTotalZ; z++){
      GameNodes.nodesVisible[GameState.getNodeIndexZRC(z, row, column)] = Visibility.Invisible;;
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
    final bottom = GameConvert.rowColumnToRenderY(currentNodeRow, currentNodeColumn);
    final distance =  bottom - screenTop;
    nodesMaxZ = (distance ~/ Node_Height);
    if (nodesMaxZ > nodesGridTotalZMinusOne){
      nodesMaxZ = nodesGridTotalZMinusOne;
    }
    if (nodesMaxZ < 0){
      nodesMaxZ = 0;
    }

    while (GameConvert.rowColumnZToRenderY(currentNodeRow, currentNodeColumn, nodesMinZ) > screenBottom){
      nodesMinZ++;
      if (nodesMinZ >= GameState.nodesTotalZ){
        return renderOrderGrid.end();
      }
    }
  }

  static int get countLeftOffscreen {
    final x = GameConvert.rowColumnToRenderX(currentNodeRow, currentNodeColumn);
    if (Engine.screen.left < x) return 0;
    final diff = Engine.screen.left - x;
    return diff ~/ Node_Size;
  }

  static double getRenderYBouncing(Vector3 v3) => ((v3.y + v3.x) * 0.5) - v3.z + GameAnimation.animationFrameWaterHeight;

  static void renderTextV3(Vector3 v3, dynamic text, {double offsetY = 0}){
    renderText(
      text: text.toString(),
      x: GameConvert.convertV3ToRenderX(v3),
      y: GameConvert.convertV3ToRenderY(v3) + offsetY,
    );
  }

  static void casteShadowDownV3(Vector3 vector3){
    if (vector3.z < Node_Height) return;
    if (vector3.z >= GameState.nodesLengthZ) return;
    final nodeIndex = GameQueries.getNodeIndexV3(vector3);
    if (nodeIndex > GameNodes.nodesArea) {
      final nodeBelowIndex = nodeIndex - GameNodes.nodesArea;
      final nodeBelowOrientation = GameNodes.nodesOrientation[nodeBelowIndex];
      if (nodeBelowOrientation == NodeOrientation.Solid){
        final topRemainder = vector3.z % Node_Height;
        GameRender.renderShadow(vector3.x, vector3.y, vector3.z - topRemainder, scale: topRemainder > 0 ? (topRemainder / Node_Height) * 2 : 2.0);
      }
    }
  }

  static void renderWireFrameBlue(
      int z,
      int row,
      int column,
      ) {
    Engine.renderSprite(
      image: GameImages.atlas_nodes,
      dstX: GameConvert.rowColumnToRenderX(row, column),
      dstY: GameConvert.rowColumnZToRenderY(row, column,z),
      srcX: AtlasNodeX.Wireframe_Blue,
      srcY: AtlasNodeY.Wireframe_Blue,
      srcWidth: GameConstants.Sprite_Width,
      srcHeight: GameConstants.Sprite_Height,
      anchorY: GameConstants.Sprite_Anchor_Y,
    );
    return;
  }

  static void renderWireFrameRed(int row, int column, int z) {
    Engine.renderSprite(
      image: GameImages.atlas_nodes,
      dstX: GameConvert.rowColumnToRenderX(row, column),
      dstY: GameConvert.rowColumnZToRenderY(row, column,z),
      srcX: AtlasNodeX.Wireframe_Red,
      srcY: AtlasNodeY.Wireframe_Red,
      srcWidth: GameConstants.Sprite_Width,
      srcHeight: GameConstants.Sprite_Height,
      anchorY: GameConstants.Sprite_Anchor_Y,
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
        if (GameNodes.nodesType[searchIndex] != NodeType.Torch) continue;
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
      final torchPosX = torchRow * Node_Size + Node_Size_Half;
      final torchPosY = torchColumn * Node_Size + Node_Size_Half;
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
      dstX: GameConvert.getRenderX(shadowX, shadowY, shadowZ),
      dstY: GameConvert.getRenderY(shadowX, shadowY, shadowZ),
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
        if (GameNodes.nodesType[searchIndex] != NodeType.Torch) continue;
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
      final torchPosX = torchRow * Node_Size + Node_Size_Half;
      final torchPosY = torchColumn * Node_Size + Node_Size_Half;
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
      dstX: GameConvert.getRenderX(shadowX, shadowY, shadowZ),
      dstY: GameConvert.getRenderY(shadowX, shadowY, shadowZ),
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

  static void canvasRenderCursorHand(ui.Canvas canvas){
    Engine.renderExternalCanvas(
        canvas: canvas,
        image: GameImages.atlas_icons,
        srcX: 0,
        srcY: 256,
        srcWidth: 64,
        srcHeight: 64,
        dstX: GameIO.getCursorScreenX(),
        dstY: GameIO.getCursorScreenY(),
        scale: 0.5,
    );
  }

  static void canvasRenderCursorTalk(ui.Canvas canvas){
    Engine.renderExternalCanvas(
      canvas: canvas,
      image: GameImages.atlas_icons,
      srcX: 0,
      srcY: 320,
      srcWidth: 64,
      srcHeight: 64,
      dstX: GameIO.getCursorScreenX(),
      dstY: GameIO.getCursorScreenY(),
      scale: 0.5,
    );
  }

  static void canvasRenderCursorCrossHair(ui.Canvas canvas, double range){
    const srcX = 0;
    const srcY = 192;
    const offset = 18.0 * 1.5;
    Engine.renderExternalCanvas(
        canvas: canvas,
        image: GameImages.atlas_icons,
        srcX: srcX + 29,
        srcY: srcY + 0,
        srcWidth: 6,
        srcHeight: 22,
        dstX: GameIO.getCursorScreenX(),
        dstY: GameIO.getCursorScreenY() - range - offset,
        anchorY: 1.0
    );
    Engine.renderExternalCanvas(
        canvas: canvas,
        image: GameImages.atlas_icons,
        srcX: srcX + 29,
        srcY: srcY + 0,
        srcWidth: 6,
        srcHeight: 22,
        dstX: GameIO.getCursorScreenX(),
        dstY: GameIO.getCursorScreenY() + range - offset,
        anchorY: 0.0
    );
    Engine.renderExternalCanvas(
        canvas: canvas,
        image: GameImages.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: GameIO.getCursorScreenX() - range,
        dstY: GameIO.getCursorScreenY() - offset,
        anchorX: 1.0
    );
    Engine.renderExternalCanvas(
        canvas: canvas,
        image: GameImages.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: GameIO.getCursorScreenX() + range,
        dstY: GameIO.getCursorScreenY() - offset,
        anchorX: 0.0
    );
  }

  static void canvasRenderCursorCrossHairRed(ui.Canvas canvas, double range){
    const srcX = 0;
    const srcY = 384;
    const offset = 18.0 * 1.5;
    Engine.renderExternalCanvas(
        canvas: canvas,
        image: GameImages.atlas_icons,
        srcX: srcX + 29,
        srcY: srcY + 0,
        srcWidth: 6,
        srcHeight: 22,
        dstX: GameIO.getCursorScreenX(),
        dstY: GameIO.getCursorScreenY() - range - offset,
        anchorY: 1.0
    );
    Engine.renderExternalCanvas(
        canvas: canvas,
        image: GameImages.atlas_icons,
        srcX: srcX + 29,
        srcY: srcY + 0,
        srcWidth: 6,
        srcHeight: 22,
        dstX: GameIO.getCursorScreenX(),
        dstY: GameIO.getCursorScreenY() + range - offset,
        anchorY: 0.0
    );
    Engine.renderExternalCanvas(
        canvas: canvas,
        image: GameImages.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: GameIO.getCursorScreenX() - range,
        dstY: GameIO.getCursorScreenY() - offset,
        anchorX: 1.0
    );
    Engine.renderExternalCanvas(
        canvas: canvas,
        image: GameImages.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: GameIO.getCursorScreenX() + range,
        dstY: GameIO.getCursorScreenY() - offset,
        anchorX: 0.0
    );
  }

  static void renderCircle32(double x, double y, double z){
    Engine.renderSprite(
      image: GameImages.atlas_gameobjects,
      srcX: AtlasGameObjects.Circle32_X,
      srcY: AtlasGameObjects.Circle32_Y,
      srcWidth: 32,
      srcHeight: 32,
      dstX: GameConvert.getRenderX(x, y, z),
      dstY: GameConvert.getRenderY(x, y, z),
    );
  }

  static void renderNodeTorch(){
    if (!ClientState.torchesIgnited.value) {
      Engine.renderSprite(
        image: atlas,
        srcX: AtlasNodeX.Torch,
        srcY: AtlasNodeY.Torch,
        srcWidth: AtlasNode.Width_Torch,
        srcHeight: AtlasNode.Height_Torch,
        dstX: GameRender.currentNodeDstX,
        dstY: GameRender.currentNodeDstY,
        anchorY: AtlasNodeAnchorY.Torch,
        color: GameRender.currentNodeColor,
      );
      return;
    }
    if (renderNodeWind == WindType.Calm){
      Engine.renderSprite(
        image: atlas,
        srcX: AtlasNodeX.Torch,
        srcY: AtlasNodeY.Torch + AtlasNode.Height_Torch + (((GameRender.currentNodeRow + (GameAnimation.animationFrame)) % 6) * AtlasNode.Height_Torch), // TODO Optimize
        srcWidth: AtlasNode.Width_Torch,
        srcHeight: AtlasNode.Height_Torch,
        dstX: GameRender.currentNodeDstX,
        dstY: GameRender.currentNodeDstY,
        anchorY: AtlasNodeAnchorY.Torch,
        color: GameRender.currentNodeColor,
      );
      return;
    }
    Engine.renderSprite(
      image: atlas,
      srcX: AtlasNode.X_Torch_Windy,
      srcY: AtlasNode.Y_Torch_Windy + AtlasNode.Height_Torch + (((GameRender.currentNodeRow + (GameAnimation.animationFrame)) % 6) * AtlasNode.Height_Torch), // TODO Optimize
      srcWidth: AtlasNode.Width_Torch,
      srcHeight: AtlasNode.Height_Torch,
      dstX: GameRender.currentNodeDstX,
      dstY: GameRender.currentNodeDstY,
      anchorY: AtlasNodeAnchorY.Torch,
      color: GameRender.currentNodeColor,
    );
    return;
  }

  static void renderNodeWater() =>
      Engine.renderSprite(
        image: atlas,
        srcX: AtlasNodeX.Water,
        srcY: AtlasNodeY.Water + (((GameAnimation.animationFrameWater + ((GameRender.currentNodeRow + GameRender.currentNodeColumn) * 3)) % 10) * 72.0), // TODO Optimize
        srcWidth: GameConstants.Sprite_Width,
        srcHeight: GameConstants.Sprite_Height,
        dstX: GameRender.currentNodeDstX,
        dstY: GameRender.currentNodeDstY + GameAnimation.animationFrameWaterHeight + 14,
        anchorY: 0.3334,
        color: renderNodeColor,
      );

  static void renderStandardNode({
    required double srcX,
    required double srcY,
  }){
    GameRender.onscreenNodes++;
    final f = Engine.bufferIndex * 4;
    bufferClr[Engine.bufferIndex] = GameRender.currentNodeVisibility == Visibility.Opaque ? 1 : GameLighting.Transparent;
    bufferSrc[f] = srcX;
    bufferSrc[f + 1] = srcY;
    bufferSrc[f + 2] = srcX + GameConstants.Sprite_Width;
    bufferSrc[f + 3] = srcY + GameConstants.Sprite_Height;
    bufferDst[f] = 1.0; // scale
    bufferDst[f + 1] = 0;
    bufferDst[f + 2] = GameRender.currentNodeDstX - (GameConstants.Sprite_Width_Half);
    bufferDst[f + 3] = GameRender.currentNodeDstY - (GameConstants.Sprite_Height_Third);
    Engine.incrementBufferIndex();
  }

  static void renderStandardNodeShaded({
    required double srcX,
    required double srcY,
  }){
    GameRender.onscreenNodes++;
    final f = Engine.bufferIndex * 4;
    bufferClr[Engine.bufferIndex] = GameRender.currentNodeVisibility == Visibility.Opaque ? GameRender.currentNodeColor : GameLighting.Transparent;
    bufferSrc[f] = srcX;
    bufferSrc[f + 1] = srcY;
    bufferSrc[f + 2] = srcX + GameConstants.Sprite_Width;
    bufferSrc[f + 3] = srcY + GameConstants.Sprite_Height;
    bufferDst[f] = 1.0; // scale
    bufferDst[f + 1] = 0;
    bufferDst[f + 2] = GameRender.currentNodeDstX - (GameConstants.Sprite_Width_Half);
    bufferDst[f + 3] = GameRender.currentNodeDstY - (GameConstants.Sprite_Height_Third);
    Engine.incrementBufferIndex();
  }

  static void renderNodeShadedOffset({
    required double srcX,
    required double srcY,
    required double offsetX,
    required double offsetY,
  }){
    GameRender.onscreenNodes++;
    final f = Engine.bufferIndex * 4;
    bufferClr[Engine.bufferIndex] = GameRender.currentNodeColor;
    bufferSrc[f] = srcX;
    bufferSrc[f + 1] = srcY;
    bufferSrc[f + 2] = srcX + GameConstants.Sprite_Width;
    bufferSrc[f + 3] = srcY + GameConstants.Sprite_Height;
    bufferDst[f] = 1.0; // scale
    bufferDst[f + 1] = 0;
    bufferDst[f + 2] = GameRender.currentNodeDstX - (GameConstants.Sprite_Width_Half) + offsetX;
    bufferDst[f + 3] = GameRender.currentNodeDstY - (GameConstants.Sprite_Height_Third) + offsetY;
    Engine.incrementBufferIndex();
  }


  static void renderStandardNodeHalfEastOld({
    required double srcX,
    required double srcY,
    int color = 1,
  }){
    GameRender.onscreenNodes++;
    Engine.renderSprite(
      image: atlas,
      srcX: srcX,
      srcY: srcY,
      srcWidth: GameConstants.Sprite_Width,
      srcHeight: GameConstants.Sprite_Height,
      dstX: GameRender.currentNodeDstX + 17,
      dstY: GameRender.currentNodeDstY - 17,
      anchorY: GameConstants.Sprite_Anchor_Y,
      color: color,
    );
  }

  static void renderStandardNodeHalfNorthOld({
    required double srcX,
    required double srcY,
    int color = 1,
  }){
    GameRender.onscreenNodes++;
    Engine.renderSprite(
      image: atlas,
      srcX: srcX,
      srcY: srcY,
      srcWidth: GameConstants.Sprite_Width,
      srcHeight: GameConstants.Sprite_Height,
      dstX: GameRender.currentNodeDstX - 17,
      dstY: GameRender.currentNodeDstY - 17,
      anchorY: GameConstants.Sprite_Anchor_Y,
      color: color,
    );
  }

  static var previousVisibility = 0;

  static void renderNodeAt() {
    final currentNodeVisibility = GameRender.currentNodeVisibility;
    if (currentNodeVisibility == Visibility.Invisible) return;

    if (currentNodeVisibility != previousVisibility){
      previousVisibility = currentNodeVisibility;
      Engine.bufferBlendMode = VisibilityBlendModes.fromVisibility(currentNodeVisibility);
    }

    switch (GameRender.currentNodeType) {
      case NodeType.Grass:
        if (GameRender.currentNodeOrientation == NodeOrientation.Solid){
          if (GameRender.currentNodeVariation){
            renderStandardNodeShaded(
              srcX: 624,
              srcY: 0,
            );
            return;
          }
        }
        renderNodeTemplateShaded(GameConstants.Sprite_Width_Padded_3);
        return;
      case NodeType.Brick:
        const index_grass = 2;
        const srcX = GameConstants.Sprite_Width_Padded * index_grass;
        renderNodeTemplateShaded(srcX);
        return;
      case NodeType.Torch:
        renderNodeTorch();
        break;
      case NodeType.Water:
        renderNodeWater();
        break;
      case NodeType.Tree_Bottom:
        renderTreeBottom();
        break;
      case NodeType.Tree_Top:
        renderTreeTop();
        break;
      case NodeType.Grass_Long:
        switch (GameRender.currentNodeWind) {
          case WindType.Calm:
            renderStandardNodeShaded(
              srcX: AtlasNodeX.Grass_Long,
              srcY: 0,
            );
            return;
          default:
            renderStandardNodeShaded(
              srcX: AtlasNodeX.Grass_Long + ((((GameRender.currentNodeRow - GameRender.currentNodeColumn) + GameAnimation.animationFrameGrass) % 6) * 48), // TODO Expensive Operation
              srcY: 0,
            );
            return;
        }
      case NodeType.Rain_Falling:
        renderStandardNodeShaded(
          srcX: ClientState.srcXRainFalling,
          srcY: 72.0 * ((GameAnimation.animationFrame + GameRender.currentNodeRow + GameRender.currentNodeRow + GameRender.currentNodeColumn) % 6), // TODO Expensive Operation
        );
        return;
      case NodeType.Rain_Landing:
        if (GameQueries.getNodeTypeBelow(GameRender.currentNodeIndex) == NodeType.Water){
          Engine.renderSprite(
            image: GameImages.atlas_nodes,
            srcX: AtlasNode.Node_Rain_Landing_Water_X,
            srcY: 72.0 * ((GameAnimation.animationFrame + GameRender.currentNodeRow + GameRender.currentNodeColumn) % 10), // TODO Expensive Operation
            srcWidth: GameConstants.Sprite_Width,
            srcHeight: GameConstants.Sprite_Height,
            dstX: GameRender.currentNodeDstX,
            dstY: GameRender.currentNodeDstY + GameAnimation.animationFrameWaterHeight + 14,
            anchorY: 0.3,
            color: GameRender.currentNodeColor,
          );
          return;
        }
        renderStandardNodeShaded(
          srcX: ClientState.srcXRainLanding,
          srcY: 72.0 * ((GameAnimation.animationFrame + GameRender.currentNodeRow + GameRender.currentNodeColumn) % 6), // TODO Expensive Operation
        );
        return;
      case NodeType.Concrete:
        renderNodeTemplateShaded(GameConstants.Sprite_Width_Padded_8);
        return;
      case NodeType.Metal:
        renderNodeTemplateShaded(GameConstants.Sprite_Width_Padded_4);
        return;
      case NodeType.Road:
        renderNodeTemplateShaded(GameConstants.Sprite_Width_Padded_9);
        return;
      case NodeType.Road_2:
        renderStandardNodeShaded(srcX: 768, srcY: 672 + GameConstants.Sprite_Height_Padded);
        return;
      case NodeType.Wooden_Plank:
        renderNodeWoodenPlank();
        return;
      case NodeType.Wood:
        const index_grass = 5;
        const srcX = GameConstants.Sprite_Width_Padded * index_grass;
        renderNodeTemplateShaded(srcX);
        break;
      case NodeType.Bau_Haus:
        const index_grass = 6;
        const srcX = GameConstants.Sprite_Width_Padded * index_grass;
        renderNodeTemplateShaded(srcX);
        break;
      case NodeType.Sunflower:
        renderStandardNodeShaded(
          srcX: 1753.0,
          srcY: AtlasNodeY.Sunflower,
        );
        return;
      case NodeType.Soil:
        const index_grass = 7;
        const srcX = GameConstants.Sprite_Width_Padded * index_grass;
        renderNodeTemplateShaded(srcX);
        return;
      case NodeType.Fireplace:
        renderStandardNode(
          srcX: AtlasNode.Campfire_X,
          srcY: AtlasNode.Node_Campfire_Y + ((GameAnimation.animationFrame % 6) * 72),
        );
        return;
      case NodeType.Boulder:
        renderStandardNodeShaded(
          srcX: AtlasNodeX.Boulder,
          srcY: AtlasNodeY.Boulder,
        );
        return;
      case NodeType.Oven:
        renderStandardNodeShaded(
          srcX: AtlasNodeX.Oven,
          srcY: AtlasNodeY.Oven,
        );
        return;
      case NodeType.Chimney:
        renderStandardNodeShaded(
          srcX: AtlasNode.Chimney_X,
          srcY: AtlasNode.Node_Chimney_Y,
        );
        return;
      case NodeType.Window:
        renderNodeWindow();
        break;
      case NodeType.Spawn:
        if (GameState.playMode) return;
        renderStandardNode(
          srcX: AtlasNode.Spawn_X,
          srcY: AtlasNode.Spawn_Y,
        );
        break;
      case NodeType.Spawn_Weapon:
        if (GameState.playMode) return;
        renderStandardNode(
          srcX: AtlasNode.Spawn_Weapon_X,
          srcY: AtlasNode.Spawn_Weapon_Y,
        );
        break;
      case NodeType.Spawn_Player:
        if (GameState.playMode) return;
        renderStandardNode(
          srcX: AtlasNode.Spawn_Player_X,
          srcY: AtlasNode.Spawn_Player_Y,
        );
        break;
      case NodeType.Table:
        renderStandardNode(
          srcX: AtlasNode.Table_X,
          srcY: AtlasNode.Node_Table_Y,
        );
        return;
      case NodeType.Bed_Top:
        renderStandardNode(
          srcX: AtlasNode.X_Bed_Top,
          srcY: AtlasNode.Y_Bed_Top,
        );
        return;
      case NodeType.Bed_Bottom:
        renderStandardNode(
          srcX: AtlasNode.X_Bed_Bottom,
          srcY: AtlasNode.Y_Bed_Bottom,
        );
        return;
      case NodeType.Respawning:
        return;
      default:
        throw Exception('renderNode(index: ${GameRender.currentNodeIndex}, type: ${NodeType.getName(GameRender.currentNodeType)}, orientation: ${NodeOrientation.getName(GameNodes.nodesOrientation[GameRender.currentNodeIndex])}');
    }
  }

  static void renderTreeTop() => renderNodeBelowVariation ? renderTreeTopPine() : renderTreeTopOak();

  static void renderTreeBottom() => renderNodeVariation ? renderTreeBottomPine() : renderTreeBottomOak();

  static void renderTreeTopOak(){
    var shift = GameAnimation.treeAnimation[((GameRender.currentNodeRow - GameRender.currentNodeColumn) + GameAnimation.animationFrame) % GameAnimation.treeAnimation.length] * renderNodeWind;
    Engine.renderSprite(
      image: GameImages.atlas_nodes,
      srcX: AtlasNodeX.Tree_Top,
      srcY: AtlasNodeY.Tree_Top,
      srcWidth: AtlasNode.Node_Tree_Top_Width,
      srcHeight: AtlasNode.Node_Tree_Top_Height,
      dstX: GameRender.currentNodeDstX + (shift * 0.5),
      dstY: GameRender.currentNodeDstY,
      color: getRenderLayerColor(-2),
    );
  }

  static void renderTreeTopPine() {
    var shift = GameAnimation.treeAnimation[((GameRender.currentNodeRow - GameRender.currentNodeColumn) + GameAnimation.animationFrame) % GameAnimation.treeAnimation.length] * renderNodeWind;
    Engine.renderSprite(
      image: GameImages.atlas_nodes,
      srcX: 1262,
      srcY: 80 ,
      srcWidth: 45,
      srcHeight: 58,
      dstX: GameRender.currentNodeDstX + (shift * 0.5),
      dstY: GameRender.currentNodeDstY,
      color: getRenderLayerColor(-2),
    );
  }

  static void renderTreeBottomOak() {
    Engine.renderSprite(
      image: GameImages.atlas_nodes,
      srcX: AtlasNodeX.Tree_Bottom,
      srcY: AtlasNodeY.Tree_Bottom,
      srcWidth: AtlasNode.Width_Tree_Bottom,
      srcHeight: AtlasNode.Node_Tree_Bottom_Height,
      dstX: GameRender.currentNodeDstX,
      dstY: GameRender.currentNodeDstY,
      color: renderNodeBelowColor,
    );
  }

  static void renderTreeBottomPine() {
    Engine.renderSprite(
      image: GameImages.atlas_nodes,
      srcX: 1216,
      srcY: 80,
      srcWidth: 45,
      srcHeight: 66,
      dstX: GameRender.currentNodeDstX,
      dstY: GameRender.currentNodeDstY,
      color: renderNodeBelowColor,
    );
  }

  static void renderNodeTemplateShaded(double srcX) {
    switch (GameRender.currentNodeOrientation){
      case NodeOrientation.Solid:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_00,
        );
        return;
      case NodeOrientation.Half_North:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_01,
          offsetX: -8,
          offsetY: -8,
        );
        return;
      case NodeOrientation.Half_South:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_01,
          offsetX: 8,
          offsetY: 8,
        );
        return;
      case NodeOrientation.Half_East:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_02,
          offsetX: 8,
          offsetY: -8,
        );
        return;
      case NodeOrientation.Half_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_02,
          offsetX: -8,
          offsetY: 8,
        );
        return;
      case NodeOrientation.Corner_Top:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_03,
        );
        return;
      case NodeOrientation.Corner_Right:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_04,
        );
        return;
      case NodeOrientation.Corner_Bottom:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_05,
        );
        return;
      case NodeOrientation.Corner_Left:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_06,
        );
        return;
      case NodeOrientation.Slope_North:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_07,
        );
        return;
      case NodeOrientation.Slope_East:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_08,
        );
        return;
      case NodeOrientation.Slope_South:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_09,
        );
        return;
      case NodeOrientation.Slope_West:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_10,
        );
        return;
      case NodeOrientation.Slope_Outer_South_West:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_11,
        );
        return;
      case NodeOrientation.Slope_Outer_North_West:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_12,
        );
        return;
      case NodeOrientation.Slope_Outer_North_East:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_13,
        );
        return;
      case NodeOrientation.Slope_Outer_South_East:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_14,
        );
        return;
      case NodeOrientation.Slope_Inner_South_East:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_15,
        );
        return;
      case NodeOrientation.Slope_Inner_North_East :
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_16,
        );
        return;
      case NodeOrientation.Slope_Inner_North_West:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_17,
        );
        return;
      case NodeOrientation.Slope_Inner_South_West:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_18,
        );
        return;
      case NodeOrientation.Radial:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_19,
        );
        return;
      case NodeOrientation.Half_Vertical_Top:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_20,
          offsetX: 0,
          offsetY: -9,
        );
        return;
      case NodeOrientation.Half_Vertical_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_20,
          offsetX: 0,
          offsetY: -1,
        );
        return;
      case NodeOrientation.Half_Vertical_Bottom:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_20,
          offsetX: 0,
          offsetY: 2,
        );
        return;
      case NodeOrientation.Column_Top_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_21,
          offsetX: 0,
          offsetY: -16,
        );
        return;
      case NodeOrientation.Column_Top_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_21,
          offsetX: -8,
          offsetY: -8,
        );
        return;
      case NodeOrientation.Column_Top_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_21,
          offsetX: -16,
          offsetY: 0,
        );
        return;
      case NodeOrientation.Column_Center_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_21,
          offsetX: 8,
          offsetY: -8,
        );
        break;
      case NodeOrientation.Column_Center_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_21,
          offsetX: 0,
          offsetY: 0,
        );
        break;
      case NodeOrientation.Column_Center_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_21,
          offsetX: -8,
          offsetY: 8,
        );
        break;

      case NodeOrientation.Column_Bottom_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_21,
          offsetX: 0,
          offsetY: 16,
        );
        return;
      case NodeOrientation.Column_Bottom_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_21,
          offsetX: 8,
          offsetY: 8,
        );
        return;
      case NodeOrientation.Column_Bottom_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_21,
          offsetX: 16,
          offsetY: 0,
        );
        return;
    }
  }

  static void renderNodeWoodenPlank(){
    switch(renderNodeOrientation){
      case NodeOrientation.Solid:
        renderStandardNodeShaded(
          srcX: AtlasNode.Wooden_Plank_Solid_X,
          srcY: AtlasNode.Node_Wooden_Plank_Solid_Y,
        );
        return;
      case NodeOrientation.Half_North:
        renderStandardNodeHalfNorthOld(
          srcX: AtlasNode.Node_Wooden_Plank_Half_South_X,
          srcY: AtlasNode.Node_Wooden_Plank_Half_South_Y,
          color: renderNodeColor,
        );
        return;
      case NodeOrientation.Half_East:
        renderStandardNodeHalfEastOld(
          srcX: AtlasNode.Node_Wooden_Plank_Half_West_X,
          srcY: AtlasNode.Node_Wooden_Plank_Half_West_Y,
          color: renderNodeColor,
        );
        return;
      case NodeOrientation.Half_South:
        renderStandardNodeShaded(
          srcX: AtlasNode.Node_Wooden_Plank_Half_South_X,
          srcY: AtlasNode.Node_Wooden_Plank_Half_South_Y,
        );
        return;
      case NodeOrientation.Half_West:
        renderStandardNodeShaded(
          srcX: AtlasNode.Node_Wooden_Plank_Half_West_X,
          srcY: AtlasNode.Node_Wooden_Plank_Half_West_Y,
        );
        return;
      case NodeOrientation.Corner_Top:
        renderStandardNodeShaded(
          srcX: AtlasNode.Node_Wooden_Plank_Corner_Top_X,
          srcY: AtlasNode.Node_Wooden_Plank_Corner_Top_Y,
        );
        return;
      case NodeOrientation.Corner_Right:
        renderStandardNodeShaded(
          srcX: AtlasNode.Node_Wooden_Plank_Corner_Right_X,
          srcY: AtlasNode.Node_Wooden_Plank_Corner_Right_Y,
        );
        return;
      case NodeOrientation.Corner_Bottom:
        renderStandardNodeShaded(
          srcX: AtlasNode.Node_Wooden_Plank_Corner_Bottom_X,
          srcY: AtlasNode.Node_Wooden_Plank_Corner_Bottom_Y,
        );
        return;
      case NodeOrientation.Corner_Left:
        renderStandardNodeShaded(
          srcX: AtlasNode.Node_Wooden_Plank_Corner_Left_X,
          srcY: AtlasNode.Node_Wooden_Plank_Corner_Left_Y,
        );
        return;
    }
  }

  static void renderNodeWindow(){
    const srcX = 1508.0;
    switch (renderNodeOrientation) {
      case NodeOrientation.Half_North:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: 80 + GameConstants.Sprite_Height_Padded,
          offsetX: -8,
          offsetY: -8,
        );
        return;
      case NodeOrientation.Half_South:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: 80 + GameConstants.Sprite_Height_Padded,
          offsetX: 8,
          offsetY: 8,
        );
        return;
      case NodeOrientation.Half_East:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: 80,
          offsetX: 8,
          offsetY: -8,
        );
        return;
      case NodeOrientation.Half_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: 80,
          offsetX: -8,
          offsetY: 8,
        );
        return;
      default:
        throw Exception("render_node_window(${NodeOrientation.getName(renderNodeOrientation)})");
    }
  }


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
  int getTotal() => ClientState.totalActiveParticles;

  @override
  void reset() {
    GameSort.sortParticles();
    super.reset();
  }
}

int get renderNodeShade => GameNodes.nodesShade[GameRender.currentNodeIndex];
int get renderNodeOrientation => GameNodes.nodesOrientation[GameRender.currentNodeIndex];
int get renderNodeColor => GameLighting.values[renderNodeShade];
int get renderNodeWind => GameNodes.nodesWind[renderNodeShade];
bool get renderNodeVariation => GameNodes.nodesVariation[GameRender.currentNodeIndex];

int get renderNodeBelowIndex => GameRender.currentNodeIndex - GameNodes.nodesArea;
bool get renderNodeBelowVariation => renderNodeBelowIndex > 0 ? GameNodes.nodesVariation[renderNodeBelowIndex] : renderNodeVariation;

int get renderNodeBelowShade {
  if (renderNodeBelowIndex < 0) return ServerState.ambientShade.value;
  if (renderNodeBelowIndex >= GameNodes.nodesTotal) return ServerState.ambientShade.value;
  return GameNodes.nodesShade[renderNodeBelowIndex];
}

int get renderNodeBelowColor => GameLighting.values[renderNodeBelowShade];

int getRenderLayerColor(int layers) =>
    GameLighting.values[getRenderLayerShade(layers)];

int getRenderLayerShade(int layers){
   final index = GameRender.currentNodeIndex + (layers * GameNodes.nodesArea);
   if (index < 0) return ServerState.ambientShade.value;
   if (index >= GameNodes.nodesTotal) return ServerState.ambientShade.value;
   return GameNodes.nodesShade[index];
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