import 'dart:math';

import 'package:bleed_common/library.dart';
import 'package:bleed_common/node_size.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/game_object.dart';
import 'package:gamestream_flutter/isometric/classes/projectile.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/constants/color_pitch_black.dart';
import 'package:gamestream_flutter/isometric/convert_index.dart';
import 'package:gamestream_flutter/isometric/game.dart';
import 'package:gamestream_flutter/isometric/gameobjects.dart';
import 'package:gamestream_flutter/isometric/grid_state_util.dart';
import 'package:gamestream_flutter/isometric/lighting/apply_emmissions_particles.dart';
import 'package:gamestream_flutter/isometric/lighting/apply_projectile_emissions.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';
import 'package:gamestream_flutter/isometric/nodes/render/render_constants.dart';
import 'package:gamestream_flutter/isometric/nodes/render/render_node.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:gamestream_flutter/isometric/render/highlight_character_nearest_mouse.dart';
import 'package:gamestream_flutter/isometric/render/renderCharacter.dart';
import 'package:gamestream_flutter/isometric/render/render_floating_texts.dart';
import 'package:gamestream_flutter/isometric/render/render_game_object.dart';
import 'package:gamestream_flutter/isometric/render/render_projectiles.dart';
import 'package:gamestream_flutter/isometric/utils/convert.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';
import 'package:lemon_watch/watch.dart';

