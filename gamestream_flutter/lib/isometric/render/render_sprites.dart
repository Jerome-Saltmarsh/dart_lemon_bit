import 'dart:math';

import 'package:bleed_common/library.dart';
import 'package:bleed_common/node_size.dart';
import 'package:gamestream_flutter/isometric/characters.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/game_object.dart';
import 'package:gamestream_flutter/isometric/classes/projectile.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/game.dart';
import 'package:gamestream_flutter/isometric/gameobjects.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';
import 'package:gamestream_flutter/isometric/lighting/apply_emissions_characters.dart';
import 'package:gamestream_flutter/isometric/lighting/apply_emmissions_particles.dart';
import 'package:gamestream_flutter/isometric/lighting/apply_projectile_emissions.dart';
import 'package:gamestream_flutter/isometric/nodes/render/render_constants.dart';
import 'package:gamestream_flutter/isometric/nodes/render/render_node.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/projectiles.dart';
import 'package:gamestream_flutter/isometric/render/highlight_character_nearest_mouse.dart';
import 'package:gamestream_flutter/isometric/render/renderCharacter.dart';
import 'package:gamestream_flutter/isometric/render/render_floating_texts.dart';
import 'package:gamestream_flutter/isometric/render/render_game_object.dart';
import 'package:gamestream_flutter/isometric/render/render_projectiles.dart';
import 'package:gamestream_flutter/isometric/utils/convert.dart';
import 'package:lemon_engine/screen.dart';
import 'package:lemon_math/library.dart';
import 'package:lemon_watch/watch.dart';

import '../classes/particle.dart';
import '../edit.dart';
import '../grid.dart';
import '../lighting/apply_emissions_gameobjects.dart';
import 'render_particle.dart';


final renderOrderGrid = RenderOrderGrid();
final renderOrderParticle = RenderOrderParticle();
final renderOrderProjectiles = RenderOrderProjectiles();
final renderOrderCharacters = RenderOrderCharacters();
final renderOrderGameObjects = RenderOrderGameObjects();


// final renderOrder = <RenderOrder> [
//   RenderOrderGrid(),
//   RenderOrderParticle(),
//   RenderOrderProjectiles(),
//   RenderOrderCharacters(),
//   RenderOrderGameObjects(),
// ];

// renderOrderLength gets called a lot during rendering so use a const and update it manually if need be
// const renderOrderLength = 5;
// var renderOrderFirst = renderOrder.first;
var totalRemaining = 0;
var totalIndex = 0;

final maxZRender = Watch<int>(nodesTotalZ, clamp: (int value){
  return clamp<int>(value, 0, max(nodesTotalZ - 1, 0));
});

void resetRenderOrder(RenderOrder value){
  value.reset();
  if (value.remaining){
    totalRemaining++;
  }
}

