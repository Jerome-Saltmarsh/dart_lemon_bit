import 'dart:math';

import 'package:bleed_common/library.dart';
import 'package:bleed_common/node_size.dart';
import 'package:gamestream_flutter/atlases.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/animation_frame.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/game_object.dart';
import 'package:gamestream_flutter/isometric/classes/projectile.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/constants/color_pitch_black.dart';
import 'package:gamestream_flutter/isometric/convert_index.dart';
import 'package:gamestream_flutter/isometric/game.dart';
import 'package:gamestream_flutter/isometric/grid_state_util.dart';
import 'package:gamestream_flutter/isometric/lighting/apply_emmissions_particles.dart';
import 'package:gamestream_flutter/isometric/lighting/apply_projectile_emissions.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';
import 'package:gamestream_flutter/isometric/nodes/render/atlas_src_gameobjects.dart';
import 'package:gamestream_flutter/isometric/nodes/render/render_constants.dart';
import 'package:gamestream_flutter/isometric/nodes/render/render_node.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:gamestream_flutter/isometric/render/get_character_render_color.dart';
import 'package:gamestream_flutter/isometric/render/highlight_character_nearest_mouse.dart';
import 'package:gamestream_flutter/isometric/render/renderCharacter.dart';
import 'package:gamestream_flutter/isometric/render/render_floating_texts.dart';
import 'package:gamestream_flutter/isometric/render/render_projectiles.dart';
import 'package:gamestream_flutter/isometric/render/render_shadow.dart';
import 'package:gamestream_flutter/isometric/utils/convert.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';
import 'package:lemon_watch/watch.dart';

import 'isometric/classes/particle.dart';
import 'isometric/edit.dart';
import 'isometric/grid.dart';
import 'isometric/lighting/apply_emissions_gameobjects.dart';
import 'isometric/render/render_particle.dart';



class RenderEngine {
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

  static final maxZRender = Watch<int>(Game.nodesTotalZ, clamp: (int value){
    return clamp<int>(value, 0, max(Game.nodesTotalZ - 1, 0));
  });

  static double get currentNodeRenderX => (currentNodeRow - currentNodeColumn) * tileSizeHalf;
  static double get currentNodeRenderY => convertRowColumnZToY(currentNodeRow, currentNodeColumn, currentNodeZ);


  static void renderCurrentParticle() =>
    renderParticle(currentParticle);

  static void renderCurrentProjectile() =>
    renderProjectile(currentRenderProjectile);

  static void renderCurrentGameObject() =>
    renderGameObject(currentRenderGameObject);

  static void updateCurrentParticle(){
    currentParticle = Game.particles[renderOrderParticle.index];
    renderOrderParticle.order = currentParticle.renderOrder;
    renderOrderParticle.orderZ = currentParticle.indexZ;
  }

  static void updateCurrentProjectile(){
    currentRenderProjectile = Game.projectiles[renderOrderProjectiles.index];
    renderOrderProjectiles.order = currentRenderProjectile.renderOrder;
    renderOrderProjectiles.orderZ = currentRenderProjectile.indexZ;
  }

  static void updateCurrentGameObject(){
    currentRenderGameObject = Game.gameObjects[renderOrderGameObjects.index];
    renderOrderGameObjects.order = currentRenderGameObject.renderOrder;
    renderOrderGameObjects.orderZ = currentRenderGameObject.indexZ;
  }

  static void renderCurrentCharacter(){
    renderCharacter(currentRenderCharacter);
  }

  static void updateCurrentCharacter() {
    currentRenderCharacter = Game.characters[renderOrderCharacters.index];
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
    if (currentNodeColumn < Game.nodesTotalColumns) {
      return nodesSetStart();
    }
    currentNodeRow = currentNodeColumn - nodesGridTotalColumnsMinusOne;
    currentNodeColumn = nodesGridTotalColumnsMinusOne;

    if (currentNodeRow >= Game.nodesTotalRows){
      renderOrderGrid.remaining = false;
      return;
    }
    currentNodeDstY = ((currentNodeRow + currentNodeColumn) * nodeSizeHalf) - (currentNodeZ * nodeHeight);
    nodesSetStart();
  }


