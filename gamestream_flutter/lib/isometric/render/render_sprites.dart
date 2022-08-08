import 'dart:math';

import 'package:bleed_common/character_type.dart';
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/characters.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/game_object.dart';
import 'package:gamestream_flutter/isometric/classes/node.dart';
import 'package:gamestream_flutter/isometric/classes/projectile.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/gameobjects.dart';
import 'package:gamestream_flutter/isometric/lighting/apply_emissions_npcs.dart';
import 'package:gamestream_flutter/isometric/lighting/apply_particle_emissions.dart';
import 'package:gamestream_flutter/isometric/lighting/apply_projectile_emissions.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/projectiles.dart';
import 'package:gamestream_flutter/isometric/render/render_character_rat.dart';
import 'package:gamestream_flutter/isometric/render/render_character_zombie.dart';
import 'package:gamestream_flutter/isometric/render/render_floating_texts.dart';
import 'package:gamestream_flutter/isometric/render/render_game_object.dart';
import 'package:gamestream_flutter/isometric/render/render_projectiles.dart';
import 'package:gamestream_flutter/isometric/utils/convert.dart';
import 'package:lemon_engine/screen.dart';
import 'package:lemon_math/library.dart';
import 'package:lemon_watch/watch.dart';

import '../classes/particle.dart';
import '../grid.dart';
import 'render_character_template.dart';
import 'render_grid_node.dart';
import 'render_particle.dart';


final renderOrder = <RenderOrder> [
  RenderOrderGrid(),
  RenderOrderParticle(),
  RenderOrderProjectiles(),
  RenderOrderCharacters(),
  RenderOrderGameObjects(),
];

// renderOrderLength gets called a lot during rendering so use a const and update it manually if need be
const renderOrderLength = 5;
var renderOrderFirst = renderOrder.first;
var totalRemaining = 0;
var totalIndex = 0;

final maxZRender = Watch<int>(gridTotalZ, clamp: (int value){
  return clamp<int>(value, 0, max(grid.length - 1, 0));
});

void renderSprites() {
  var remaining = false;
  totalRemaining = 0;
  for (final order in renderOrder){
      order.reset();
      if (order.remaining){
        totalRemaining++;
      }
  }
  remaining = totalRemaining > 0;

  while (remaining) {
    final next = getNextRenderOrder();

    if (!next.remaining) return;

    if (totalRemaining == 1){
      while (next.remaining){
        next.render();
      }
      return;
    }

    if (next.render()) continue;
    totalRemaining--;
    remaining = totalRemaining > 0;
  }
}

bool shouldRender(Vector3 v){
  if (!playerImperceptible) return true;
  if (v.indexZ <= player.indexZ) return true;
  final halfZ = v.indexZ / 2;
  final renderRow = v.indexRow - halfZ;
  final renderColumn = v.indexColumn - halfZ;
  final renderRowDistance = (renderRow - playerRenderRow).abs();
  final renderColumnDistance = (renderColumn - playerRenderColumn).abs();
  return renderRowDistance >= 5 || renderColumnDistance >= 5;
}

class RenderOrderCharacters extends RenderOrder {
  late Character character;

  @override
  void renderFunction() {

    if (!shouldRender(character)) return;

    switch(character.type){
      case CharacterType.Template:
        return renderCharacterTemplate(character);
      case CharacterType.Rat:
        return renderCharacterRat(character);
      case CharacterType.Zombie:
        return renderCharacterZombie(character);
      default:
        throw Exception("Cannot render character type: ${character.type}");
    }
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
    applyEmissionsCharacters();
  }
}

class RenderOrderGameObjects extends RenderOrder {

  late GameObject gameObject;

  @override
  int getTotal() => totalGameObjects;

  @override
  void renderFunction() {
    if (!shouldRender(gameObject)) return;
    renderGameObject(gameObject);
  }

  @override
  void updateFunction() {
    gameObject = gameObjects[_index];
    order = gameObject.renderOrder;
    orderZ = gameObject.indexZ;
  }
}

class RenderOrderProjectiles extends RenderOrder {
  late Projectile projectile;

  @override
  void renderFunction() {
    if (!shouldRender(projectile)) return;
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
    if (!shouldRender(particle)) return;
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
    for (var i = 0; i < totalActive; i++){
       applyParticleEmission(particles[i]);
    }
    super.reset();
  }
}


var playerImperceptible = false;
var gridZGreaterThanPlayerZ = false;
var playerRenderRow = 0;
var playerRenderColumn = 0;
var playerZ = 0;
var playerRow = 0;
var playerColumn = 0;

var offscreenNodes = 0;
var offscreenNodesTop = 0;
var offscreenNodesRight = 0;
var offscreenNodesBottom = 0;
var offscreenNodesLeft = 0;
var onscreenNodes = 0;

class RenderOrderGrid extends RenderOrder {
  var z = 0;
  var column = 0;
  var row = 0;
  var shiftIndex = 0;
  late Node node;
  var screenTopLeftRow = 0;
  var screenBottomRightRow = 0;
  var gridTotalColumnsMinusOne = 0;
  var gridTotalZMinusOne = 0;
  var gridZHalf = 0;

