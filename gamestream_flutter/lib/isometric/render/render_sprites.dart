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
  static final renderOrderGrid = RenderOrderGrid();
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

  static var renderNodeZ = 0;
  static var renderNodeRow = 0;
  static var renderNodeColumn = 0;
  static var renderNodeDstX = 0.0;
  static var renderNodeDstY = 0.0;
  static var renderNodeIndex = 0;
  static var renderNodeType = 0;

  static var indexShow = 0;
  static var indexShowRow = 0;
  static var indexShowColumn = 0;
  static var indexShowZ = 0;

  static final maxZRender = Watch<int>(GameState.nodesTotalZ, clamp: (int value){
    return clamp<int>(value, 0, max(GameState.nodesTotalZ - 1, 0));
  });

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
}

class RenderOrderCharacters extends RenderOrder {
  late Character character;

  @override
  void renderFunction() {
    renderCharacter(character);
  }

  @override
  void updateFunction() {
    character = GameState.characters[_index];
    order = character.renderOrder;
    orderZ = character.indexZ;
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

  late GameObject gameObject;

  @override
  int getTotal() => totalGameObjects;

  @override
  void renderFunction() {
    renderGameObject(gameObject);
  }

  @override
  void updateFunction() {
    gameObject = gameObjects[_index];
    order = gameObject.renderOrder;
    orderZ = gameObject.indexZ;
  }

  @override
  void reset() {
    super.reset();
  }
}

class RenderOrderProjectiles extends RenderOrder {
  late Projectile projectile;

  @override
  void renderFunction() {
    renderProjectile(projectile);
  }

  @override
  void updateFunction() {
     projectile = GameState.projectiles[_index];
     order = projectile.renderOrder;
     orderZ = projectile.indexZ;
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
  late Particle particle;
  var totalActive = 0;

  @override
  void renderFunction() {
    renderParticle(particle);
  }

  @override
  void updateFunction() {
    particle = GameState.particles[_index];
    order = particle.renderOrder;
    orderZ = particle.indexZ;
  }

  @override
  int getTotal() => totalActive;

  @override
  void reset() {
    sortParticles();
    totalActive = GameState.totalActiveParticles;
    super.reset();
  }
}

int get renderNodeShade => GameState.nodesShade[RenderEngine.renderNodeIndex];
int get renderNodeOrientation => GameState.nodesOrientation[RenderEngine.renderNodeIndex];
int get renderNodeColor => colorShades[renderNodeShade];
int get renderNodeWind => GameState.nodesWind[renderNodeShade];
int get renderNodeBelowIndex => RenderEngine.renderNodeIndex + GameState.nodesArea;

int get renderNodeBelowShade {
  if (renderNodeBelowIndex < 0) return GameState.ambientShade.value;
  if (renderNodeBelowIndex >= GameState.nodesTotal) return GameState.ambientShade.value;
  return GameState.nodesShade[renderNodeBelowIndex];
}

int get renderNodeBelowColor => colorShades[renderNodeBelowShade];

int getRenderLayerColor(int layers) =>
  colorShades[getRenderLayerShade(layers)];

int getRenderLayerShade(int layers){
   final index = RenderEngine.renderNodeIndex + (layers * GameState.nodesArea);
   if (index < 0) return GameState.ambientShade.value;
   if (index >= GameState.nodesTotal) return GameState.ambientShade.value;
   return GameState.nodesShade[index];
}


class RenderOrderGrid extends RenderOrder {
  var rowsMax = 0;
  var shiftIndex = 0;
  var screenTopLeftRow = 0;
  var screenBottomRightRow = 0;
  var gridTotalColumnsMinusOne = 0;
  var gridTotalZMinusOne = 0;

  var playerColumnRow = 0;
  var playerUnderRoof = false;

  var startRow = 0;
  var startColumn = 0;

  var maxZ = 0;
  var minZ = 0;

  double get renderX => (RenderEngine.renderNodeRow - RenderEngine.renderNodeColumn) * tileSizeHalf;
  double get renderY => convertRowColumnZToY(RenderEngine.renderNodeRow, RenderEngine.renderNodeColumn, RenderEngine.renderNodeZ);

  @override
  void renderFunction() {

    while (
    RenderEngine.renderNodeColumn >= 0 &&
        RenderEngine.renderNodeRow <= rowsMax &&
        RenderEngine.renderNodeDstX <= RenderEngine.screenRight
    ){
      RenderEngine.renderNodeType = GameState.nodesType[RenderEngine.renderNodeIndex];
      if (RenderEngine.renderNodeType != NodeType.Empty){
        renderNodeAt();
      }
      RenderEngine.renderNodeRow++;
      RenderEngine.renderNodeColumn--;
      RenderEngine.renderNodeIndex += gridTotalColumnsMinusOne;
      RenderEngine.renderNodeDstX += spriteWidth;
    }
  }