void renderSprites() {
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

class RenderOrderCharacters extends RenderOrder {
  late Character character;

  @override
  void renderFunction() {
    renderCharacter(character);
  }

  @override
  void updateFunction() {
    character = characters[_index];
    order = character.renderOrder;
    orderZ = character.indexZ;
  }

  @override
  int getTotal() {
    return totalCharacters;
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
     projectile = projectiles[_index];
     order = projectile.renderOrder;
     orderZ = projectile.indexZ;
  }

  @override
  int getTotal() {
    return totalProjectiles;
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
    particle = particles[_index];
    order = particle.renderOrder;
    orderZ = particle.indexZ;
  }

  @override
  int getTotal() => totalActive;

  @override
  void reset() {
    sortParticles();
    totalActive = totalActiveParticles;
    super.reset();
  }
}


var playerImperceptible = false;
var playerRenderRow = 0;
var playerRenderColumn = 0;
var playerZ = 0;
var playerRow = 0;
var playerColumn = 0;

var offscreenNodesTop = 0;
var offscreenNodesRight = 0;
var offscreenNodesBottom = 0;
var offscreenNodesLeft = 0;

var onscreenNodes = 0;
var offscreenNodes = 0;

var screenTop = screen.top - 120;
var screenRight = screen.right + tileSize;
var screenBottom = screen.bottom + 80;
var screenLeft = screen.left - tileSize;

var renderNodeZ = 0;
var renderNodeRow = 0;
var renderNodeColumn = 0;
var renderNodeDstX = 0.0;
var renderNodeDstY = 0.0;
var renderNodeIndex = 0;
var renderNodeType = 0;

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

  double get renderX => (renderNodeRow - renderNodeColumn) * tileSizeHalf;
  double get renderY => convertRowColumnZToY(renderNodeRow, renderNodeColumn, renderNodeZ);

  @override
  void renderFunction() {

    while (
        renderNodeColumn >= 0 &&
        renderNodeRow <= rowsMax &&
        renderNodeDstX <= screenRight
    ){
      renderNodeType = nodesType[renderNodeIndex];

      if (renderNodeType != NodeType.Empty){
        renderNodeAt();
      }
      renderNodeRow++;
      renderNodeColumn--;
      renderNodeIndex += gridTotalColumnsMinusOne;
      renderNodeDstX += spriteWidth;
    }
  }

  @override
  void updateFunction() {
    renderNodeZ++;
    if (renderNodeZ > maxZ) {
      renderNodeZ = 0;
      shiftIndexDown();
      if (!remaining) return;
      calculateMinMaxZ();
      if (!remaining) return;
      trimLeft();

      while (renderY > screenBottom) {
        renderNodeZ++;
        if (renderNodeZ > maxZ) {
          remaining = false;
          return;
        }
      }
    } else {
      renderNodeRow = startRow;
      renderNodeColumn = startColumn;
    }
    renderNodeDstX = (renderNodeRow - renderNodeColumn) * nodeSizeHalf;
    renderNodeDstY = ((renderNodeRow + renderNodeColumn) * nodeSizeHalf) - (renderNodeZ * nodeHeight);
    renderNodeIndex = (renderNodeZ * nodesArea) + (renderNodeRow * nodesTotalColumns) + renderNodeColumn;
    renderNodeType = nodesType[renderNodeIndex];
    order = ((renderNodeRow + renderNodeColumn) * tileSize) + tileSizeHalf;
    orderZ = renderNodeZ;
  }

  @override
  int getTotal() {
    return nodesTotalZ * nodesTotalRows * nodesTotalColumns;
  }

  @override
  void reset() {
    rowsMax = nodesTotalRows - 1;
    gridTotalZMinusOne = nodesTotalZ - 1;
    offscreenNodesTop = 0;
    offscreenNodesRight = 0;
    offscreenNodesBottom = 0;
    offscreenNodesLeft = 0;
    offscreenNodes = 0;
    onscreenNodes = 0;
    minZ = 0;
    order = 0;
    orderZ = 0;
    renderNodeZ = 0;
    orderZ = 0;
    gridTotalColumnsMinusOne = nodesTotalColumns - 1;
    playerZ = player.indexZ;
    playerRow = player.indexRow;
    playerColumn = player.indexColumn;
    playerColumnRow = playerRow + playerColumn;
    playerRenderRow = playerRow - (player.indexZ ~/ 2);
    playerRenderColumn = playerColumn - (player.indexZ ~/ 2);
    playerUnderRoof = gridIsUnderSomething(playerZ, playerRow, playerColumn);

    playerImperceptible =
        !gridIsPerceptible(playerZ, playerRow, playerColumn)
          ||
        !gridIsPerceptible(playerZ + 1, playerRow, playerColumn)
          ||
        !gridIsPerceptible(playerZ, playerRow + 1, playerColumn + 1)
          ||
        !gridIsPerceptible(playerZ, playerRow - 1, playerColumn)
          ||
        !gridIsPerceptible(playerZ, playerRow , playerColumn - 1)
    ;

    screenRight = screen.right + tileSize;
    screenLeft = screen.left - tileSize;
    screenTop = screen.top - 72;
    screenBottom = screen.bottom + 72;
    var screenTopLeftColumn = convertWorldToColumn(screenLeft, screenTop, 0);
    screenBottomRightRow = clamp(convertWorldToRow(screenRight, screenBottom, 0), 0, nodesTotalRows - 1);
    screenTopLeftRow = convertWorldToRow(screenLeft, screenTop, 0);

    if (screenTopLeftRow < 0){
      screenTopLeftColumn += screenTopLeftRow;
      screenTopLeftRow = 0;
    }
    if (screenTopLeftColumn < 0){
      screenTopLeftRow += screenTopLeftColumn;
      screenTopLeftColumn = 0;
    }
    if (screenTopLeftColumn >= nodesTotalColumns){
      screenTopLeftRow = screenTopLeftColumn - gridTotalColumnsMinusOne;
      screenTopLeftColumn = gridTotalColumnsMinusOne;
    }
    if (screenTopLeftRow < 0 || screenTopLeftColumn < 0){
      screenTopLeftRow = 0;
      screenTopLeftColumn = 0;
    }

    renderNodeRow = screenTopLeftRow;
    renderNodeColumn = screenTopLeftColumn;


    shiftIndex = 0;
    calculateMinMaxZ();
    trimTop();
    trimLeft();

    renderNodeDstX = (renderNodeRow - renderNodeColumn) * nodeSizeHalf;
    renderNodeDstY = ((renderNodeRow + renderNodeColumn) * nodeSizeHalf) - (renderNodeZ * nodeHeight);
    renderNodeIndex = (renderNodeZ * nodesArea) + (renderNodeRow * nodesTotalColumns) + renderNodeColumn;
    renderNodeType = nodesType[renderNodeIndex];

    if (playerImperceptible){
       // revealAbove(playerZ + 1, playerRow, playerColumn);
       // revealAbove(playerZ + 1, playerRow + 1, playerColumn);
       // revealAbove(playerZ + 1, playerRow, playerColumn + 1);
       // revealAbove(playerZ + 1, playerRow + 1, playerColumn + 1);

      final d = 3;
       for (var r = playerRow - d; r < playerRow + d; r++){
          for (var c = playerColumn - d; c < playerColumn + d; c++) {
            if (r < playerRow || c < playerColumn){
              revealRaycast(playerZ + 2, r, c);
            } else {
              revealRaycast(playerZ + 1, r, c);
              revealRaycast(playerZ + 2, r, c);
            }
          }
       }
    }
    total = getTotal();
    _index = 0;
    remaining = total > 0;

    refreshDynamicLightGrid();
    applyEmissionsCharacters();
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

  void revealRaycast(int z, int row, int column){
    if (!verifyInBoundZRC(z, row, column)) return;

    for (; z < nodesTotalZ; z += 2){
      row++;
      column++;
      if (row >= nodesTotalRows) return;
      if (column >= nodesTotalColumns) return;
      nodesVisible[getNodeIndexZRC(z, row, column)] = false;
      if (z < nodesTotalZ - 2){
        nodesVisible[getNodeIndexZRC(z + 1, row, column)] = false;
      }
    }
  }

  void revealAbove(int z, int row, int column){
    for (; z < nodesTotalZ; z++){
      nodesVisible[getNodeIndexZRC(z, row, column)] = false;
    }
  }

  void trimTop() {
    while (renderY < screenTop){
      shiftIndexDown();
    }
    calculateMinMaxZ();
    setStart();
  }

  // given a grid coordinate row / column workout the maximum z before it goes above the top of the screen.
  // otherwise use totalZ;
  // calculate the world position Y at row / column, then workout its distance from the top of the screen;
  void calculateMinMaxZ(){
    final bottom = convertRowColumnToY(renderNodeRow, renderNodeColumn);
    final distance =  bottom - screenTop;
    maxZ = (distance ~/ tileHeight);
    if (maxZ > gridTotalZMinusOne){
      maxZ = gridTotalZMinusOne;
    }
    if (maxZ < 0){
      maxZ = 0;
    }

    while (convertRowColumnZToY(renderNodeRow, renderNodeColumn, minZ) > screenBottom){
      minZ++;
      if (minZ >= nodesTotalZ){
        return end();
      }
    }
  }

  void shiftIndexDown(){
    renderNodeColumn = renderNodeRow + renderNodeColumn + 1;
    renderNodeRow = 0;
    if (renderNodeColumn < nodesTotalColumns) {
      return setStart();
    }
    renderNodeRow = renderNodeColumn - gridTotalColumnsMinusOne;
    renderNodeColumn = gridTotalColumnsMinusOne;

    if (renderNodeRow >= nodesTotalRows){
       remaining = false;
       return;
    }
    renderNodeDstY = ((renderNodeRow + renderNodeColumn) * nodeSizeHalf) - (renderNodeZ * nodeHeight);
    setStart();
  }

  void trimLeft(){
    final offscreen = countLeftOffscreen;
    if (offscreen <= 0) return;
    renderNodeColumn -= offscreen;
    renderNodeRow += offscreen;
    while (renderX < screenLeft){
      renderNodeRow++;
      renderNodeColumn--;
    }
    setStart();
  }

  void setStart(){
    startRow = renderNodeRow;
    startColumn = renderNodeColumn;
  }

  int get countLeftOffscreen {
    final x = convertRowColumnToX(renderNodeRow, renderNodeColumn);
    if (screen.left < x) return 0;
    final diff = screen.left - x;
    return diff ~/ tileSize;
  }

  void refreshDynamicLightGrid() {
    for (var i = 0; i < nodesTotal; i++) {
      nodesShade[i] = nodesBake[i];
    }
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
  renderText(text: totalIndex.toString(), x: position.renderX, y: position.renderY - 100);
}