  // ACTIONS

  static void resetRenderOrder(RenderOrder value){
    value.reset();
    if (value.remaining){
      totalRemaining++;
    }
  }
  
  static double getRenderX(Vector3 v3) => (v3.x - v3.y) * 0.5;
  static double getRenderY(Vector3 v3) => ((v3.y + v3.x) * 0.5) - v3.z;

  static void renderGameObject(GameObject gameObject) {
    switch (gameObject.type) {
      case GameObjectType.Rock:
        Engine.renderBuffer(
          dstX: gameObject.renderX,
          dstY: gameObject.renderY,
          srcX: AtlasSrcGameObjects.Rock_X,
          srcY: AtlasSrcGameObjects.Rock_Y,
          srcWidth: AtlasSrcGameObjects.Rock_Width,
          srcHeight: AtlasSrcGameObjects.Rock_Height,
          color: getRenderColor(gameObject),
        );
        return;
      case GameObjectType.Loot:
        Engine.renderSprite(
          image: Images.gameobjects,
          dstX: getRenderX(gameObject),
          dstY: getRenderY(gameObject),
          srcX: AtlasSrcGameObjects.Loot_X,
          srcY: AtlasSrcGameObjects.Loot_Y,
          srcWidth: AtlasSrcGameObjects.Loot_Width,
          srcHeight: AtlasSrcGameObjects.Loot_Height,
          color: getRenderColor(gameObject),
        );
        return;
      case GameObjectType.Barrel:
        Engine.renderSprite(
          image: Images.gameobjects,
          dstX: getRenderX(gameObject),
          dstY: getRenderY(gameObject),
          srcX: AtlasSrcGameObjects.Barrel_X,
          srcY: AtlasSrcGameObjects.Barrel_Y,
          srcWidth: AtlasSrcGameObjects.Barrel_Width,
          srcHeight: AtlasSrcGameObjects.Barrel_Height,
          anchorY: AtlasSrcGameObjects.Barrel_Anchor,
          color: getRenderColor(gameObject),
        );
        return;
      case GameObjectType.Tavern_Sign:
        Engine.renderSprite(
          image: Images.gameobjects,
          dstX: getRenderX(gameObject),
          dstY: getRenderY(gameObject),
          srcX: AtlasSrcGameObjects.Tavern_Sign_X,
          srcY: AtlasSrcGameObjects.Tavern_Sign_Y,
          srcWidth: AtlasSrcGameObjects.Tavern_Sign_Width,
          srcHeight: AtlasSrcGameObjects.Tavern_Sign_Height,
          color: getRenderColor(gameObject),
        );
        return;
      case GameObjectType.Candle:
        Engine.renderBuffer(
          dstX: getRenderX(gameObject),
          dstY: getRenderY(gameObject),
          srcX: 1812,
          srcY: 0,
          srcWidth: 3,
          srcHeight: 10,
          anchorY: 0.95,
        );
        return;
      case GameObjectType.Bottle:
        Engine.renderBuffer(
          dstX: getRenderX(gameObject),
          dstY: getRenderY(gameObject),
          srcX: 1811,
          srcY: 11,
          srcWidth: 5,
          srcHeight: 14,
          anchorY: 0.95,
          color: getRenderColor(gameObject),
        );
        return;
      case GameObjectType.Wheel:
        Engine.renderBuffer(
          dstX: getRenderX(gameObject),
          dstY: getRenderY(gameObject),
          srcX: 1775,
          srcY: 0,
          srcWidth: 34,
          srcHeight: 40,
          anchorY: 0.9,
          color: getRenderColor(gameObject),
        );
        return;
      case GameObjectType.Flower:
        Engine.renderBuffer(
          dstX: getRenderX(gameObject),
          dstY: getRenderY(gameObject),
          srcX: 1680,
          srcY: 0,
          srcWidth: 16,
          srcHeight: 16,
          color: getRenderColor(gameObject),
        );
        return;
      case GameObjectType.Stick:
        Engine.renderBuffer(
          dstX: getRenderX(gameObject),
          dstY: getRenderY(gameObject),
          srcX: 1696,
          srcY: 0,
          srcWidth: 16,
          srcHeight: 16,
          color: getRenderColor(gameObject),
        );
        return;
      case GameObjectType.Crystal:
        Engine.renderSprite(
            image: Images.gameobjects,
            dstX: getRenderX(gameObject),
            dstY: getRenderY(gameObject),
            srcX: AtlasSrcGameObjects.Crystal_Large_X,
            srcY: AtlasSrcGameObjects.Crystal_Large_Y,
            srcWidth: AtlasSrcGameObjects.Crystal_Large_Width,
            srcHeight: AtlasSrcGameObjects.Crystal_Large_Height,
            anchorY: AtlasSrcGameObjects.Crystal_Anchor_Y
        );
        return;
      case GameObjectType.Cup:
        Engine.renderBuffer(
          dstX: getRenderX(gameObject),
          dstY: getRenderY(gameObject),
          srcX: AtlasSrcGameObjects.Cup_X,
          srcY: AtlasSrcGameObjects.Cup_Y,
          srcWidth: AtlasSrcGameObjects.Cup_Width,
          srcHeight: AtlasSrcGameObjects.Cup_Height,
          anchorY: AtlasSrcGameObjects.Cup_Anchor_Y,
        );
        return;
      case GameObjectType.Lantern_Red:
        Engine.renderBuffer(
          dstX:getRenderX(gameObject),
          dstY:getRenderY(gameObject),
          srcX: 1744,
          srcY: 48,
          srcWidth: 12,
          srcHeight: 22,
          scale: 1.0,
          color: colorShades[Shade.Very_Bright],
        );
        return;
      case GameObjectType.Wooden_Shelf_Row:
        Engine.renderBuffer(
            dstX:getRenderX(gameObject),
            dstY:getRenderY(gameObject),
            srcX: 1664,
            srcY: 16,
            srcWidth: 32,
            srcHeight: 38
        );
        return;
      case GameObjectType.Book_Purple:
        Engine.renderBuffer(
          dstX:getRenderX(gameObject),
          dstY:getRenderY(gameObject),
          srcX: 1697,
          srcY: 16,
          srcWidth: 8,
          srcHeight: 15,
        );
        return;
      case GameObjectType.Crystal_Small_Blue:
        Engine.renderBuffer(
          dstX:getRenderX(gameObject),
          dstY:getRenderY(gameObject),
          srcX: 1697,
          srcY: 33,
          srcWidth: 10,
          srcHeight: 19,
        );
        return;
      case GameObjectType.Flower_Green:
        Engine.renderBuffer(
          dstX:getRenderX(gameObject),
          dstY:getRenderY(gameObject),
          srcX: 1696,
          srcY: 53,
          srcWidth: 9,
          srcHeight: 7,
        );
        return;
    }


    const shadowScale = 1.5;
    const shadowScaleHeight = 0.15;
    if (gameObject.type == GameObjectType.Weapon_Shotgun) {
      renderShadow(gameObject.x, gameObject.y, gameObject.z - 15, scale: shadowScale + (shadowScaleHeight * animationFrameWaterHeight.toDouble()));
      return Engine.renderBuffer(
          dstX: getRenderX(gameObject),
          dstY: ((gameObject.y + gameObject.x) * 0.5) - gameObject.z + animationFrameWaterHeight,
          srcX: 262,
          srcY: 204,
          srcWidth: 26,
          srcHeight: 7,
          color: getRenderColor(gameObject)
      );
    }

    if (gameObject.type == GameObjectType.Weapon_Handgun) {
      renderShadow(gameObject.x, gameObject.y, gameObject.z - 15, scale: shadowScale + (shadowScaleHeight * animationFrameWaterHeight.toDouble()));
      return Engine.renderBuffer(
          dstX:getRenderX(gameObject),
          dstY: ((gameObject.y + gameObject.x) * 0.5) - gameObject.z + animationFrameWaterHeight,
          srcX: 234,
          srcY: 200,
          srcWidth: 17,
          srcHeight: 10,
          color: getRenderColor(gameObject)
      );
    }

    if (gameObject.type == GameObjectType.Weapon_Blade) {
      renderShadow(gameObject.x, gameObject.y, gameObject.z - 15, scale: shadowScale + (shadowScaleHeight * animationFrameWaterHeight.toDouble()));
      Engine.renderBuffer(
          dstX:getRenderX(gameObject),
          dstY: ((gameObject.y + gameObject.x) * 0.5) - gameObject.z + animationFrameWaterHeight,
          srcX: 1029,
          srcY: 1644,
          srcWidth: 33,
          srcHeight: 13,
          color: getRenderColor(gameObject)
      );
      return;
    }

    if (gameObject.type == GameObjectType.Weapon_Bow) {
      renderShadow(gameObject.x, gameObject.y, gameObject.z - 15, scale: shadowScale + (shadowScaleHeight * animationFrameWaterHeight.toDouble()));
      Engine.renderBuffer(
          dstX:getRenderX(gameObject),
          dstY: ((gameObject.y + gameObject.x) * 0.5) - gameObject.z + animationFrameWaterHeight,
          srcX: 7181,
          srcY: 1838,
          srcWidth: 30,
          srcHeight: 28,
          color: getRenderColor(gameObject)
      );
      return;
    }

    if (gameObject.type == GameObjectType.Weapon_Staff) {
      renderShadow(gameObject.x, gameObject.y, gameObject.z - 15, scale: shadowScale + (shadowScaleHeight * animationFrameWaterHeight.toDouble()));
      Engine.renderBuffer(
          dstX: getRenderX(gameObject),
          dstY: ((gameObject.y + gameObject.x) * 0.5) - gameObject.z + animationFrameWaterHeight,
          srcX: 7119,
          srcY: 1519,
          srcWidth: 24,
          srcHeight: 24,
          color: getRenderColor(gameObject)
      );
      return;
    }
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

  static void renderCurrentNodeLine() {
    while (
        currentNodeColumn >= 0 &&
        currentNodeRow <= nodesRowsMax &&
        currentNodeDstX <= screenRight
    ){
      currentNodeType = Game.nodesType[currentNodeIndex];
      if (currentNodeType != NodeType.Empty){
        renderNodeAt();
      }
      currentNodeRow++;
      currentNodeColumn--;
      currentNodeIndex += nodesGridTotalColumnsMinusOne;
      currentNodeDstX += spriteWidth;
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
    currentNodeIndex = (currentNodeZ * Game.nodesArea) + (currentNodeRow * Game.nodesTotalColumns) + currentNodeColumn;
    currentNodeType = Game.nodesType[currentNodeIndex];
    renderOrderGrid.order = ((currentNodeRow + currentNodeColumn) * tileSize) + tileSizeHalf;
    renderOrderGrid.orderZ = currentNodeZ;
  }

  static void resetNodes() {
    nodesRowsMax = Game.nodesTotalRows - 1;
    nodesGridTotalZMinusOne = Game.nodesTotalZ - 1;
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
    nodesGridTotalColumnsMinusOne = Game.nodesTotalColumns - 1;
    playerZ = Game.player.indexZ;
    playerRow = Game.player.indexRow;
    playerColumn = Game.player.indexColumn;
    nodesPlayerColumnRow = playerRow + playerColumn;
    playerRenderRow = playerRow - (Game.player.indexZ ~/ 2);
    playerRenderColumn = playerColumn - (Game.player.indexZ ~/ 2);
    nodesPlayerUnderRoof = gridIsUnderSomething(playerZ, playerRow, playerColumn);

    indexShow = inBoundsVector3(Game.player) ? Game.player.nodeIndex : 0;
    indexShowRow = convertIndexToRow(indexShow);
    indexShowColumn = convertIndexToColumn(indexShow);
    indexShowZ = convertIndexToZ(indexShow);

    indexShowPerceptible =
        gridIsPerceptible(indexShow) &&
            gridIsPerceptible(indexShow + 1) &&
            gridIsPerceptible(indexShow - 1) &&
            gridIsPerceptible(indexShow + Game.nodesTotalColumns) &&
            gridIsPerceptible(indexShow - Game.nodesTotalColumns) &&
            gridIsPerceptible(indexShow + Game.nodesTotalColumns + 1) ;

    screenRight = Engine.screen.right + tileSize;
    screenLeft = Engine.screen.left - tileSize;
    screenTop = Engine.screen.top - 72;
    screenBottom = Engine.screen.bottom + 72;
    var screenTopLeftColumn = convertWorldToColumn(screenLeft, screenTop, 0);
    nodesScreenBottomRightRow = clamp(convertWorldToRow(screenRight, screenBottom, 0), 0, Game.nodesTotalRows - 1);
    nodesScreenTopLeftRow = convertWorldToRow(screenLeft, screenTop, 0);

    if (nodesScreenTopLeftRow < 0){
      screenTopLeftColumn += nodesScreenTopLeftRow;
      nodesScreenTopLeftRow = 0;
    }
    if (screenTopLeftColumn < 0){
      nodesScreenTopLeftRow += screenTopLeftColumn;
      screenTopLeftColumn = 0;
    }
    if (screenTopLeftColumn >= Game.nodesTotalColumns){
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
    currentNodeIndex = (currentNodeZ * Game.nodesArea) + (currentNodeRow * Game.nodesTotalColumns) + currentNodeColumn;
    currentNodeType = Game.nodesType[currentNodeIndex];

    while (Game.visibleIndex > 0) {
      Game.nodesVisible[Game.nodesVisibleIndex[Game.visibleIndex]] = true;
      Game.visibleIndex--;
    }
    Game.nodesVisible[Game.nodesVisibleIndex[0]] = true;


    if (!indexShowPerceptible) {
      const radius = 3;
      for (var r = -radius; r <= radius + 2; r++){
        for (var c = -radius; c <= radius + 2; c++){
          if (indexShowRow + r < 0) continue;
          if (indexShowRow + r >= Game.nodesTotalRows) continue;
          if (indexShowColumn + c < 0) continue;
          if (indexShowColumn + c >= Game.nodesTotalColumns) continue;
          nodesHideIndex(indexShow - (Game.nodesTotalColumns * r) + c);
        }
      }
    }

    renderOrderGrid.total = renderOrderGrid.getTotal();
    renderOrderGrid.index = 0;
    renderOrderGrid.remaining = renderOrderGrid.total > 0;

    refreshDynamicLightGrid();
    Game.applyEmissionsCharacters();
    applyEmissionGameObjects();
    applyEmissionsParticles();
    applyCharacterColors();

    if (editMode){
      applyEmissionDynamic(
        index: EditState.nodeIndex.value,
        maxBrightness: Shade.Very_Bright,
      );
    }

    highlightCharacterNearMouse();
  }

  static void nodesHideIndex(int index){
    var i = index + Game.nodesArea + Game.nodesTotalColumns + 1;
    while (true) {
      if (i >= Game.nodesTotal) break;
      Game.nodesVisible[i] = false;
      Game.nodesVisibleIndex[Game.visibleIndex] = i;
      Game.visibleIndex++;
      i += Game.nodesArea + Game.nodesArea + Game.nodesTotalColumns + 1;
    }
    i = index + Game.nodesArea + Game.nodesArea + Game.nodesTotalColumns + 1;
    while (true) {
      if (i >= Game.nodesTotal) break;
      Game.nodesVisible[i] = false;
      Game.nodesVisibleIndex[Game.visibleIndex] = i;
      Game.visibleIndex++;
      i += Game.nodesArea + Game.nodesArea + Game.nodesTotalColumns + 1;
    }
  }

  static void nodesRevealRaycast(int z, int row, int column){
    if (!verifyInBoundZRC(z, row, column)) return;

    for (; z < Game.nodesTotalZ; z += 2){
      row++;
      column++;
      if (row >= Game.nodesTotalRows) return;
      if (column >= Game.nodesTotalColumns) return;
      Game.nodesVisible[getNodeIndexZRC(z, row, column)] = false;
      if (z < Game.nodesTotalZ - 2){
        Game.nodesVisible[getNodeIndexZRC(z + 1, row, column)] = false;
      }
    }
  }

  static void nodesRevealAbove(int z, int row, int column){
    for (; z < Game.nodesTotalZ; z++){
      Game.nodesVisible[getNodeIndexZRC(z, row, column)] = false;
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
    final bottom = convertRowColumnToY(currentNodeRow, currentNodeColumn);
    final distance =  bottom - screenTop;
    nodesMaxZ = (distance ~/ tileHeight);
    if (nodesMaxZ > nodesGridTotalZMinusOne){
      nodesMaxZ = nodesGridTotalZMinusOne;
    }
    if (nodesMaxZ < 0){
      nodesMaxZ = 0;
    }

    while (convertRowColumnZToY(currentNodeRow, currentNodeColumn, nodesMinZ) > screenBottom){
      nodesMinZ++;
      if (nodesMinZ >= Game.nodesTotalZ){
        return renderOrderGrid.end();
      }
    }
  }

  static int get countLeftOffscreen {
    final x = convertRowColumnToX(currentNodeRow, currentNodeColumn);
    if (Engine.screen.left < x) return 0;
    final diff = Engine.screen.left - x;
    return diff ~/ tileSize;
  }

  static void refreshDynamicLightGrid() {
    while (Game.dynamicIndex >= 0) {
      final i = Game.nodesDynamicIndex[Game.dynamicIndex];
      Game.nodesShade[i] = Game.nodesBake[i];
      Game.dynamicIndex--;
    }
    Game.dynamicIndex = 0;
  }
}

class RenderOrderCharacters extends RenderOrder {
  @override
  void renderFunction() => RenderEngine.renderCurrentCharacter();
  void updateFunction() => RenderEngine.updateCurrentCharacter();
  @override
  int getTotal() => Game.totalCharacters;
}

class RenderOrderGameObjects extends RenderOrder {

  @override
  int getTotal() => Game.totalGameObjects;

  @override
  void renderFunction() => RenderEngine.renderCurrentGameObject();

  @override
  void updateFunction() => RenderEngine.updateCurrentGameObject();

  @override
  void reset() {
    super.reset();
  }
}

class RenderOrderProjectiles extends RenderOrder {
  @override
  void renderFunction() => RenderEngine.renderCurrentProjectile();

  @override
  void updateFunction() => RenderEngine.updateCurrentProjectile();

  @override
  int getTotal() {
    return Game.totalProjectiles;
  }

  @override
  void reset() {
    applyProjectileEmissions();
    super.reset();
  }
}

class RenderOrderParticle extends RenderOrder {

  @override
  void renderFunction() => RenderEngine.renderCurrentParticle();

  @override
  void updateFunction() => RenderEngine.updateCurrentParticle();
  @override
  int getTotal() => Game.totalActiveParticles;

  @override
  void reset() {
    sortParticles();
    super.reset();
  }
}

int get renderNodeShade => Game.nodesShade[RenderEngine.currentNodeIndex];
int get renderNodeOrientation => Game.nodesOrientation[RenderEngine.currentNodeIndex];
int get renderNodeColor => colorShades[renderNodeShade];
int get renderNodeWind => Game.nodesWind[renderNodeShade];
int get renderNodeBelowIndex => RenderEngine.currentNodeIndex + Game.nodesArea;

int get renderNodeBelowShade {
  if (renderNodeBelowIndex < 0) return Game.ambientShade.value;
  if (renderNodeBelowIndex >= Game.nodesTotal) return Game.ambientShade.value;
  return Game.nodesShade[renderNodeBelowIndex];
}

int get renderNodeBelowColor => colorShades[renderNodeBelowShade];

int getRenderLayerColor(int layers) =>
  colorShades[getRenderLayerShade(layers)];

int getRenderLayerShade(int layers){
   final index = RenderEngine.currentNodeIndex + (layers * Game.nodesArea);
   if (index < 0) return Game.ambientShade.value;
   if (index >= Game.nodesTotal) return Game.ambientShade.value;
   return Game.nodesShade[index];
}

class RenderOrderNodes extends RenderOrder {

  @override
  void renderFunction() => RenderEngine.renderCurrentNodeLine();
  @override
  void updateFunction() => RenderEngine.nodesUpdateFunction();
  @override
  void reset() => RenderEngine.resetNodes();
  @override
  int getTotal() {
    return Game.nodesTotalZ * Game.nodesTotalRows * Game.nodesTotalColumns;
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
  renderText(text: RenderEngine.totalIndex.toString(), x: position.renderX, y: position.renderY - 100);
}