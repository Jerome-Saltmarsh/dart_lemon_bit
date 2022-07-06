import 'dart:math';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/lighting/apply_emissions_npcs.dart';
import 'package:gamestream_flutter/isometric/render/render_floating_texts.dart';
import 'package:lemon_engine/screen.dart';
import 'package:lemon_math/library.dart';
import 'package:lemon_watch/watch.dart';
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/projectile.dart';
import 'package:gamestream_flutter/isometric/lighting/apply_particle_emissions.dart';
import 'package:gamestream_flutter/isometric/lighting/apply_player_emissions.dart';
import 'package:gamestream_flutter/isometric/lighting/apply_projectile_emissions.dart';
import 'package:gamestream_flutter/isometric/npcs.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/players.dart';
import 'package:gamestream_flutter/isometric/projectiles.dart';
import 'package:gamestream_flutter/isometric/render/render_grid_node_transparent.dart';
import 'package:gamestream_flutter/isometric/render/render_projectiles.dart';
import 'package:gamestream_flutter/isometric/render/render_zombie.dart';
import 'package:gamestream_flutter/isometric/utils/convert.dart';
import 'package:gamestream_flutter/isometric/zombies.dart';
import 'package:lemon_engine/engine.dart';

import '../classes/particle.dart';
import '../grid.dart';
import 'render_character.dart';
import 'render_grid_node.dart';
import 'render_particle.dart';


final renderOrder = <RenderOrder> [
  RenderOrderGrid(),
  RenderOrderPlayer(),
  RenderOrderZombie(),
  RenderOrderParticle(),
  RenderOrderProjectiles(),
  RenderOrderNpcs(),
];

// renderOrderLength gets called a lot during rendering so use a const and update it manually if need be
const renderOrderLength = 6;
var renderOrderFirst = renderOrder.first;
var anyRemaining = false;
var totalIndex = 0;

final maxZRender = Watch<int>(gridTotalZ, clamp: (int value){
  return clamp<int>(value, 0, max(grid.length - 1, 0));
});


void renderSprites() {
  for (final order in renderOrder){
      order.reset();
  }
  updateAnyRemaining();
  // totalIndex = 0;
  while (anyRemaining) {
    getNextRenderOrder().render();
    // totalIndex++;
  }
}

class RenderOrderZombie extends RenderOrder {
  late Character zombie;

  @override
  void renderFunction() {
    renderZombie(zombie);
  }

  @override
  void updateFunction() {
    zombie = zombies[_index];
    order = zombie.renderOrder;
    orderZ = zombie.indexZ;
  }

  @override
  int getTotal() {
    return totalZombies;
  }
}

class RenderOrderNpcs extends RenderOrder {
  late Character npc;

  @override
  void renderFunction() {
    renderCharacter(npc, renderHealthBar: false);
  }

  @override
  void updateFunction() {
    npc = npcs[_index];
    order = npc.renderOrder;
    orderZ = npc.indexZ;
  }

  @override
  int getTotal() {
    return totalNpcs;
  }

  @override
  void reset() {
    applyEmissionsNpcs();
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
    for (var i = 0; i < totalActive; i++){
       applyParticleEmission(particles[i]);
    }
    super.reset();
  }
}

class RenderOrderPlayer extends RenderOrder {
  late Character player;

  @override
  void renderFunction() {
    renderCharacter(player);
  }

  @override
  void updateFunction() {
    player = players[_index];
    order = player.renderOrder;
    orderZ = player.indexZ;
  }

  @override
  int getTotal() {
    return totalPlayers;
  }

  @override
  void reset() {
    applyPlayerEmissions();
    super.reset();
  }
}

class RenderOrderGrid extends RenderOrder {
  var gridZ = 0;
  var gridColumn = 0;
  var gridRow = 0;
  var gridType = 0;
  var maxColumnRow = 0;
  var minColumnRow = 0;
  var gridTotalColumnsMinusOne = 0;
  var maxRow = 0;
  var gridZHalf = 0;
  late List<List<int>> plain;
  late List<List<int>> shadePlain;

  var playerZ = 0;
  var playerRow = 0;
  var playerColumn = 0;
  var playerRenderRow = 0;
  var playerRenderColumn = 0;
  var playerUnderRoof = false;
  var playerImperceptible = false;
  var gridZGreaterThanPlayerZ = false;

  var screenRight = engine.screen.right + tileSize;
  var screenLeft = engine.screen.left - tileSize;
  var screenTop = engine.screen.top - tileSize;
  var screenBottom = engine.screen.bottom + tileSize;

  var dstY = 0.0;