  @override
  void updateFunction() {
    RenderEngine.renderNodeZ++;
    if (RenderEngine.renderNodeZ > maxZ) {
      RenderEngine.renderNodeZ = 0;
      shiftIndexDown();
      if (!remaining) return;
      calculateMinMaxZ();
      if (!remaining) return;
      trimLeft();

      while (renderY > RenderEngine.screenBottom) {
        RenderEngine.renderNodeZ++;
        if (RenderEngine.renderNodeZ > maxZ) {
          remaining = false;
          return;
        }
      }
    } else {
      RenderEngine.renderNodeRow = startRow;
      RenderEngine.renderNodeColumn = startColumn;
    }
    RenderEngine.renderNodeDstX = (RenderEngine.renderNodeRow - RenderEngine.renderNodeColumn) * nodeSizeHalf;
    RenderEngine.renderNodeDstY = ((RenderEngine.renderNodeRow + RenderEngine.renderNodeColumn) * nodeSizeHalf) - (RenderEngine.renderNodeZ * nodeHeight);
    RenderEngine.renderNodeIndex = (RenderEngine.renderNodeZ * GameState.nodesArea) + (RenderEngine.renderNodeRow * GameState.nodesTotalColumns) + RenderEngine.renderNodeColumn;
    RenderEngine.renderNodeType = GameState.nodesType[RenderEngine.renderNodeIndex];
    order = ((RenderEngine.renderNodeRow + RenderEngine.renderNodeColumn) * tileSize) + tileSizeHalf;
    orderZ = RenderEngine.renderNodeZ;
  }

  @override
  int getTotal() {
    return GameState.nodesTotalZ * GameState.nodesTotalRows * GameState.nodesTotalColumns;
  }

