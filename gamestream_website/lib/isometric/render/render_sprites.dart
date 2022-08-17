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

class RenderOrderCharacters extends RenderOrder {
  late Character character;

  @override
  void renderFunction() {

    if (!character.tile.visible) return;

    if (character.spawning) {
      if (character.frame % 3 != 0) return;
      return spawnParticleOrbShard(
        x: character.x,
        y: character.y,
        z: character.z,
        speed: 1.5,
      );
    }

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

    for (var i = 0; i < totalGameObjects; i++){
       if (gameObjects[i].type != GameObjectType.Candle) continue;
       gameObjects[i].tile.applyLight1();
       gameObjects[i].tileBelow.applyLight1();

    }
  }
}

class RenderOrderGameObjects extends RenderOrder {

  late GameObject gameObject;

  @override
  int getTotal() => totalGameObjects;

  @override
  void renderFunction() {
    if (!gameObject.tile.visible) return;
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
    if (!projectile.tile.visible) return;
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
    if (!particle.tile.visible) return;
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
  var rowsMax = 0;
  var shiftIndex = 0;
  late Node node;
  var screenTopLeftRow = 0;
  var screenBottomRightRow = 0;
  var gridTotalColumnsMinusOne = 0;
  var gridTotalZMinusOne = 0;

  var playerColumnRow = 0;
  var playerUnderRoof = false;

  var screenTop = screen.top - tileSize;
  var screenRight = screen.right + tileSize;
  var screenBottom = screen.bottom + tileSize;
  var screenLeft = screen.left - tileSize;

  var maxZ = 0;
  var minZ = 0;
  late List<List<Node>> zPlain;

  double get renderX => (row - column) * tileSizeHalf;
  double get renderY => convertRowColumnZToY(row, column, z);

  @override
  void renderFunction() {

    while (column > 0 && row < rowsMax){
      assignNode();
      row++;
      column--;

      if (!node.renderable) continue;
      if (node.dstX > screenRight) return;
      assert (node.dstX >= screenLeft);
      assert (node.dstY >= screenTop);
      assert (node.dstY <= screenBottom);
      // if (node.dstX < screenLeft) {
      //   offscreenNodesLeft++;
      //   continue;
      // }
      // if (node.dstY < screenTop) {
      //   offscreenNodesTop++;
      //   return;
      // }
      // if (node.dstY > screenBottom) {
      //   offscreenNodesBottom++;
      //   return;
      // }
      // onscreenNodes++;
      if (node.visible) {
        node.handleRender();
      } else {
        node.visible = true;
      }
    }
  }

  @override
  void updateFunction() {
    zPlain = grid[z];
    nextGridNode();
    order = ((row + column) * tileSize) + tileSizeHalf;
    orderZ = z;
  }

  @override
  int getTotal() {
    return gridTotalZ * gridTotalRows * gridTotalColumns;
  }

  @override
  void reset() {
    rowsMax = gridTotalRows - 1;
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
    zPlain = grid[z];
    orderZ = 0;
    gridTotalColumnsMinusOne = gridTotalColumns - 1;
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
    refreshDynamicLightGrid();

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
    // super.reset();
    total = getTotal();
    _index = 0;
    remaining = total > 0;
  }


  void revealRaycast(int z, int row, int column){
    for (; z < gridTotalZ; z += 2){
      row++;
      column++;
      if (row >= gridTotalRows) return;
      if (column >= gridTotalColumns) return;
      getNode(z, row, column).hide();
      getNode(z + 1, row, column).hide();
    }
  }

  void revealAbove(int z, int row, int column){
    for (; z < gridTotalZ; z++){
      grid[z][row][column].hide();
    }
  }

  void trimTop() {
    while (renderY < screen.top){
      shiftIndexDown();
    }
    assignNode();
    calculateMinMaxZ();
    setStart();
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

  void nextGridNode(){
    z++;
    if (z > maxZ) {
      z = 0;
      shiftIndexDown();
      if (!remaining) return;
      calculateMinMaxZ();
      if (!remaining) return;
      trimLeft();

      while (renderY > screenBottom) {
        z++;
        if (z > maxZ) {
          remaining = false;
          return;
        }
      }
    } else {
      row = startRow;
      column = startColumn;
    }
    zPlain = grid[z];
  }

  void assignNode() {
    assert (z >= 0);
    assert (z < gridTotalZ);
    assert (row >= 0);
    assert (row < gridTotalRows);
    assert (column >= 0);
    assert (column < gridTotalColumns);
    node = zPlain[row][column];
  }

  void shiftIndexDown(){
    column = row + column + 1;
    row = 0;
    if (column < gridTotalColumns) {
      return setStart();
    }
    row = column - gridTotalColumnsMinusOne;
    column = gridTotalColumnsMinusOne;

    if (row >= gridTotalRows){
       remaining = false;
       return;
    }
    setStart();
  }

  void trimLeft(){
    final offscreen = countLeftOffscreen;
    if (offscreen <= 0) return;
    column -= offscreen;
    row += offscreen;
    while (renderX < screenLeft){
      row++;
      column--;
    }
    setStart();
  }

  void setStart(){
    startRow = row;
    startColumn = column;
  }

  int get countLeftOffscreen {
    final x = convertRowColumnToX(row, column);
    if (screen.left < x) return 0;
    final diff = screen.left - x;
    return diff ~/ tileSize;
  }

    void refreshDynamicLightGrid(){
        for (var z = 0; z < gridTotalZ; z++) {
          final zPlain = grid[z];
          final zLength = z * tileSize;
          final minRow = convertWorldToRowSafe(screenLeft, screenTop, zLength);
          final maxRow = convertWorldToRowSafe(screenRight, screenBottom, zLength);
          final minColumn = convertWorldToColumnSafe(screenRight, screenTop, zLength);
          final maxColumn = convertWorldToColumnSafe(screenLeft, screenBottom, zLength);
          for (var rowIndex = minRow; rowIndex <= maxRow; rowIndex++) {
            final dynamicRow = zPlain[rowIndex];
            for (var columnIndex = minColumn; columnIndex <= maxColumn; columnIndex++) {
              final node = dynamicRow[columnIndex];
              if (node.dstY > screenBottom) break;
              if (node.dstX > screenRight) continue;
              node.resetShadeToBake();
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
  var startRow = 0;
  var startColumn = 0;

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