  @override
  void renderFunction() {
    if (playerImperceptible) {
      if (gridZGreaterThanPlayerZ) {
        final renderRow = gridRow - gridZHalf;
        final renderColumn = gridColumn - gridZHalf;
        final renderRowDistance = (renderRow - playerRenderRow).abs();
        final renderColumnDistance = (renderColumn - playerRenderColumn).abs();
        const radius = 7;
        if (renderRowDistance < radius && renderColumnDistance < radius){
          if (gridZ > playerZ + 2) return;
          final renderRowMatch = renderRow == playerRenderRow;
          final renderColumnMatch = renderColumn == playerRenderColumn;
          if (
           (renderRowMatch && renderColumnMatch) ||
           (renderRowMatch && renderColumn == playerRenderColumn - 1) ||
           (renderRowMatch && renderColumn == playerRenderColumn + 1) ||
           (renderRow == playerRenderRow - 1 && renderColumnMatch) ||
           (renderRow == playerRenderRow + 1 && renderColumnMatch) ||
           (renderRow == playerRenderRow + 1 && renderColumn == playerRenderColumn + 1) ||
           (renderRow == playerRenderRow - 1 && renderColumn == playerRenderColumn - 1)
          ){
            return renderGridNodeTransparent(gridZ, gridRow, gridColumn, gridType);
          }
        }
      }
    }

    renderGridNode(
        gridZ,
        gridRow,
        gridColumn,
        gridType,
        dstY,
        shadePlain[gridRow][gridColumn],
    );
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
    orderZ = 0;
    gridZHalf = 0;
    dstY = 0;
    plain = grid[gridZ];
    shadePlain = gridLightDynamic[gridZ];
    gridType = 0;
    gridTotalColumnsMinusOne = gridTotalColumns - 1;
    playerZ = player.indexZ;
    playerRow = player.indexRow;
    playerColumn = player.indexColumn;
    playerRenderRow = playerRow - (player.indexZ ~/ 2);
    playerRenderColumn = playerColumn - (player.indexZ ~/ 2);
    playerUnderRoof = gridIsUnderSomething(playerZ, playerRow, playerColumn);
    gridZGreaterThanPlayerZ = false;
    playerImperceptible = !gridIsPerceptible(playerZ, playerRow, playerColumn);

    screenRight = screen.right + tileSize;
    screenLeft = screen.left - tileSize;
    screenTop = screen.top;
    screenBottom = screen.bottom + (gridTotalZ * tileHeight);
    final screenBottomLeftColumn = convertWorldToColumn(screenLeft, screenBottom, 0);
    final screenBottomLeftRow = convertWorldToRow(screenLeft, screenBottom, 0);
    final screenBottomLeftTotal = screenBottomLeftRow + screenBottomLeftColumn;
    final screenTopLeftColumn = convertWorldToColumn(screenLeft, screenTop, 0);
    final screenTopLeftRow = convertWorldToRow(screenLeft, screenTop, 0);
    minColumnRow = max(screenTopLeftRow + screenTopLeftColumn, 0);
    maxColumnRow = min(gridTotalRows + gridTotalColumns, screenBottomLeftTotal);

    gridRow = screenTopLeftRow;
    gridColumn = screenTopLeftColumn;

    if (gridRow < 0) {
      gridColumn += gridRow;
      gridRow = 0;
    }
    if (gridColumn < 0){
      gridRow += gridColumn;
      gridColumn = 0;
    }
    if (gridColumn >= gridTotalColumns) {
      gridRow = gridColumn - gridTotalColumnsMinusOne;
      gridColumn = gridTotalColumnsMinusOne;
    }
    if (gridRow < 0 || gridColumn < 0){
      gridRow = 0;
      gridColumn = 0;
    }

    assert(gridRow >= 0);
    assert(gridColumn >= 0);
    assert(gridRow < gridTotalColumns);
    assert(gridColumn < gridTotalColumns);
    recalculateMaxRow();
    refreshDynamicLightGrid();

    super.reset();
  }

  void refreshDynamicLightGrid(){
    for (var z = 0; z < gridTotalZ; z++) {
      final dynamicPlain = gridLightDynamic[z];
      final bakePlain = gridLightBake[z];
      for (var rowIndex = 0; rowIndex < gridTotalRows; rowIndex++) {
        final dynamicRow = dynamicPlain[rowIndex];
        final bakeRow = bakePlain[rowIndex];
        for (var columnIndex = 0; columnIndex < gridTotalColumns; columnIndex++) {
          dynamicRow[columnIndex] = bakeRow[columnIndex];
        }
      }
    }
  }

  void recalculateMaxRow() {

    maxRow = (screenRight + (gridRow + gridColumn) * tileSizeHalf) ~/ tileSize;

    if (maxRow > gridTotalRows) {
      maxRow = gridTotalRows;
    }
  }

  void nextGridNode(){
    gridRow++;
    gridColumn--;

    if (gridColumn < 0 || gridRow >= maxRow) {

      while (true) {
        shiftIndexDown();
        recalculateMaxRow();
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
            gridRow >= gridTotalRows
        ) {
          gridZ++;
          orderZ = gridZ;
          if (gridZ >= gridTotalZ || gridZ > maxZRender.value) return end();
          gridZHalf =  gridZ ~/ 2;
          gridZGreaterThanPlayerZ = gridZ > playerZ;
          gridRow = 0;
          gridColumn = 0;
          plain = grid[gridZ];
          shadePlain = gridLightDynamic[gridZ];
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
    index = 0;
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
    if (!remaining){
      updateAnyRemaining();
    }
  }

  void end(){
     index = total;
  }

  void render() {
    assert(remaining);
    renderFunction();
    index = (_index + 1);
    if (remaining) {
      updateFunction();
    } else {
      updateAnyRemaining();
    }
  }
}

RenderOrder getNextRenderOrder(){
  assert (anyRemaining);
  var next = renderOrderFirst;
  for (var i = 1; i < renderOrderLength; i++){
    next =  next.compare(renderOrder[i]);
  }
  assert(next.remaining);
  return next;
}

void updateAnyRemaining(){
  for (final order in renderOrder){
    if (!order.remaining) continue;
    anyRemaining = true;
    return;
  }
  anyRemaining = false;
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