  @override
  void reset() {
    rowsMax = GameState.nodesTotalRows - 1;
    gridTotalZMinusOne = GameState.nodesTotalZ - 1;
    RenderEngine.offscreenNodesTop = 0;
    RenderEngine.offscreenNodesRight = 0;
    RenderEngine.offscreenNodesBottom = 0;
    RenderEngine.offscreenNodesLeft = 0;
    RenderEngine.offscreenNodes = 0;
    RenderEngine.onscreenNodes = 0;
    minZ = 0;
    order = 0;
    orderZ = 0;
    RenderEngine.renderNodeZ = 0;
    orderZ = 0;
    gridTotalColumnsMinusOne = GameState.nodesTotalColumns - 1;
    RenderEngine.playerZ = GameState.player.indexZ;
    RenderEngine.playerRow = GameState.player.indexRow;
    RenderEngine.playerColumn = GameState.player.indexColumn;
    playerColumnRow = RenderEngine.playerRow + RenderEngine.playerColumn;
    RenderEngine.playerRenderRow = RenderEngine.playerRow - (GameState.player.indexZ ~/ 2);
    RenderEngine.playerRenderColumn = RenderEngine.playerColumn - (GameState.player.indexZ ~/ 2);
    playerUnderRoof = gridIsUnderSomething(RenderEngine.playerZ, RenderEngine.playerRow, RenderEngine.playerColumn);

    RenderEngine.indexShow = inBoundsVector3(GameState.player) ? GameState.player.nodeIndex : 0;
    RenderEngine.indexShowRow = convertIndexToRow(RenderEngine.indexShow);
    RenderEngine.indexShowColumn = convertIndexToColumn(RenderEngine.indexShow);
    RenderEngine.indexShowZ = convertIndexToZ(RenderEngine.indexShow);

    RenderEngine.indexShowPerceptible =
        gridIsPerceptible(RenderEngine.indexShow) &&
        gridIsPerceptible(RenderEngine.indexShow + 1) &&
        gridIsPerceptible(RenderEngine.indexShow - 1) &&
        gridIsPerceptible(RenderEngine.indexShow + GameState.nodesTotalColumns) &&
        gridIsPerceptible(RenderEngine.indexShow - GameState.nodesTotalColumns) &&
        gridIsPerceptible(RenderEngine.indexShow + GameState.nodesTotalColumns + 1) ;

    RenderEngine.screenRight = Engine.screen.right + tileSize;
    RenderEngine.screenLeft = Engine.screen.left - tileSize;
    RenderEngine.screenTop = Engine.screen.top - 72;
    RenderEngine.screenBottom = Engine.screen.bottom + 72;
    var screenTopLeftColumn = convertWorldToColumn(RenderEngine.screenLeft, RenderEngine.screenTop, 0);
    screenBottomRightRow = clamp(convertWorldToRow(RenderEngine.screenRight, RenderEngine.screenBottom, 0), 0, GameState.nodesTotalRows - 1);
    screenTopLeftRow = convertWorldToRow(RenderEngine.screenLeft, RenderEngine.screenTop, 0);

    if (screenTopLeftRow < 0){
      screenTopLeftColumn += screenTopLeftRow;
      screenTopLeftRow = 0;
    }
    if (screenTopLeftColumn < 0){
      screenTopLeftRow += screenTopLeftColumn;
      screenTopLeftColumn = 0;
    }
    if (screenTopLeftColumn >= GameState.nodesTotalColumns){
      screenTopLeftRow = screenTopLeftColumn - gridTotalColumnsMinusOne;
      screenTopLeftColumn = gridTotalColumnsMinusOne;
    }
    if (screenTopLeftRow < 0 || screenTopLeftColumn < 0){
      screenTopLeftRow = 0;
      screenTopLeftColumn = 0;
    }

    RenderEngine.renderNodeRow = screenTopLeftRow;
    RenderEngine.renderNodeColumn = screenTopLeftColumn;


    shiftIndex = 0;
    calculateMinMaxZ();
    trimTop();
    trimLeft();

    RenderEngine.renderNodeDstX = (RenderEngine.renderNodeRow - RenderEngine.renderNodeColumn) * nodeSizeHalf;
    RenderEngine.renderNodeDstY = ((RenderEngine.renderNodeRow + RenderEngine.renderNodeColumn) * nodeSizeHalf) - (RenderEngine.renderNodeZ * nodeHeight);
    RenderEngine.renderNodeIndex = (RenderEngine.renderNodeZ * GameState.nodesArea) + (RenderEngine.renderNodeRow * GameState.nodesTotalColumns) + RenderEngine.renderNodeColumn;
    RenderEngine.renderNodeType = GameState.nodesType[RenderEngine.renderNodeIndex];

    while (GameState.visibleIndex > 0) {
      GameState.nodesVisible[GameState.nodesVisibleIndex[GameState.visibleIndex]] = true;
      GameState.visibleIndex--;
    }
    GameState.nodesVisible[GameState.nodesVisibleIndex[0]] = true;


    if (!RenderEngine.indexShowPerceptible) {
      const radius = 3;
      for (var r = -radius; r <= radius + 2; r++){
         for (var c = -radius; c <= radius + 2; c++){
           if (RenderEngine.indexShowRow + r < 0) continue;
           if (RenderEngine.indexShowRow + r >= GameState.nodesTotalRows) continue;
           if (RenderEngine.indexShowColumn + c < 0) continue;
           if (RenderEngine.indexShowColumn + c >= GameState.nodesTotalColumns) continue;
            hideIndex(RenderEngine.indexShow - (GameState.nodesTotalColumns * r) + c);
         }
      }
    }

    total = getTotal();
    _index = 0;
    remaining = total > 0;

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

  void hideIndex(int index){
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

  void revealRaycast(int z, int row, int column){
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

  void revealAbove(int z, int row, int column){
    for (; z < GameState.nodesTotalZ; z++){
      GameState.nodesVisible[getNodeIndexZRC(z, row, column)] = false;
    }
  }

  void trimTop() {
    while (renderY < RenderEngine.screenTop){
      shiftIndexDown();
    }
    calculateMinMaxZ();
    setStart();
  }

  // given a grid coordinate row / column workout the maximum z before it goes above the top of the screen.
  // otherwise use totalZ;
  // calculate the world position Y at row / column, then workout its distance from the top of the screen;
  void calculateMinMaxZ(){
    final bottom = convertRowColumnToY(RenderEngine.renderNodeRow, RenderEngine.renderNodeColumn);
    final distance =  bottom - RenderEngine.screenTop;
    maxZ = (distance ~/ tileHeight);
    if (maxZ > gridTotalZMinusOne){
      maxZ = gridTotalZMinusOne;
    }
    if (maxZ < 0){
      maxZ = 0;
    }

    while (convertRowColumnZToY(RenderEngine.renderNodeRow, RenderEngine.renderNodeColumn, minZ) > RenderEngine.screenBottom){
      minZ++;
      if (minZ >= GameState.nodesTotalZ){
        return end();
      }
    }
  }

  void shiftIndexDown(){
    RenderEngine.renderNodeColumn = RenderEngine.renderNodeRow + RenderEngine.renderNodeColumn + 1;
    RenderEngine.renderNodeRow = 0;
    if (RenderEngine.renderNodeColumn < GameState.nodesTotalColumns) {
      return setStart();
    }
    RenderEngine.renderNodeRow = RenderEngine.renderNodeColumn - gridTotalColumnsMinusOne;
    RenderEngine.renderNodeColumn = gridTotalColumnsMinusOne;

    if (RenderEngine.renderNodeRow >= GameState.nodesTotalRows){
       remaining = false;
       return;
    }
    RenderEngine.renderNodeDstY = ((RenderEngine.renderNodeRow + RenderEngine.renderNodeColumn) * nodeSizeHalf) - (RenderEngine.renderNodeZ * nodeHeight);
    setStart();
  }

  void trimLeft(){
    final offscreen = countLeftOffscreen;
    if (offscreen <= 0) return;
    RenderEngine.renderNodeColumn -= offscreen;
    RenderEngine.renderNodeRow += offscreen;
    while (renderX < RenderEngine.screenLeft){
      RenderEngine.renderNodeRow++;
      RenderEngine.renderNodeColumn--;
    }
    setStart();
  }

  void setStart(){
    startRow = RenderEngine.renderNodeRow;
    startColumn = RenderEngine.renderNodeColumn;
  }

  int get countLeftOffscreen {
    final x = convertRowColumnToX(RenderEngine.renderNodeRow, RenderEngine.renderNodeColumn);
    if (Engine.screen.left < x) return 0;
    final diff = Engine.screen.left - x;
    return diff ~/ tileSize;
  }

  void refreshDynamicLightGrid() {
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