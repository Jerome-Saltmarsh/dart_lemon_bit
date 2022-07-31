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

class RenderOrderGrid extends RenderOrder {
  var gridZ = 0;
  var gridColumn = 0;
  var gridRow = 0;
  late Node gridType;
  var maxColumnRow = 0;
  var minColumnRow = 0;
  var screenTopLeftRow = 0;
  var screenBottomRightRow = 0;
  var gridTotalColumnsMinusOne = 0;
  var gridZHalf = 0;
  late List<List<Node>> plain;

  var playerColumnRow = 0;
  var playerUnderRoof = false;

  var screenRight = engine.screen.right + tileSize;
  var screenLeft = engine.screen.left - tileSize;
  var screenTop = engine.screen.top - tileSize;
  var screenBottom = engine.screen.bottom + tileSize;

  var maxRow = 0;
  var minColumn = 0;
  var dstY = 0.0;

  @override
  void renderFunction() {
    transparent = false;
    if (playerImperceptible) {
      if (gridZGreaterThanPlayerZ) {
        final renderRow = gridRow - gridZHalf;
        final renderColumn = gridColumn - gridZHalf;
        final renderRowDistance = (renderRow - playerRenderRow).abs();
        final renderColumnDistance = (renderColumn - playerRenderColumn).abs();

        if (gridZ > playerZ + 1 && renderRowDistance <= 5 && renderColumnDistance <= 5) {
          // if (gridRow + gridColumn > playerColumnRow){
            return;
          // }
        }

        if (gridZ > playerZ && renderRowDistance < 2 && renderColumnDistance < 2) {
          if (gridRow + gridColumn >= playerColumnRow){
            transparent = true;
          }
        }
      }
    }

    gridType.performRender();
  }

  @override
  void updateFunction() {
    nextGridNode();
    while (gridType == GridNodeType.Empty) {
      index = _index + 1;
      if (!remaining) return;
      nextGridNode();
    }
    order = ((gridRow + gridColumn) * tileSize) + tileSizeHalf;
  }

  @override
  int getTotal() {
    return gridTotalZ * gridTotalRows * gridTotalColumns;
  }

  @override
  void reset() {
    order = 0;
    orderZ = 0;
    gridZ = 0;
    onZChanged();
    orderZ = 0;
    gridZHalf = 0;
    dstY = 0;
    plain = grid[gridZ];
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
    screenTop = screen.top;
    screenBottom = screen.bottom + (gridTotalZ * tileHeight);
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

    gridRow = screenTopLeftRow;
    gridColumn = screenTopLeftColumn;

    gridType = grid[gridZ][gridRow][gridColumn];

    assert(gridRow >= 0);
    assert(gridColumn >= 0);
    assert(gridRow < gridTotalRows);
    assert(gridColumn < gridTotalColumns);
    super.reset();
  }

  void onZChanged(){
    minColumn = convertWorldToColumnSafe(screenRight, screenTop, gridZ * tileSize);
    maxRow = convertWorldToRowSafe(screenRight, screenBottom, gridZ * tileSize);
    plain = grid[gridZ];
  }

  void nextGridNode(){
    gridRow++;
    gridColumn--;

    if (gridColumn < minColumn || gridRow >= maxRow) {

      while (true) {
        shiftIndexDown();
        final worldY = getTileWorldY(gridRow, gridColumn);
        var screenLeftColumn = convertWorldToColumn(screenLeft, worldY, 0);
        if (screenLeftColumn > 0 && screenLeftColumn < gridColumn) {
          final amount = gridColumn - screenLeftColumn;
          gridRow += amount;
          gridColumn -= amount;
        }
        if (
            gridColumn >= maxColumnRow - gridRow ||
            gridColumn >= gridTotalColumns ||
            gridRow >= maxRow
        ) {
          gridZ++;
          if (gridZ >= gridTotalZ) return end();
          onZChanged();
          orderZ = gridZ;
          gridZHalf =  gridZ ~/ 2;
          gridZGreaterThanPlayerZ = gridZ > playerZ;
          gridRow = 0;
          gridColumn = 0;
        }

        dstY = ((gridRow + gridColumn) * tileSizeHalf) - (gridZ * tileHeight);
        if (dstY > screenTop && dstY < screenBottom) break;
      }
    }
    gridType = plain[gridRow][gridColumn];
  }


  void shiftIndexDown(){
    gridColumn = gridRow + gridColumn + 1;
    gridRow = 0;
    if (gridColumn < gridTotalColumns) return;
    gridRow = gridColumn - gridTotalColumnsMinusOne;
    gridColumn = gridTotalColumnsMinusOne;
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
  }

  bool render() {
    assert(remaining);
    renderFunction();
    _index = (_index + 1);
    remaining = _index < total;
    if (remaining) {
      updateFunction();
      return true;
    } else {
      return false;
    }
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