  var playerColumnRow = 0;
  var playerUnderRoof = false;

  var screenRight = screen.right + tileSize;
  var screenLeft = screen.left - tileSize;
  var screenTop = screen.top - tileSize;
  var screenBottom = screen.bottom + tileSize;

  var maxZ = 0;
  var minZ = 0;
  var minColumn = 0;
  var maxRow = 0;

  double get renderX => convertRowColumnToX(row, column);
  double get renderY => convertRowColumnZToY(row, column, z);

  @override
  void renderFunction() {
    transparent = false;
    if (playerImperceptible) {
      if (gridZGreaterThanPlayerZ) {
        final renderRow = row - gridZHalf;
        final renderColumn = column - gridZHalf;
        final renderRowDistance = (renderRow - playerRenderRow).abs();
        final renderColumnDistance = (renderColumn - playerRenderColumn).abs();

        if (z > playerZ + 1 && renderRowDistance <= 5 && renderColumnDistance <= 5) {
          // if (gridRow + gridColumn > playerColumnRow){
            return;
          // }
        }

        if (z > playerZ && renderRowDistance < 2 && renderColumnDistance < 2) {
          if (row + column >= playerColumnRow){
            transparent = true;
          }
        }
      }
    }

    assert (node.renderable);
    assert (node.dstY >= screenTop);
    assert (node.dstX >= screenLeft);
    assert (node.dstY <= screenBottom);

    // if (node.dstX < screenLeft) {
    //   offscreenNodesLeft++;
    //   return;
    // }
    // if (node.dstY < screenTop) {
    //   offscreenNodesTop++;
    //   return;
    // }
    // if (node.dstY > screenBottom) {
    //   offscreenNodesBottom++;
    //   return;
    // }
    if (node.dstX > screenRight) {
      offscreenNodesRight++;
      return;
    }
    onscreenNodes++;
    node.handleRender();
  }

  @override
  void updateFunction() {
    nextGridNode();
    // TODO Optimize
    while (!node.renderable) {
      index = _index + 1; // TODO Optimize
      if (!remaining) return; // TODO Optimize
      nextGridNode();
    }

    order = node.order;
  }

  bool get nodeVisible {
     if (node.dstX < screenLeft) return false;
     if (node.dstX > screenRight) return false;
     if (node.dstY < screenTop) return false;
     if (node.dstY > screenBottom) return false;
     return true;
  }

  @override
  int getTotal() {
    return gridTotalZ * gridTotalRows * gridTotalColumns;
  }

  @override
  void reset() {
    gridTotalZMinusOne = gridTotalZ - 1;
    offscreenNodes = 0;
    offscreenNodesTop = 0;
    offscreenNodesRight = 0;
    offscreenNodesBottom = 0;
    offscreenNodesLeft = 0;
    onscreenNodes = 0;
    minZ = 0;
    order = 0;
    orderZ = 0;
    z = 0;
    orderZ = 0;
    gridZHalf = 0;
    gridTotalColumnsMinusOne = gridTotalColumns - 1;
    playerZ = player.indexZ;
    playerRow = player.indexRow;
    playerColumn = player.indexColumn;
    playerColumnRow = playerRow + playerColumn;
    playerRenderRow = playerRow - (player.indexZ ~/ 2);
    playerRenderColumn = playerColumn - (player.indexZ ~/ 2);
    playerUnderRoof = gridIsUnderSomething(playerZ, playerRow, playerColumn);
    gridZGreaterThanPlayerZ = false;

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
    screenTop = screen.top - tileSize;
    screenBottom = screen.bottom;
    var screenTopLeftColumn = convertWorldToColumn(screenLeft, screenTop, 0);
    screenBottomRightRow = clamp(convertWorldToRow(screenRight, screenBottom, 0), 0, gridTotalRows - 1);
    screenTopLeftRow = convertWorldToRow(screenLeft, screenTop, 0);

    if (screenTopLeftRow < 0){
      screenTopLeftColumn += screenTopLeftRow;
      screenTopLeftRow = 0;
    }
    if (screenTopLeftColumn < 0){
      screenTopLeftRow += screenTopLeftColumn;
      screenTopLeftColumn = 0;
    }
    if (screenTopLeftColumn >= gridTotalColumns){
      screenTopLeftRow = screenTopLeftColumn - gridTotalColumnsMinusOne;
      screenTopLeftColumn = gridTotalColumnsMinusOne;
    }
    if (screenTopLeftRow < 0 || screenTopLeftColumn < 0){
      screenTopLeftRow = 0;
      screenTopLeftColumn = 0;
    }

    row = screenTopLeftRow;
    column = screenTopLeftColumn;
    shiftIndex = 0;
    calculateMinMaxZ();
    assignNode();
    trimTop();
    trimLeft();
    assignNode();
    calculateMinColumnMaxRow();

    refreshDynamicLightGrid();
    super.reset();
  }

