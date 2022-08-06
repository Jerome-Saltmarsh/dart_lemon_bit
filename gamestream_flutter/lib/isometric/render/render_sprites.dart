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
import 'package:lemon_engine/engine.dart';
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
  var initialRow = 0;
  var initialColumn = 0;
  var shiftIndex = 0;
  late Node node;
  var maxColumnRow = 0;
  var minColumnRow = 0;
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

  var maxRow = 0;
  var maxZ = 0;
  var minZ = 0;
  var minColumn = 0;

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

    node.performRender();
  }

  @override
  void updateFunction() {
    nextGridNode();
    while (!node.renderable || !nodeVisible) {
      index = _index + 1;
      if (!remaining) return;
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
    calculateLimits();
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
    final screenBottomLeftColumn = convertWorldToColumn(screenLeft, screenBottom, 0);
    final screenBottomLeftRow = convertWorldToRow(screenLeft, screenBottom, 0);
    final screenBottomLeftTotal = screenBottomLeftRow + screenBottomLeftColumn;
    var screenTopLeftColumn = convertWorldToColumn(screenLeft, screenTop, 0);
    screenBottomRightRow = clamp(convertWorldToRow(screenRight, screenBottom, 0), 0, gridTotalRows - 1);
    screenTopLeftRow = convertWorldToRow(screenLeft, screenTop, 0);
    minColumnRow = max(screenTopLeftRow + screenTopLeftColumn, 0);
    maxColumnRow = min(gridTotalRows + gridTotalColumns, screenBottomLeftTotal);


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
    initialRow = row;
    initialColumn = column;
    shiftIndex = 0;
    calculateMinMaxZ();
    trim();
    node = grid[z][row][column];

    assert(row >= 0);
    assert(column >= 0);
    assert(row < gridTotalRows);
    assert(column < gridTotalColumns);
    refreshDynamicLightGrid();
    super.reset();
  }

  void calculateLimits() {
    minColumn = convertWorldToColumnSafe(screenRight, screenTop, 0);
    maxRow = convertWorldToRowSafe(screenRight, screenBottom, 0);
    assert(minColumn >= 0);
    assert(maxRow >= 0);
    assert(minColumn < gridTotalColumns);
    assert(maxRow < gridTotalRows);
  }

  void refreshMaxRow(){

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

    if (bottom > screen.bottom) {
      final diff = bottom - screen.bottom;
      minZ = diff ~/ tileHeight;
      if (minZ >= gridTotalZ){
        return end();
      }
    }
  }

  void nextGridNode(){
    z++;

    if (z >= maxZ) {
      row++;
      column--;
      if (node.dstX > screenRight || column < minColumn || row > maxRow) {
        shiftIndexDown();
        if (!remaining) return;
        calculateMinMaxZ();
        if (!remaining) return;
        while (renderX < screenLeft){
           row++;
           column--;
        }
      }
      z = minZ;
    }

    assert (z >= 0);
    assert (z < gridTotalZ);
    assert (row >= 0);
    assert (row < gridTotalRows);
    assert (column >= 0);
    assert (column < gridTotalColumns);
    node = grid[z][row][column];

    if (!node.renderable) return;

    orderZ = z;
    order = node.order;
    gridZHalf =  z ~/ 2;
    gridZGreaterThanPlayerZ = z > playerZ;
  }

  void checkValidity() {
    assert (z >= 0);
    assert (z < gridTotalZ);
    assert (row >= 0);
    assert (row < gridTotalRows);
    assert (column >= 0);
    assert (column < gridTotalColumns);
  }

  void shiftIndexDown(){
    column = row + column + 1;
    row = 0;
    if (column < gridTotalColumns) return;
    row = column - gridTotalColumnsMinusOne;
    column = gridTotalColumnsMinusOne;
    trim();

    if (row >= gridTotalRows){
       remaining = false;
    }
  }

  void trim(){
    final offscreen = countLeftOffscreen;
    if (offscreen <= 0) return;
    column -= offscreen;
    row += offscreen;
    assert(countLeftOffscreen <= 0);
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