import '../classes/particle.dart';
import '../edit.dart';
import '../grid.dart';
import '../lighting/apply_emissions_gameobjects.dart';
import 'render_particle.dart';



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

  static final maxZRender = Watch<int>(GameState.nodesTotalZ, clamp: (int value){
    return clamp<int>(value, 0, max(GameState.nodesTotalZ - 1, 0));
  });

  static double get renderX => (currentNodeRow - currentNodeColumn) * tileSizeHalf;
  static double get renderY => convertRowColumnZToY(currentNodeRow, currentNodeColumn, currentNodeZ);


  static void nodesTrimLeft(){
    final offscreen = countLeftOffscreen;
    if (offscreen <= 0) return;
    currentNodeColumn -= offscreen;
    currentNodeRow += offscreen;
    while (renderX < screenLeft){
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

  static void resetRenderOrder(RenderOrder value){
    value.reset();
    if (value.remaining){
      totalRemaining++;
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
      currentNodeType = GameState.nodesType[currentNodeIndex];
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

      while (renderY > screenBottom) {
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
    nodesPlayerUnderRoof = gridIsUnderSomething(playerZ, playerRow, playerColumn);

    indexShow = inBoundsVector3(GameState.player) ? GameState.player.nodeIndex : 0;
    indexShowRow = convertIndexToRow(indexShow);
    indexShowColumn = convertIndexToColumn(indexShow);
    indexShowZ = convertIndexToZ(indexShow);

    indexShowPerceptible =
        gridIsPerceptible(indexShow) &&
            gridIsPerceptible(indexShow + 1) &&
            gridIsPerceptible(indexShow - 1) &&
            gridIsPerceptible(indexShow + GameState.nodesTotalColumns) &&
            gridIsPerceptible(indexShow - GameState.nodesTotalColumns) &&
            gridIsPerceptible(indexShow + GameState.nodesTotalColumns + 1) ;

    screenRight = Engine.screen.right + tileSize;
    screenLeft = Engine.screen.left - tileSize;
    screenTop = Engine.screen.top - 72;
    screenBottom = Engine.screen.bottom + 72;
    var screenTopLeftColumn = convertWorldToColumn(screenLeft, screenTop, 0);
    nodesScreenBottomRightRow = clamp(convertWorldToRow(screenRight, screenBottom, 0), 0, GameState.nodesTotalRows - 1);
    nodesScreenTopLeftRow = convertWorldToRow(screenLeft, screenTop, 0);

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

    refreshDynamicLightGrid();
    GameState.applyEmissionsCharacters();
    applyEmissionGameObjects();
    applyEmissionsParticles();
    applyCharacterColors();

    if (editMode){
      applyEmissionDynamic(
        index: edit.nodeIndex.value,
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
    if (!verifyInBoundZRC(z, row, column)) return;

    for (; z < GameState.nodesTotalZ; z += 2){
      row++;
      column++;
      if (row >= GameState.nodesTotalRows) return;
      if (column >= GameState.nodesTotalColumns) return;
      GameState.nodesVisible[getNodeIndexZRC(z, row, column)] = false;
      if (z < GameState.nodesTotalZ - 2){
        GameState.nodesVisible[getNodeIndexZRC(z + 1, row, column)] = false;
      }
    }
  }

  static void nodesRevealAbove(int z, int row, int column){
    for (; z < GameState.nodesTotalZ; z++){
      GameState.nodesVisible[getNodeIndexZRC(z, row, column)] = false;
    }
  }

  static void nodesTrimTop() {
    while (renderY < screenTop){
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
      if (nodesMinZ >= GameState.nodesTotalZ){
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
    while (GameState.dynamicIndex >= 0) {
      final i = GameState.nodesDynamicIndex[GameState.dynamicIndex];
      GameState.nodesShade[i] = GameState.nodesBake[i];
      GameState.dynamicIndex--;
    }
    GameState.dynamicIndex = 0;
  }
}

class RenderOrderCharacters extends RenderOrder {

  @override
  void renderFunction() {
    renderCharacter(RenderEngine.currentRenderCharacter);
  }

  @override
  void updateFunction() {
    RenderEngine.currentRenderCharacter = GameState.characters[_index];
    order = RenderEngine.currentRenderCharacter.renderOrder;
    orderZ = RenderEngine.currentRenderCharacter.indexZ;
  }

  @override
  int getTotal() {
    return GameState.totalCharacters;
  }

  @override
  void reset() {
    super.reset();
    // applyEmissionsCharacters();
    //
    // for (var i = 0; i < totalGameObjects; i++){
    //    if (gameObjects[i].type != GameObjectType.Candle) continue;
    //    gameObjects[i].tile.applyLight1();
    //    gameObjects[i].tileBelow.applyLight1();
    // }
  }
}

class RenderOrderGameObjects extends RenderOrder {

  @override
  int getTotal() => totalGameObjects;

  @override
  void renderFunction() {
    renderGameObject(RenderEngine.currentRenderGameObject);
  }

  @override
  void updateFunction() {
    RenderEngine.currentRenderGameObject = gameObjects[_index];
    order = RenderEngine.currentRenderGameObject.renderOrder;
    orderZ = RenderEngine.currentRenderGameObject.indexZ;
  }

  @override
  void reset() {
    super.reset();
  }
}

class RenderOrderProjectiles extends RenderOrder {
  @override
  void renderFunction() {
    renderProjectile(RenderEngine.currentRenderProjectile);
  }

  @override
  void updateFunction() {
    RenderEngine.currentRenderProjectile = GameState.projectiles[_index];
     order = RenderEngine.currentRenderProjectile.renderOrder;
     orderZ = RenderEngine.currentRenderProjectile.indexZ;
  }

  @override
  int getTotal() {
    return GameState.totalProjectiles;
  }

  @override
  void reset() {
    applyProjectileEmissions();
    super.reset();
  }
}

class RenderOrderParticle extends RenderOrder {

  @override
  void renderFunction() {
    renderParticle(RenderEngine.currentParticle);
  }

  @override
  void updateFunction() {
    RenderEngine.currentParticle = GameState.particles[_index];
    order = RenderEngine.currentParticle.renderOrder;
    orderZ = RenderEngine.currentParticle.indexZ;
  }

  @override
  int getTotal() => GameState.totalActiveParticles;

  @override
  void reset() {
    sortParticles();
    super.reset();
  }
}

int get renderNodeShade => GameState.nodesShade[RenderEngine.currentNodeIndex];
int get renderNodeOrientation => GameState.nodesOrientation[RenderEngine.currentNodeIndex];
int get renderNodeColor => colorShades[renderNodeShade];
int get renderNodeWind => GameState.nodesWind[renderNodeShade];
int get renderNodeBelowIndex => RenderEngine.currentNodeIndex + GameState.nodesArea;

int get renderNodeBelowShade {
  if (renderNodeBelowIndex < 0) return GameState.ambientShade.value;
  if (renderNodeBelowIndex >= GameState.nodesTotal) return GameState.ambientShade.value;
  return GameState.nodesShade[renderNodeBelowIndex];
}

int get renderNodeBelowColor => colorShades[renderNodeBelowShade];

int getRenderLayerColor(int layers) =>
  colorShades[getRenderLayerShade(layers)];

int getRenderLayerShade(int layers){
   final index = RenderEngine.currentNodeIndex + (layers * GameState.nodesArea);
   if (index < 0) return GameState.ambientShade.value;
   if (index >= GameState.nodesTotal) return GameState.ambientShade.value;
   return GameState.nodesShade[index];
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
    return GameState.nodesTotalZ * GameState.nodesTotalRows * GameState.nodesTotalColumns;
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
    if (!verifyInBoundZRC(z, row, column)) return;

    for (; z < GameState.nodesTotalZ; z += 2){
      row++;
      column++;
      if (row >= GameState.nodesTotalRows) return;
      if (column >= GameState.nodesTotalColumns) return;
      GameState.nodesVisible[getNodeIndexZRC(z, row, column)] = false;
      if (z < GameState.nodesTotalZ - 2){
        GameState.nodesVisible[getNodeIndexZRC(z + 1, row, column)] = false;
      }
    }
  }

  static void nodesRevealAbove(int z, int row, int column){
    for (; z < GameState.nodesTotalZ; z++){
      GameState.nodesVisible[getNodeIndexZRC(z, row, column)] = false;
    }
  }

  static void nodesTrimTop() {
    while (RenderEngine.renderY < RenderEngine.screenTop){
      RenderEngine.nodesShiftIndexDown();
    }
    nodesCalculateMinMaxZ();
    RenderEngine.nodesSetStart();
  }

  // given a grid coordinate row / column workout the maximum z before it goes above the top of the screen.
  // otherwise use totalZ;
  // calculate the world position Y at row / column, then workout its distance from the top of the screen;
  static void nodesCalculateMinMaxZ(){
    final bottom = convertRowColumnToY(RenderEngine.currentNodeRow, RenderEngine.currentNodeColumn);
    final distance =  bottom - RenderEngine.screenTop;
    RenderEngine.nodesMaxZ = (distance ~/ tileHeight);
    if (RenderEngine.nodesMaxZ > RenderEngine.nodesGridTotalZMinusOne){
      RenderEngine.nodesMaxZ = RenderEngine.nodesGridTotalZMinusOne;
    }
    if (RenderEngine.nodesMaxZ < 0){
      RenderEngine.nodesMaxZ = 0;
    }

    while (convertRowColumnZToY(RenderEngine.currentNodeRow, RenderEngine.currentNodeColumn, RenderEngine.nodesMinZ) > RenderEngine.screenBottom){
      RenderEngine.nodesMinZ++;
      if (RenderEngine.nodesMinZ >= GameState.nodesTotalZ){
        return RenderEngine.renderOrderGrid.end();
      }
    }
  }

  static int get countLeftOffscreen {
    final x = convertRowColumnToX(RenderEngine.currentNodeRow, RenderEngine.currentNodeColumn);
    if (Engine.screen.left < x) return 0;
    final diff = Engine.screen.left - x;
    return diff ~/ tileSize;
  }

  static void refreshDynamicLightGrid() {
    while (GameState.dynamicIndex >= 0) {
      final i = GameState.nodesDynamicIndex[GameState.dynamicIndex];
      GameState.nodesShade[i] = GameState.nodesBake[i];
      GameState.dynamicIndex--;
    }
    GameState.dynamicIndex = 0;
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

// RenderOrder getNextRenderOrder(){
//    RenderOrder renderOrder = renderOrderGrid;
//    if (renderOrderCharacters.remaining &&
//        renderOrderCharacters.order < renderOrder.order &&
//        renderOrderCharacters.orderZ < renderOrder.orderZ
//    ) {
//     renderOrder = renderOrderCharacters;
//    }
//    if (renderOrderProjectiles.remaining){
//      renderOrder = renderOrder.compare(renderOrderProjectiles);
//    }
//    if (renderOrderGameObjects.remaining){
//      renderOrder = renderOrder.compare(renderOrderGameObjects);
//    }
//    if (renderOrderParticle.remaining){
//      renderOrder = renderOrder.compare(renderOrderParticle);
//    }
//    return renderOrder;
// }

int getRenderRow(int row, int z){
  return row - (z ~/ 2);
}

int getRenderColumn(int column, int z){
  return column - (z ~/ 2);
}

void renderTotalIndex(Vector3 position){
  renderText(text: RenderEngine.totalIndex.toString(), x: position.renderX, y: position.renderY - 100);
}