  void trimTop() {
    while (node.dstY < screen.top){
      shiftIndexDown();
      calculateMinMaxZ();
      assignNode();
    }
    assert(node.dstY >= screen.top);
  }

  // given a grid coordinate row / column workout the maximum z before it goes above the top of the screen.
  // otherwise use totalZ;
  // calculate the world position Y at row / column, then workout its distance from the top of the screen;
  void calculateMinMaxZ(){
    final bottom = convertRowColumnToY(row, column);
    final distance =  bottom - screen.top;
    maxZ = (distance ~/ tileHeight);
    if (maxZ > gridTotalZMinusOne){
      maxZ = gridTotalZMinusOne;
    }
    if (maxZ < 0){
      maxZ = 0;
    }

    while (convertRowColumnZToY(row, column, minZ) > screenBottom){
      minZ++;
      if (minZ >= gridTotalZ){
        return end();
      }
    }
  }

  void calculateMinColumnMaxRow(){
     minColumn = convertWorldToColumnSafe(screenRight, renderY, 0);
     maxRow = convertWorldToRowSafe(screenRight, renderY, 0);
  }

  void nextGridNode(){
    z++;

    if (node.renderable && node.dstX > screenRight) {
      assert (node.dstX <= screenRight);
    }

    if (z > maxZ) {
      row++;
      column--;
      if (column < minColumn || row > maxRow) {
        shiftIndexDown();
        calculateMinColumnMaxRow();
        if (!remaining) return;
        calculateMinMaxZ();
        if (!remaining) return;
        trimLeft();

        // z = minZ;
        // assignNode();
        //
        // if (node.renderable){
        //   assert (node.dstX >= screenLeft);
        //   assert (node.dstX < screenRight);
        //   assert (node.dstY >= screenTop);
        //   assert (node.dstY <= screenBottom);
        // }

        if (node.renderable && node.dstX > screenRight) {
          assert (node.dstX <= screenRight);
        }
      }
      z = minZ;
    }

    assignNode();

    if (!node.renderable) return;

    if (node.renderable && node.dstX > screenRight) {
      assert (node.dstX <= screenRight);
    }


    orderZ = z;
    order = node.order;
    gridZHalf =  z ~/ 2;
    gridZGreaterThanPlayerZ = z > playerZ;
  }

  void assignNode() {
    assert (z >= 0);
    assert (z < gridTotalZ);
    assert (row >= 0);
    assert (row < gridTotalRows);
    assert (column >= 0);
    assert (column < gridTotalColumns);
    node = grid[z][row][column];
  }

  void shiftIndexDown(){
    column = row + column + 1;
    row = 0;
    if (column < gridTotalColumns) return;
    row = column - gridTotalColumnsMinusOne;
    column = gridTotalColumnsMinusOne;

    if (row >= gridTotalRows){
       remaining = false;
    }
  }

  void trimLeft(){
    final offscreen = countLeftOffscreen;
    if (offscreen <= 0) return;
    column -= offscreen;
    row += offscreen;
    assert(countLeftOffscreen <= 0);

    while (renderX < screenLeft){
      row++;
      column--;
    }
  }

  int get countLeftOffscreen {
    final x = convertRowColumnToX(row, column);
    if (screen.left < x) return 0;
    final diff = screen.left - x;
    return diff ~/ tileSize;
  }

    void refreshDynamicLightGrid(){
        final bottom = screen.bottom + tileHeight;
        for (var z = 0; z < gridTotalZ; z++) {
          final zPlain = grid[z];
          final zLength = z * tileSize;
          final minRow = convertWorldToRowSafe(screenLeft, screenTop, zLength);
          final maxRow = convertWorldToRowSafe(screenRight, bottom, zLength);
          final minColumn = convertWorldToColumnSafe(screenRight, screenTop, zLength);
          final maxColumn = convertWorldToColumnSafe(screenLeft, bottom, zLength);
          final max = maxRow + maxColumn;
          for (var rowIndex = minRow; rowIndex <= maxRow; rowIndex++) {
            final dynamicRow = zPlain[rowIndex];
            for (var columnIndex = minColumn; columnIndex <= maxColumn; columnIndex++) {
              if (columnIndex + rowIndex > max) break;
              dynamicRow[columnIndex].resetShadeToBake();
            }
          }
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
    if (!remaining) return that;
    if (!that.remaining) return this;
    if (order <= that.order) return this;
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

  bool render() {
    assert(remaining);
    renderFunction();
    _index = (_index + 1);
    remaining = _index < total;
    if (remaining) {
      updateFunction();
      return true;
    }
    return false;
  }
}

RenderOrder getNextRenderOrder(){
  var next = renderOrderFirst;
  for (var i = 1; i < renderOrderLength; i++){
    next =  next.compare(renderOrder[i]);
  }
  return next;
}

int getRenderRow(int row, int z){
  return row - (z ~/ 2);
}

int getRenderColumn(int column, int z){
  return column - (z ~/ 2);
}

void renderTotalIndex(Vector3 position){
  renderText(text: totalIndex.toString(), x: position.renderX, y: position.renderY - 100);
}